-- Change capture: write I/U/D events into change_log
-- Notes:
-- - Assumes all business tables have pk column `id` (true for current schema).

ALTER SESSION SET CONTAINER = XEPDB1;
CONNECT lhy/SyncPwd_111111@//localhost:1521/XEPDB1;
-- 由 APP_USER 执行（deploy/.env: ORACLE_APP_USER），无需切换 CURRENT_SCHEMA

CREATE OR REPLACE TRIGGER trg_users_change
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'users', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'users',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_friend_categories_change
AFTER INSERT OR UPDATE OR DELETE ON friend_categories
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'friend_categories', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'friend_categories',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_friendships_change
AFTER INSERT OR UPDATE OR DELETE ON friendships
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'friendships', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'friendships',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_friend_requests_change
AFTER INSERT OR UPDATE OR DELETE ON friend_requests
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'friend_requests', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'friend_requests',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_rooms_change
AFTER INSERT OR UPDATE OR DELETE ON rooms
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'rooms', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'rooms',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_permission_roles_change
AFTER INSERT OR UPDATE OR DELETE ON permission_roles
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'permission_roles', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'permission_roles',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_meeting_permissions_change
AFTER INSERT OR UPDATE OR DELETE ON meeting_permissions
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'meeting_permissions', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'meeting_permissions',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_room_participants_change
AFTER INSERT OR UPDATE OR DELETE ON room_participants
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'room_participants', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'room_participants',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_messages_change
AFTER INSERT OR UPDATE OR DELETE ON messages
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'messages', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'messages',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_waiting_room_change
AFTER INSERT OR UPDATE OR DELETE ON waiting_room
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'waiting_room', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'waiting_room',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/

CREATE OR REPLACE TRIGGER trg_meeting_recordings_change
AFTER INSERT OR UPDATE OR DELETE ON meeting_recordings
FOR EACH ROW
DECLARE
  v_op CHAR(1);
  v_pk VARCHAR2(128);
BEGIN
  IF INSERTING THEN
    v_op := 'I'; v_pk := TO_CHAR(:NEW.id);
  ELSIF UPDATING THEN
    v_op := 'U'; v_pk := TO_CHAR(:NEW.id);
  ELSE
    v_op := 'D'; v_pk := TO_CHAR(:OLD.id);
  END IF;
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('oracle', 'meeting_recordings', v_pk, v_op);
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES (
    'oracle',
    'meeting_recordings',
    v_pk,
    v_op,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE WHEN v_op = 'I' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END,
    CASE WHEN v_op = 'D' THEN NULL ELSE JSON_OBJECT('id' VALUE v_pk RETURNING CLOB) END
  );
END;
/
