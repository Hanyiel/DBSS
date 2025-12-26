-- DBSS database-level users & roles (PostgreSQL)
-- This script is intended to run during container init (docker-entrypoint-initdb.d).
-- It creates 4 login users with different privileges to demonstrate DB-layer access control.

-- Roles (no login)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_role_admin') THEN
    CREATE ROLE dbss_role_admin;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_role_rw') THEN
    CREATE ROLE dbss_role_rw;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_role_ro') THEN
    CREATE ROLE dbss_role_ro;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_role_audit') THEN
    CREATE ROLE dbss_role_audit;
  END IF;
END $$;

-- Users (login roles)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_admin') THEN
    CREATE ROLE dbss_admin LOGIN PASSWORD 'DbssAdmin_111111';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_rw') THEN
    CREATE ROLE dbss_rw LOGIN PASSWORD 'DbssRw_111111';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_ro') THEN
    CREATE ROLE dbss_ro LOGIN PASSWORD 'DbssRo_111111';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbss_auditor') THEN
    CREATE ROLE dbss_auditor LOGIN PASSWORD 'DbssAudit_111111';
  END IF;
END $$;

-- Map users -> roles (default privileges come from the role)
GRANT dbss_role_admin TO dbss_admin;
GRANT dbss_role_rw TO dbss_rw;
GRANT dbss_role_ro TO dbss_ro;
GRANT dbss_role_audit TO dbss_auditor;

ALTER ROLE dbss_admin SET ROLE dbss_role_admin;
ALTER ROLE dbss_rw SET ROLE dbss_role_rw;
ALTER ROLE dbss_ro SET ROLE dbss_role_ro;
ALTER ROLE dbss_auditor SET ROLE dbss_role_audit;

-- Allow connection to database (name is the default in deploy/.env)
GRANT CONNECT ON DATABASE video_conference TO dbss_role_admin, dbss_role_rw, dbss_role_ro, dbss_role_audit;

-- Schema usage
GRANT USAGE ON SCHEMA public TO dbss_role_admin, dbss_role_rw, dbss_role_ro, dbss_role_audit;

-- Admin: full privileges on all tables/sequences in schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dbss_role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dbss_role_admin;

-- RW: CRUD on business tables; and read-only on sync/audit tables for monitoring
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  users, friend_categories, friendships, friend_requests, rooms,
  permission_roles, meeting_permissions, room_participants, messages,
  waiting_room, meeting_recordings
TO dbss_role_rw;

GRANT SELECT ON TABLE change_log, audit_log, conflicts, sync_applied, sync_stats_daily TO dbss_role_rw;

-- Identity columns may require sequence usage for INSERT defaults
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO dbss_role_rw;

-- RO: read-only on all tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dbss_role_ro;

-- Auditor: only read sync/audit tables
GRANT SELECT ON TABLE change_log, audit_log, conflicts, sync_applied, sync_stats_daily TO dbss_role_audit;

-- Default privileges for future objects created by current user
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO dbss_role_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO dbss_role_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO dbss_role_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO dbss_role_rw;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO dbss_role_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO dbss_role_audit;

