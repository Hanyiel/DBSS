# 数据库查询/触发器/存储过程库（DBSS）

这个文件用于集中存放 **MySQL / PostgreSQL / Oracle** 的常用查询、触发器、存储过程（或函数）模板，以及同步/审计相关的排查 SQL。

> 说明：不要用“每隔几秒全表扫描对比”来做同步或冲突检测；那会非常慢。
> 正确做法是：**触发器/审计把变更写到日志表（change_log/audit_log）**，后端 Worker 只轮询这些“小表”，再把变更应用到其他库。

---

## 1. 同步与审计的推荐实现方式（架构）

1) **业务表触发器**（每个库各自实现）
- 对业务表 INSERT/UPDATE/DELETE
- 写入两张表：
  - `change_log`：用于“同步”（只需要 table/pk/op/created_at/processed）
  - `audit_log`：用于“审计/冲突说明”（可保存 old/new 快照、操作人、时间等）

2) **后端 Worker**
- 周期性拉取 `change_log where processed=0`
- 对每条变更：读取源库当前行（I/U）或按 pk 删除（D），应用到另外两库
- 写入 `sync_applied`（每个 target 一行）
- 冲突检测：写入 `conflicts`（open），并可触发邮件通知（任务书要求）
- 统计：更新 `sync_stats_daily`（日报数据）

---

## 2. MySQL 常用 SQL（排查/审计/触发器）

### 2.1 查看触发器
```sql
SHOW TRIGGERS;
SHOW TRIGGERS LIKE 'users';
```

### 2.2 同步事件（change_log）
```sql
SELECT * FROM change_log ORDER BY id DESC LIMIT 50;
SELECT * FROM change_log WHERE processed = 0 ORDER BY id ASC LIMIT 50;
```

### 2.3 审计日志（audit_log）
```sql
SELECT * FROM audit_log ORDER BY id DESC LIMIT 50;
SELECT * FROM audit_log WHERE table_name='users' AND pk_value='1' ORDER BY id DESC LIMIT 20;
```

### 2.4 冲突与同步结果
```sql
SELECT * FROM conflicts WHERE status='open' ORDER BY detected_at DESC LIMIT 50;
SELECT * FROM sync_applied ORDER BY id DESC LIMIT 50;
```

### 2.5 日报统计
```sql
SELECT * FROM sync_stats_daily ORDER BY stat_date DESC LIMIT 30;
```

---

## 3. PostgreSQL 常用 SQL（排查/审计/触发器）

### 3.1 查看触发器与触发函数
```sql
SELECT tgname, tgrelid::regclass AS table_name
FROM pg_trigger
WHERE NOT tgisinternal
ORDER BY table_name, tgname;
```

### 3.2 change_log / audit_log
```sql
SELECT * FROM change_log ORDER BY id DESC LIMIT 50;
SELECT * FROM change_log WHERE processed = FALSE ORDER BY id ASC LIMIT 50;

SELECT * FROM audit_log ORDER BY id DESC LIMIT 50;
SELECT * FROM audit_log WHERE table_name='users' AND pk_value='1' ORDER BY id DESC LIMIT 20;
```

### 3.3 conflicts / sync_applied / sync_stats_daily
```sql
SELECT * FROM conflicts WHERE status='open' ORDER BY detected_at DESC LIMIT 50;
SELECT * FROM sync_applied ORDER BY id DESC LIMIT 50;
SELECT * FROM sync_stats_daily ORDER BY stat_date DESC LIMIT 30;
```

---

## 4. Oracle 常用 SQL（排查/审计/触发器）

> 注意 Oracle schema/大小写：建议统一用未加引号建表（默认会转大写），后端会做不区分大小写的表名解析。

### 4.1 查看触发器
```sql
SELECT trigger_name, table_name, status
FROM user_triggers
ORDER BY table_name, trigger_name;
```

### 4.2 change_log / audit_log
```sql
SELECT * FROM change_log ORDER BY id DESC FETCH FIRST 50 ROWS ONLY;
SELECT * FROM change_log WHERE processed = 0 ORDER BY id ASC FETCH FIRST 50 ROWS ONLY;

SELECT * FROM audit_log ORDER BY id DESC FETCH FIRST 50 ROWS ONLY;
```

### 4.3 conflicts / sync_applied / sync_stats_daily
```sql
SELECT * FROM conflicts WHERE status='open' ORDER BY detected_at DESC FETCH FIRST 50 ROWS ONLY;
SELECT * FROM sync_applied ORDER BY id DESC FETCH FIRST 50 ROWS ONLY;
SELECT * FROM sync_stats_daily ORDER BY stat_date DESC FETCH FIRST 30 ROWS ONLY;
```

