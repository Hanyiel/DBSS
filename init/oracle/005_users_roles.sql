-- DBSS database-level users & roles (Oracle XE)
-- Goal: demonstrate DB-layer access control by creating multiple users with different privileges.
-- This script is intended to run during container init (gvenzl/oracle-xe).
--
-- IMPORTANT:
-- - Needs to run as SYS (or a user with CREATE USER / CREATE ROLE privileges).
-- - deploy/.env sets ORACLE_PASSWORD=OracleSysPwd_111111 for SYS/SYSTEM by default.

ALTER SESSION SET CONTAINER = XEPDB1;

-- Create roles
BEGIN
  EXECUTE IMMEDIATE 'CREATE ROLE DBSS_ROLE_ADMIN';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF; -- ORA-01921: role name already exists
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE ROLE DBSS_ROLE_RW';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE ROLE DBSS_ROLE_RO';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE ROLE DBSS_ROLE_AUDIT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

-- Create users
DECLARE
  PROCEDURE ensure_user(p_user VARCHAR2, p_pwd VARCHAR2) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM dba_users WHERE username = UPPER(p_user);
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'CREATE USER ' || p_user || ' IDENTIFIED BY "' || p_pwd || '"';
    END IF;
  END;
BEGIN
  ensure_user('DBSS_ADMIN', 'DbssAdmin_111111');
  ensure_user('DBSS_RW', 'DbssRw_111111');
  ensure_user('DBSS_RO', 'DbssRo_111111');
  ensure_user('DBSS_AUDITOR', 'DbssAudit_111111');
END;
/

-- Basic login privilege
GRANT CREATE SESSION TO DBSS_ADMIN, DBSS_RW, DBSS_RO, DBSS_AUDITOR;

-- Admin gets dictionary access for demo/reporting (optional)
GRANT SELECT_CATALOG_ROLE TO DBSS_ADMIN;

-- Role membership
GRANT DBSS_ROLE_ADMIN TO DBSS_ADMIN;
GRANT DBSS_ROLE_RW TO DBSS_RW;
GRANT DBSS_ROLE_RO TO DBSS_RO;
GRANT DBSS_ROLE_AUDIT TO DBSS_AUDITOR;

-- Grant object privileges on APP_USER schema (default: lhy)
-- If you changed deploy/.env ORACLE_APP_USER, update this schema name accordingly.
DECLARE
  v_schema VARCHAR2(30) := 'LHY';
BEGIN
  -- Business tables: RW
  FOR t IN (
    SELECT table_name
    FROM all_tables
    WHERE owner = v_schema
      AND table_name IN (
        'USERS','FRIEND_CATEGORIES','FRIENDSHIPS','FRIEND_REQUESTS','ROOMS',
        'PERMISSION_ROLES','MEETING_PERMISSIONS','ROOM_PARTICIPANTS','MESSAGES',
        'WAITING_ROOM','MEETING_RECORDINGS'
      )
  ) LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || v_schema || '.' || t.table_name || ' TO DBSS_ROLE_RW';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_schema || '.' || t.table_name || ' TO DBSS_ROLE_RO';
    EXECUTE IMMEDIATE 'GRANT ALL ON ' || v_schema || '.' || t.table_name || ' TO DBSS_ROLE_ADMIN';
  END LOOP;

  -- System/sync tables: audit + read access
  FOR t IN (
    SELECT table_name
    FROM all_tables
    WHERE owner = v_schema
      AND table_name IN ('CHANGE_LOG','AUDIT_LOG','CONFLICTS','SYNC_APPLIED','SYNC_STATS_DAILY')
  ) LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_schema || '.' || t.table_name || ' TO DBSS_ROLE_AUDIT';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_schema || '.' || t.table_name || ' TO DBSS_ROLE_RW';
    EXECUTE IMMEDIATE 'GRANT ALL ON ' || v_schema || '.' || t.table_name || ' TO DBSS_ROLE_ADMIN';
  END LOOP;
END;
/

