-- Change capture: write I/U/D events into change_log
-- Notes:
-- - Assumes all business tables have pk column `id` (true for current schema).

CREATE OR REPLACE FUNCTION log_change_to_change_log()
RETURNS TRIGGER AS $$
DECLARE
  v_op CHAR(1);
  v_pk TEXT;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_op := 'I';
    v_pk := NEW.id::text;
  ELSIF TG_OP = 'UPDATE' THEN
    v_op := 'U';
    v_pk := NEW.id::text;
  ELSE
    v_op := 'D';
    v_pk := OLD.id::text;
  END IF;

  INSERT INTO change_log (source_db, table_name, pk_value, op)
  VALUES ('postgres', TG_TABLE_NAME, v_pk, v_op);

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'users',
    'friend_categories',
    'friendships',
    'friend_requests',
    'rooms',
    'permission_roles',
    'meeting_permissions',
    'room_participants',
    'messages',
    'waiting_room',
    'meeting_recordings'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%s_change ON %I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_%s_change AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION log_change_to_change_log()',
      t,
      t
    );
  END LOOP;
END $$;

