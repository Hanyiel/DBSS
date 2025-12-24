# DBSS Frontend（Vite + React）

## Quickstart

```powershell
cd frontend
npm install
npm run dev
```

Dev server：`http://localhost:5173`

## Notes

- 登录页调用后端 `POST /api/auth/token`，token 保存到 `localStorage.access_token`
- 迁移页调用 `/api/migration/*`（需要管理员 token）
- 数据库操作页（`/db`）调用 `/api/db/*`（需要管理员 token）