---

## 5. 脚本位置（本项目）

- 同步系统表：`init/mysql/002_sync_system.sql`、`init/postgres/002_sync_system.sql`、`init/oracle/002_sync_system.sql`
- 触发器（写入 change_log + audit_log）：`init/*/003_change_log_triggers.sql`

## 6. 让审计/触发器生效（重要）

Docker 只会在“数据卷为空”的首次启动时自动执行 `init/*` 脚本；如果你以前启动过容器（`data/*` 已存在），需要：

- 开发环境（最省事）：运行 `deploy/rebuild.ps1` 重新初始化三库（会清空 `data/mysql|postgres|oracle`）
- 保留数据：手动在各数据库执行：
  - `init/<db>/002_sync_system.sql`（创建 audit_log 等系统表）
  - `init/<db>/003_change_log_triggers.sql`（重建触发器）

然后用下面 SQL 验证：
- `SELECT * FROM audit_log ORDER BY id DESC LIMIT 5;`
- `SELECT * FROM change_log ORDER BY id DESC LIMIT 5;`

## 7. 升级 conflicts（保存“解决方式/备注”）

本项目已在初始化脚本里给 `conflicts` 增加了 `resolution_method`/`resolution_note` 用于保存“最新/手动”等解决策略与备注。
如果你的数据库是旧数据卷启动的（表已存在），需要手动 `ALTER TABLE`：

**MySQL**
```sql
ALTER TABLE conflicts
  ADD COLUMN resolution_method VARCHAR(20) NULL,
  ADD COLUMN resolution_note VARCHAR(255) NULL;
```

**PostgreSQL**
```sql
ALTER TABLE conflicts ADD COLUMN IF NOT EXISTS resolution_method TEXT;
ALTER TABLE conflicts ADD COLUMN IF NOT EXISTS resolution_note TEXT;
```

**Oracle**
```sql
ALTER TABLE conflicts ADD (resolution_method VARCHAR2(20));
ALTER TABLE conflicts ADD (resolution_note VARCHAR2(255));
```

## 8. 每分钟巡检（reconcile）= “扫描小范围数据找冲突”

如果你想演示“系统每分钟自动发现冲突”，建议用后端定时任务做 **小范围巡检**：

- 每分钟（`RECONCILE_INTERVAL_SECONDS=60`）执行一次
- 只抽样检查“最近 N 分钟更新/创建”的行（`RECONCILE_WINDOW_MINUTES`），而不是全表全量扫描
- 发现不一致就写入 `conflicts`（避免重复会做去重）

配置（`backend/.env`）：
```env
RECONCILE_ENABLED=true
RECONCILE_INTERVAL_SECONDS=60
RECONCILE_WINDOW_MINUTES=5
RECONCILE_MAX_PKS=200
RECONCILE_FULL_SCAN_MAX_PKS=5000
RECONCILE_STORE_DB=mysql
RECONCILE_RUN_ON_STARTUP=true
RECONCILE_STARTUP_FULL_SCAN=true
```

手动触发一次（方便验收/调试）：
- `POST /api/reconcile/run`（需要管理员 token）

---

## 9. 复杂查询展示（用于页面演示）

前端页面：`/queries`（“查询”）。后端会返回：
- `sql`：实际执行的 SQL 文本（方便展示）
- `rows`：查询结果
- `explain`：执行计划（MySQL: `EXPLAIN`，Postgres: `EXPLAIN`，Oracle: `EXPLAIN PLAN + DBMS_XPLAN`）

### 9.1 活跃会议室概览（room_activity）

**优化点（索引建议）**
- `rooms(status)`, `rooms(host_id)`
- `room_participants(room_id, participant_status)`
- `messages(room_id, created_at)`

**SQL（MySQL / PostgreSQL）**
```sql
SELECT
  r.id AS room_id,
  r.meeting_code,
  r.name AS room_name,
  u.username AS host_username,
  (
    SELECT COUNT(*)
    FROM room_participants rp
    WHERE rp.room_id = r.id AND rp.participant_status = 'active'
  ) AS active_participants,
  (
    SELECT COUNT(*)
    FROM messages m
    WHERE m.room_id = r.id AND m.created_at >= :since
  ) AS messages_since,
  (
    SELECT MAX(m2.created_at)
    FROM messages m2
    WHERE m2.room_id = r.id
  ) AS last_message_at
FROM rooms r
JOIN users u ON u.id = r.host_id
WHERE r.status = 'active'
ORDER BY messages_since DESC, active_participants DESC, r.id DESC
LIMIT :limit;
```

