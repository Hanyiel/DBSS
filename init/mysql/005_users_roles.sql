-- DBSS database-level users & roles (MySQL 8)
-- This script is intended to run during container init (docker-entrypoint-initdb.d).
-- It creates 4 login users with different privileges to demonstrate DB-layer access control.

-- Roles
CREATE ROLE IF NOT EXISTS `dbss_role_admin`;
CREATE ROLE IF NOT EXISTS `dbss_role_rw`;
CREATE ROLE IF NOT EXISTS `dbss_role_ro`;
CREATE ROLE IF NOT EXISTS `dbss_role_audit`;

-- Users
CREATE USER IF NOT EXISTS 'dbss_admin'@'%' IDENTIFIED BY 'DbssAdmin_111111';
CREATE USER IF NOT EXISTS 'dbss_rw'@'%' IDENTIFIED BY 'DbssRw_111111';
CREATE USER IF NOT EXISTS 'dbss_ro'@'%' IDENTIFIED BY 'DbssRo_111111';
CREATE USER IF NOT EXISTS 'dbss_auditor'@'%' IDENTIFIED BY 'DbssAudit_111111';

-- Role membership + default role
GRANT `dbss_role_admin` TO 'dbss_admin'@'%';
GRANT `dbss_role_rw` TO 'dbss_rw'@'%';
GRANT `dbss_role_ro` TO 'dbss_ro'@'%';
GRANT `dbss_role_audit` TO 'dbss_auditor'@'%';

SET DEFAULT ROLE `dbss_role_admin` TO 'dbss_admin'@'%';
SET DEFAULT ROLE `dbss_role_rw` TO 'dbss_rw'@'%';
SET DEFAULT ROLE `dbss_role_ro` TO 'dbss_ro'@'%';
SET DEFAULT ROLE `dbss_role_audit` TO 'dbss_auditor'@'%';

-- NOTE: database name is the default in deploy/.env (MYSQL_DATABASE=video_conference)

-- Admin: full privileges on database
GRANT ALL PRIVILEGES ON `video_conference`.* TO `dbss_role_admin`;

-- RW: CRUD on business tables (sync tables only SELECT for monitoring)
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`users` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`friend_categories` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`friendships` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`friend_requests` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`rooms` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`permission_roles` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`meeting_permissions` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`room_participants` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`messages` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`waiting_room` TO `dbss_role_rw`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `video_conference`.`meeting_recordings` TO `dbss_role_rw`;
-- Read-only stored functions used by query templates
GRANT EXECUTE ON FUNCTION `video_conference`.`fn_room_score` TO `dbss_role_rw`;

GRANT SELECT ON `video_conference`.`change_log` TO `dbss_role_rw`;
GRANT SELECT ON `video_conference`.`audit_log` TO `dbss_role_rw`;
GRANT SELECT ON `video_conference`.`conflicts` TO `dbss_role_rw`;
GRANT SELECT ON `video_conference`.`sync_applied` TO `dbss_role_rw`;
GRANT SELECT ON `video_conference`.`sync_stats_daily` TO `dbss_role_rw`;

-- RO: read-only on database
GRANT SELECT ON `video_conference`.* TO `dbss_role_ro`;
GRANT EXECUTE ON FUNCTION `video_conference`.`fn_room_score` TO `dbss_role_ro`;

-- Auditor: only read sync/audit tables
GRANT SELECT ON `video_conference`.`change_log` TO `dbss_role_audit`;
GRANT SELECT ON `video_conference`.`audit_log` TO `dbss_role_audit`;
GRANT SELECT ON `video_conference`.`conflicts` TO `dbss_role_audit`;
GRANT SELECT ON `video_conference`.`sync_applied` TO `dbss_role_audit`;
GRANT SELECT ON `video_conference`.`sync_stats_daily` TO `dbss_role_audit`;

FLUSH PRIVILEGES;
