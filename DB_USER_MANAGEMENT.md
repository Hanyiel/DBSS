# 数据库层面的用户与权限管理（DBSS）

本项目为了满足“数据库层面用户管理 + 权限管理”的实践要求，在 **MySQL / PostgreSQL / Oracle** 三个数据库中分别创建了 4 个登录用户，并通过角色（role）授予不同权限，以区分“登录数据库后能做什么”。

> 说明：这些账号/密码用于课程演示，生产环境请自行修改密码并按最小权限原则细化授权。

---

## 1. 账号与角色（统一命名）

为三库创建的用户（登录账号）：

- **管理员**：`dbss_admin` / `DBSS_ADMIN`（密码：`DbssAdmin_111111`）
- **业务读写**：`dbss_rw` / `DBSS_RW`（密码：`DbssRw_111111`）
- **只读**：`dbss_ro` / `DBSS_RO`（密码：`DbssRo_111111`）
- **审计/监控只读**：`dbss_auditor` / `DBSS_AUDITOR`（密码：`DbssAudit_111111`）

对应角色（不登录、只用于授权）：

- MySQL：`dbss_role_admin` / `dbss_role_rw` / `dbss_role_ro` / `dbss_role_audit`
- PostgreSQL：`dbss_role_admin` / `dbss_role_rw` / `dbss_role_ro` / `dbss_role_audit`
- Oracle：`DBSS_ROLE_ADMIN` / `DBSS_ROLE_RW` / `DBSS_ROLE_RO` / `DBSS_ROLE_AUDIT`

---

## 2. 每个用户拥有哪些权限（最终效果）

### 2.1 `dbss_admin`（管理员）

用途：初始化、DDL 维护、排障、全量读写。

- MySQL：`video_conference.*` **ALL PRIVILEGES**
- PostgreSQL：`public` schema 下 **所有表/序列 ALL PRIVILEGES**（并可连接 `video_conference`）
- Oracle：对 `LHY` schema（默认 APP_USER）下 **业务表 + 同步系统表 ALL**；并额外授予 `SELECT_CATALOG_ROLE`（方便演示查看字典视图）

### 2.2 `dbss_rw`（业务读写）

用途：业务数据增删改查，但不允许做 DDL；可查看同步/审计信息用于定位问题。

- 业务表（CRUD）：`users`、`friend_categories`、`friendships`、`friend_requests`、`rooms`、`permission_roles`、`meeting_permissions`、`room_participants`、`messages`、`waiting_room`、`meeting_recordings`
- 同步/审计表（只读）：`change_log`、`audit_log`、`conflicts`、`sync_applied`、`sync_stats_daily`
- PostgreSQL 额外：授予 `USAGE/SELECT` on sequences（避免 identity 默认值插入时报权限问题）

### 2.3 `dbss_ro`（只读）

用途：只允许查询数据（例如只读报表、只读排查）。

- MySQL：`video_conference.*` **SELECT**
- PostgreSQL：`public` schema 下 **所有表 SELECT**
- Oracle：对 `LHY` schema 下 **业务表 SELECT**

> 注：只读用户不授予 `change_log/audit_log` 的写权限，不会影响触发器记录变更；触发器由表所有者/定义者执行。

### 2.4 `dbss_auditor`（审计/监控只读）

用途：仅查看同步与审计相关表，不接触业务表数据。

- 仅 SELECT：`change_log`、`audit_log`、`conflicts`、`sync_applied`、`sync_stats_daily`

---

## 3. 脚本在哪里，如何执行

对应脚本（已加入项目）：

- MySQL：`init/mysql/005_users_roles.sql`
- PostgreSQL：`init/postgres/005_users_roles.sql`
- Oracle：`init/oracle/005_users_roles.sql`

### 3.1 自动执行（推荐，适用于首次初始化）

Docker 只会在“数据卷为空”的首次启动时自动执行 `init/*` 脚本：

- 执行 `deploy/rebuild.ps1`（会删除 `data/mysql|postgres|oracle` 并重建）
- 然后 `docker compose up -d`

### 3.2 手动执行（适用于已经有 data/* 的情况）

如果你以前启动过容器（`data/*` 已存在），需要手动执行脚本。

**MySQL（root 执行）**

在任意 MySQL 客户端里用 `root` 连接后执行 `init/mysql/005_users_roles.sql`。

**PostgreSQL（超级用户执行，默认 `POSTGRES_USER`）**

用 `POSTGRES_USER`（`deploy/.env` 里默认是 `lhy`）连接到 `video_conference` 后执行 `init/postgres/005_users_roles.sql`。

**Oracle（需要 SYS 执行）**

`init/oracle/005_users_roles.sql` 需要以 `SYS`（或具备 `CREATE USER/ROLE` 权限的 DBA）执行。
默认 `deploy/.env` 已设置 `ORACLE_PASSWORD=OracleSysPwd_111111`，用于课程演示。

---

## 4. 如何验证权限（建议在验收时截图）

**MySQL**
```sql
SHOW GRANTS FOR 'dbss_admin'@'%';
SHOW GRANTS FOR 'dbss_rw'@'%';
SHOW GRANTS FOR 'dbss_ro'@'%';
SHOW GRANTS FOR 'dbss_auditor'@'%';
```

**PostgreSQL**
```sql
\\du+
\\dp users
\\dp change_log
```

**Oracle**
```sql
SELECT * FROM dba_role_privs WHERE grantee IN ('DBSS_ADMIN','DBSS_RW','DBSS_RO','DBSS_AUDITOR');
SELECT * FROM dba_tab_privs WHERE grantee IN ('DBSS_ROLE_ADMIN','DBSS_ROLE_RW','DBSS_ROLE_RO','DBSS_ROLE_AUDIT');
```

