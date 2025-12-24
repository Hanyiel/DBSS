# DBSS Backend（FastAPI）

## Quickstart（本地开发）

1) 安装依赖

```powershell
cd backend
pip install -r requirements.txt
```

2) 配置环境变量

```powershell
Copy-Item .env.example .env
```

注意：
- `ORACLE_USER`/`ORACLE_PASSWORD` 必须与 `deploy/.env` 的 `ORACLE_APP_USER`/`ORACLE_APP_USER_PASSWORD` 一致（默认 `lhy`）
- 如果 Oracle 表在其他 schema 下（例如以前用过不同的 APP_USER），设置 `ORACLE_SCHEMA=XXX`

3) 启动

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Swagger：`http://localhost:8000/docs`

## 同步系统（change_log）

- 检查同步系统表是否存在：`GET /api/sync/precheck`
- UI `/db` 的插入/删除会返回 `sync` 结果（并尝试同步到另外两库）
- 直接在数据库里写入（Navicat 等）需要 Worker/`run-once` 来消费 `change_log`
