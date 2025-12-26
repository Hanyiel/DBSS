# 冲突邮件通知（DBSS）

本项目支持在“同步写入失败 / 冲突产生”时，自动给管理员发送邮件提醒。邮件中包含一个可点击链接（PC/移动端通用），链接参数携带短期 JWT token，用于免登录查看冲突页面。

---

## 1. 触发时机

当后端检测到冲突并写入 `conflicts` 表（`status='open'`）时触发邮件：
- 同步 Worker（`change_log` 应用到目标库失败且判定为冲突）
- 巡检 reconcile（发现三库数据不一致并写入 `conflicts`）

> 为避免刷屏：同一条 “open 冲突（同 table/pk/source/target）” 会做去重，只有首次写入才会发送。

---

## 2. 邮件内容与链接

邮件内容包含：
- `store_db`、`conflict_id`（如果可获取）、`table_name`、`pk_value`、`source_db/target_db`、`reason`
- 查看链接：`{FRONTEND_PUBLIC_URL}/email-login?...`

链接参数：
- `token`：短期 JWT（包含 `role=admin`，用于前端写入 localStorage 并自动登录）
- `store_db`、`conflict_id`：用于打开冲突页面并自动弹出对应详情

前端落地页：`/email-login`（`frontend/src/pages/EmailLoginPage.tsx`）

---

## 3. 配置（以 163 邮箱为例）

在 `backend/.env` 里配置（先复制 `backend/.env.example`）：

```env
EMAIL_ENABLED=true

EMAIL_SMTP_HOST=smtp.163.com
EMAIL_SMTP_PORT=465
EMAIL_SMTP_USERNAME=你的163邮箱@163.com
# 注意：这里填 163 的“SMTP授权码”，不是登录密码
EMAIL_SMTP_PASSWORD=你的SMTP授权码

EMAIL_USE_SSL=true
EMAIL_USE_TLS=false

EMAIL_FROM=你的163邮箱@163.com
EMAIL_TO=管理员收件邮箱1@xxx.com,管理员收件邮箱2@xxx.com

FRONTEND_PUBLIC_URL=http://localhost:5173
EMAIL_LINK_TOKEN_EXPIRE_MINUTES=60
EMAIL_MAX_PER_RUN=10
```

163 邮箱后台需要开启 SMTP 并生成授权码（在邮箱设置里）。

---

## 4. 验证方式

1) 启动后端与前端
2) 登录管理员（或直接点击邮件链接）
3) 制造冲突：
   - 前端冲突页点“制造演示冲突（users 唯一键）”，或
   - 直接让目标库先插入同 username，再从源库插入同 username
4) 观察收件箱，点击链接应能直接打开 `/conflicts` 并展示对应冲突

也可以先用测试接口验证 SMTP 配置是否正确（推荐）：
- `GET /api/notify/email/config`
- `POST /api/notify/email/test`（body 可选：`{"to":"xxx@xxx.com"}`）

如果要在手机上点击链接访问：
- 前端 Vite 需要监听 `0.0.0.0`（允许局域网访问），例如 `npm run dev -- --host 0.0.0.0 --port 5173`
- 后端 Uvicorn 也需要监听 `0.0.0.0`，例如 `python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
- `FRONTEND_PUBLIC_URL` 要写成你电脑局域网 IP（不能用 `localhost`）

---

## 5. 相关代码位置

- 邮件发送：`backend/app/services/notify_email.py`
- 冲突写入（同步 Worker）：`backend/app/services/sync.py`（`_record_conflict`）
- 巡检冲突（reconcile）：`backend/app/services/reconcile.py`
- 邮件落地页：`frontend/src/pages/EmailLoginPage.tsx`
- 冲突页 deep link：`frontend/src/pages/ConflictsPage.tsx`（读取 `store_db/conflict_id`）
