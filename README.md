# DBSS：多数据库同步系统（MySQL + PostgreSQL + Oracle）

目录结构：
- `deploy/`：Docker Compose（三库/全栈）
- `init/`：三库初始化脚本（业务表 + 同步系统表 + `change_log` 触发器）
- `backend/`：FastAPI 后端（`/api/*`）
- `frontend/`：Vite + React 前端（页面 `/db`、`/migration`）

## 1) 启动三库（推荐先跑通）

```powershell
cd deploy
docker compose up -d
```

如果你之前已经启动过（本地卷 `data/*` 已存在），Docker 的初始化脚本不会再次执行；请看下面 “change_log 怎么配置”。

## 2) 启动后端（本地开发）

```powershell
cd backend
pip install -r requirements.txt
Copy-Item .env.example .env
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Swagger：`http://localhost:8000/docs`

## 3) 启动前端（本地开发）

```powershell
cd frontend
npm install
Copy-Item .env.example .env
npm run dev
```

打开 `http://localhost:5173`。

## change_log 怎么配置（同步系统初始化）

同步依赖每个库里都有这些对象：`change_log`、`sync_applied`、`conflicts`、`sync_stats_daily`，以及业务表对应的触发器（把 I/U/D 记录到 `change_log`）。

检查当前是否齐全：
- `GET /api/sync/precheck`（需要管理员 token）

两种初始化方式：
1) **推荐：重建容器数据卷（开发环境）**：执行 `deploy/rebuild.ps1`（会删除 `data/mysql|postgres|oracle`，然后重新 `docker compose up -d`，触发 `init/*` 脚本）
2) **保留数据：手动执行 SQL**：按顺序执行每个库的脚本：
   - `init/<db>/002_sync_system.sql`
   - `init/<db>/003_change_log_triggers.sql`

## 插入/删除没同步的排查

- UI `/db` 页面插入/删除：后端会尝试同步到另外两库，并在响应里返回 `sync` 结果（Oracle 不可用时会显示失败原因）。
- 如果你在 Navicat/SQL*Plus 里直接改库：需要运行 Worker 或调用 `POST /api/sync/run-once` 才会消费 `change_log`。
- 如果报 `change_log doesn't exist`：说明还没初始化同步系统（按上面配置）。

## Oracle 打不开（WinError 10061 / Connection refused）

这通常不是代码问题，而是 Oracle 实例没启动或端口未监听：
- 先确认 `db-oracle` 容器在跑：`docker ps`
- 确认 `deploy/docker-compose.yml` 暴露了 `1521:1521`
- 确认 `backend/.env` 的 `ORACLE_HOST/ORACLE_PORT/ORACLE_SERVICE_NAME/ORACLE_USER/ORACLE_PASSWORD` 与 `deploy/.env` 一致