**SQL（Oracle）**
```sql
SELECT *
FROM (
  SELECT
    r.id AS room_id,
    r.meeting_code,
    r.name AS room_name,
    u.username AS host_username,
    (
      SELECT COUNT(*)
      FROM room_participants rp
      WHERE rp.room_id = r.id AND rp.participant_status = 'active'
    ) AS active_participants,
    (
      SELECT COUNT(*)
      FROM messages m
      WHERE m.room_id = r.id AND m.created_at >= :since
    ) AS messages_since,
    (
      SELECT MAX(m2.created_at)
      FROM messages m2
      WHERE m2.room_id = r.id
    ) AS last_message_at
  FROM rooms r
  JOIN users u ON u.id = r.host_id
  WHERE r.status = 'active'
  ORDER BY messages_since DESC, active_participants DESC, r.id DESC
)
WHERE ROWNUM <= :limit;
```

### 9.2 用户社交活跃度（user_social_activity）

**优化点（索引建议）**
- `messages(user_id, created_at)`（本项目初始化脚本已补充）
- `room_participants(user_id, participant_status)`
- `friend_requests(status, to_user_id)`（本项目初始化脚本已补充）

**SQL（MySQL / PostgreSQL）**
```sql
SELECT
  u.id AS user_id,
  u.username,
  u.email,
  COALESCE(f.friend_count, 0) AS friend_count,
  COALESCE(p.pending_in, 0) AS pending_in_requests,
  COALESCE(m.msg_count, 0) AS messages_since,
  COALESCE(ar.active_room_count, 0) AS active_rooms
FROM users u
LEFT JOIN (
  SELECT user_id, COUNT(*) AS friend_count
  FROM friendships
  GROUP BY user_id
) f ON f.user_id = u.id
LEFT JOIN (
  SELECT to_user_id, COUNT(*) AS pending_in
  FROM friend_requests
  WHERE status = 'pending'
  GROUP BY to_user_id
) p ON p.to_user_id = u.id
LEFT JOIN (
  SELECT m.user_id, COUNT(*) AS msg_count
  FROM messages m
  WHERE m.created_at >= :since
    AND m.room_id IN (
      SELECT rp.room_id
      FROM room_participants rp
      WHERE rp.user_id = m.user_id AND rp.participant_status = 'active'
    )
  GROUP BY m.user_id
) m ON m.user_id = u.id
LEFT JOIN (
  SELECT rp.user_id, COUNT(DISTINCT rp.room_id) AS active_room_count
  FROM room_participants rp
  JOIN rooms r ON r.id = rp.room_id
  WHERE rp.participant_status = 'active' AND r.status = 'active'
  GROUP BY rp.user_id
) ar ON ar.user_id = u.id
ORDER BY messages_since DESC, pending_in_requests DESC, user_id DESC
LIMIT :limit;
```

**SQL（Oracle）**
```sql
SELECT *
FROM (
  SELECT
    u.id AS user_id,
    u.username,
    u.email,
    COALESCE(f.friend_count, 0) AS friend_count,
    COALESCE(p.pending_in, 0) AS pending_in_requests,
    COALESCE(m.msg_count, 0) AS messages_since,
    COALESCE(ar.active_room_count, 0) AS active_rooms
  FROM users u
  LEFT JOIN (
    SELECT user_id, COUNT(*) AS friend_count
    FROM friendships
    GROUP BY user_id
  ) f ON f.user_id = u.id
  LEFT JOIN (
    SELECT to_user_id, COUNT(*) AS pending_in
    FROM friend_requests
    WHERE status = 'pending'
    GROUP BY to_user_id
  ) p ON p.to_user_id = u.id
  LEFT JOIN (
    SELECT m.user_id, COUNT(*) AS msg_count
    FROM messages m
    WHERE m.created_at >= :since
      AND m.room_id IN (
        SELECT rp.room_id
        FROM room_participants rp
        WHERE rp.user_id = m.user_id AND rp.participant_status = 'active'
      )
    GROUP BY m.user_id
  ) m ON m.user_id = u.id
  LEFT JOIN (
    SELECT rp.user_id, COUNT(DISTINCT rp.room_id) AS active_room_count
    FROM room_participants rp
    JOIN rooms r ON r.id = rp.room_id
    WHERE rp.participant_status = 'active' AND r.status = 'active'
    GROUP BY rp.user_id
  ) ar ON ar.user_id = u.id
  ORDER BY messages_since DESC, pending_in_requests DESC, user_id DESC
)
WHERE ROWNUM <= :limit;
```

