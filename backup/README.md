# `backup/`

用于存放三库（MySQL / PostgreSQL / Oracle）的备份导出文件与说明。

## 使用方法（PowerShell）

- 导出/备份（MySQL + PostgreSQL + Oracle）：`cd deploy; .\backup.ps1`
- 从某次备份恢复：`cd deploy; .\restore.ps1 -FromDir ..\backup\dumps\YYYYMMDD-HHMMSS`

可按需跳过某个库：
- `.\backup.ps1 -SkipOracle`
- `.\restore.ps1 -FromDir ..\backup\dumps\... -SkipOracle`

## 网页触发备份（可选）

如果你使用了本项目的 Web 管理页，也可以在“迁移”页面点击“一键备份”。

- 后端接口：`POST /api/migration/backup`
- 输出目录：`backup/dumps/<timestamp>/`

## 备份产物说明

每次备份会生成一个目录：`backup/dumps/<timestamp>/`

- `mysql.sql`：MySQL 全库 dump（含表结构/数据/触发器/存储过程等）
- `postgres.dump`：PostgreSQL `pg_dump -Fc` 格式
- `oracle.dmp` / `oracle.log`：Oracle Data Pump 导出文件与日志
- `meta.txt`：备份时间与容器信息

## 注意事项

- 脚本会读取 `deploy/.env` 获取账号与密码：`deploy/backup.ps1`、`deploy/restore.ps1`
- Oracle 备份/恢复使用 `expdp/impdp`，脚本会自动为应用用户授予 `DATA_PUMP_DIR` 的读写权限（用于演示环境）
- Oracle 恢复使用 `impdp ... table_exists_action=replace`，适合演示；生产环境建议采用更严格的恢复策略
