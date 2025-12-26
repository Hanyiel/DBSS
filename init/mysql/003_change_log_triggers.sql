-- Change capture: write I/U/D events into change_log
-- Notes:
-- - MySQL triggers can't combine multiple events, so each table has 3 triggers.
-- - For initial scaffold we only record pk/op (worker can read current row for I/U).

DELIMITER $$

-- users
DROP TRIGGER IF EXISTS trg_users_change_ai $$
CREATE TRIGGER trg_users_change_ai AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'users', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'users', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_users_change_au $$
CREATE TRIGGER trg_users_change_au AFTER UPDATE ON users
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'users', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'users', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_users_change_ad $$
CREATE TRIGGER trg_users_change_ad AFTER DELETE ON users
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'users', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'users', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- friend_categories
DROP TRIGGER IF EXISTS trg_friend_categories_change_ai $$
CREATE TRIGGER trg_friend_categories_change_ai AFTER INSERT ON friend_categories
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_categories', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_categories', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_friend_categories_change_au $$
CREATE TRIGGER trg_friend_categories_change_au AFTER UPDATE ON friend_categories
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_categories', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_categories', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_friend_categories_change_ad $$
CREATE TRIGGER trg_friend_categories_change_ad AFTER DELETE ON friend_categories
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_categories', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_categories', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- friendships
DROP TRIGGER IF EXISTS trg_friendships_change_ai $$
CREATE TRIGGER trg_friendships_change_ai AFTER INSERT ON friendships
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friendships', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friendships', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_friendships_change_au $$
CREATE TRIGGER trg_friendships_change_au AFTER UPDATE ON friendships
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friendships', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friendships', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_friendships_change_ad $$
CREATE TRIGGER trg_friendships_change_ad AFTER DELETE ON friendships
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friendships', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friendships', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- friend_requests
DROP TRIGGER IF EXISTS trg_friend_requests_change_ai $$
CREATE TRIGGER trg_friend_requests_change_ai AFTER INSERT ON friend_requests
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_requests', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_requests', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_friend_requests_change_au $$
CREATE TRIGGER trg_friend_requests_change_au AFTER UPDATE ON friend_requests
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_requests', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_requests', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_friend_requests_change_ad $$
CREATE TRIGGER trg_friend_requests_change_ad AFTER DELETE ON friend_requests
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'friend_requests', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'friend_requests', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- rooms
DROP TRIGGER IF EXISTS trg_rooms_change_ai $$
CREATE TRIGGER trg_rooms_change_ai AFTER INSERT ON rooms
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'rooms', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'rooms', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_rooms_change_au $$
CREATE TRIGGER trg_rooms_change_au AFTER UPDATE ON rooms
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'rooms', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'rooms', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_rooms_change_ad $$
CREATE TRIGGER trg_rooms_change_ad AFTER DELETE ON rooms
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'rooms', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'rooms', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- permission_roles
DROP TRIGGER IF EXISTS trg_permission_roles_change_ai $$
CREATE TRIGGER trg_permission_roles_change_ai AFTER INSERT ON permission_roles
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'permission_roles', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'permission_roles', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_permission_roles_change_au $$
CREATE TRIGGER trg_permission_roles_change_au AFTER UPDATE ON permission_roles
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'permission_roles', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'permission_roles', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_permission_roles_change_ad $$
CREATE TRIGGER trg_permission_roles_change_ad AFTER DELETE ON permission_roles
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'permission_roles', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'permission_roles', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- meeting_permissions
DROP TRIGGER IF EXISTS trg_meeting_permissions_change_ai $$
CREATE TRIGGER trg_meeting_permissions_change_ai AFTER INSERT ON meeting_permissions
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_permissions', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_permissions', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_meeting_permissions_change_au $$
CREATE TRIGGER trg_meeting_permissions_change_au AFTER UPDATE ON meeting_permissions
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_permissions', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_permissions', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_meeting_permissions_change_ad $$
CREATE TRIGGER trg_meeting_permissions_change_ad AFTER DELETE ON meeting_permissions
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_permissions', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_permissions', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- room_participants
DROP TRIGGER IF EXISTS trg_room_participants_change_ai $$
CREATE TRIGGER trg_room_participants_change_ai AFTER INSERT ON room_participants
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'room_participants', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'room_participants', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_room_participants_change_au $$
CREATE TRIGGER trg_room_participants_change_au AFTER UPDATE ON room_participants
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'room_participants', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'room_participants', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_room_participants_change_ad $$
CREATE TRIGGER trg_room_participants_change_ad AFTER DELETE ON room_participants
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'room_participants', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'room_participants', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- messages
DROP TRIGGER IF EXISTS trg_messages_change_ai $$
CREATE TRIGGER trg_messages_change_ai AFTER INSERT ON messages
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'messages', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'messages', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_messages_change_au $$
CREATE TRIGGER trg_messages_change_au AFTER UPDATE ON messages
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'messages', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'messages', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_messages_change_ad $$
CREATE TRIGGER trg_messages_change_ad AFTER DELETE ON messages
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'messages', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'messages', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- waiting_room
DROP TRIGGER IF EXISTS trg_waiting_room_change_ai $$
CREATE TRIGGER trg_waiting_room_change_ai AFTER INSERT ON waiting_room
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'waiting_room', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'waiting_room', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_waiting_room_change_au $$
CREATE TRIGGER trg_waiting_room_change_au AFTER UPDATE ON waiting_room
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'waiting_room', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'waiting_room', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_waiting_room_change_ad $$
CREATE TRIGGER trg_waiting_room_change_ad AFTER DELETE ON waiting_room
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'waiting_room', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'waiting_room', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

-- meeting_recordings
DROP TRIGGER IF EXISTS trg_meeting_recordings_change_ai $$
CREATE TRIGGER trg_meeting_recordings_change_ai AFTER INSERT ON meeting_recordings
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_recordings', NEW.id, 'I');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_recordings', NEW.id, 'I', USER(), NULL, JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_meeting_recordings_change_au $$
CREATE TRIGGER trg_meeting_recordings_change_au AFTER UPDATE ON meeting_recordings
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_recordings', NEW.id, 'U');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_recordings', NEW.id, 'U', USER(), JSON_OBJECT('id', OLD.id), JSON_OBJECT('id', NEW.id));
END $$

DROP TRIGGER IF EXISTS trg_meeting_recordings_change_ad $$
CREATE TRIGGER trg_meeting_recordings_change_ad AFTER DELETE ON meeting_recordings
FOR EACH ROW
BEGIN
  INSERT INTO change_log (source_db, table_name, pk_value, op) VALUES ('mysql', 'meeting_recordings', OLD.id, 'D');
  INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_by, old_row, new_row)
  VALUES ('mysql', 'meeting_recordings', OLD.id, 'D', USER(), JSON_OBJECT('id', OLD.id), NULL);
END $$

DELIMITER ;
