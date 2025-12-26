-- Demo seed data for "Sync monitoring / report"
-- Target DB: MySQL (video_conference)
--
-- What it seeds:
-- - change_log: a few demo change events (some processed, some unprocessed)
-- - sync_applied: ok/fail per target db for those events (linked via FK to change_log.id)
-- - audit_log: demo audit rows (old_row/new_row)
-- - sync_stats_daily: demo daily metrics (INSERT IGNORE, will not overwrite existing rows)
--
-- Notes:
-- - All demo rows are marked with source_db/changed_by = 'DEMO_SYNC_SEED' so you can delete safely.
-- - You can rerun this file: it deletes its own demo rows first.

USE video_conference;

-- =========================
-- 0) Clean previous demo rows (safe rerun)
-- =========================
DELETE FROM audit_log WHERE changed_by = 'DEMO_SYNC_SEED';
-- Cascades to sync_applied via fk_sync_applied_change (ON DELETE CASCADE)
DELETE FROM change_log WHERE source_db = 'DEMO_SYNC_SEED';

-- =========================
-- 1) Seed change events (change_log)
-- =========================
INSERT INTO change_log (source_db, table_name, pk_value, op, created_at, processed) VALUES
  ('DEMO_SYNC_SEED', 'users', '900101', 'U', NOW() - INTERVAL 8 DAY, 1),
  ('DEMO_SYNC_SEED', 'rooms', '700101', 'I', NOW() - INTERVAL 6 DAY, 1),
  ('DEMO_SYNC_SEED', 'messages', '600101', 'I', NOW() - INTERVAL 6 DAY, 1),
  ('DEMO_SYNC_SEED', 'friend_requests', '800101', 'U', NOW() - INTERVAL 2 DAY, 0),
  ('DEMO_SYNC_SEED', 'meeting_permissions', '500101', 'D', NOW() - INTERVAL 1 DAY, 0);

-- =========================
-- 2) Seed apply results (sync_applied)
--    - ok/fail per target DB; failures carry error_text
-- =========================

-- users: postgres ok, oracle ok
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'postgres', created_at + INTERVAL 2 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='users' AND pk_value='900101';
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'oracle', created_at + INTERVAL 3 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='users' AND pk_value='900101';

-- rooms: postgres ok, oracle fail
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'postgres', created_at + INTERVAL 2 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='rooms' AND pk_value='700101';
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'oracle', created_at + INTERVAL 4 SECOND, 'fail', 'DEMO: ORA-00001 unique constraint violated'
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='rooms' AND pk_value='700101';

-- messages: postgres ok, oracle ok
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'postgres', created_at + INTERVAL 1 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='messages' AND pk_value='600101';
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'oracle', created_at + INTERVAL 2 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='messages' AND pk_value='600101';

-- friend_requests: postgres fail, oracle fail (keep unprocessed to show backlog)
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'postgres', created_at + INTERVAL 8 SECOND, 'fail', 'DEMO: deadlock detected'
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='friend_requests' AND pk_value='800101';
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'oracle', created_at + INTERVAL 10 SECOND, 'fail', 'DEMO: FK missing parent'
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='friend_requests' AND pk_value='800101';

-- meeting_permissions delete: postgres ok, oracle ok (keep unprocessed to show backlog)
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'postgres', created_at + INTERVAL 2 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='meeting_permissions' AND pk_value='500101';
INSERT INTO sync_applied (change_id, target_db, applied_at, status, error_text)
SELECT id, 'oracle', created_at + INTERVAL 3 SECOND, 'ok', NULL
FROM change_log WHERE source_db='DEMO_SYNC_SEED' AND table_name='meeting_permissions' AND pk_value='500101';

-- =========================
-- 3) Seed audit rows (audit_log)
-- =========================
INSERT INTO audit_log (source_db, table_name, pk_value, op, changed_at, changed_by, old_row, new_row) VALUES
  (
    'mysql',
    'users',
    '900101',
    'U',
    NOW() - INTERVAL 8 DAY,
    'DEMO_SYNC_SEED',
    '{"id":900101,"username":"demo_user_a","status":"offline"}',
    '{"id":900101,"username":"demo_user_a","status":"online"}'
  ),
  (
    'mysql',
    'rooms',
    '700101',
    'I',
    NOW() - INTERVAL 6 DAY,
    'DEMO_SYNC_SEED',
    NULL,
    '{"id":700101,"meeting_code":"MTC999001","status":"active"}'
  ),
  (
    'mysql',
    'friend_requests',
    '800101',
    'U',
    NOW() - INTERVAL 2 DAY,
    'DEMO_SYNC_SEED',
    '{"id":800101,"status":"pending"}',
    '{"id":800101,"status":"accepted"}'
  );

-- =========================
-- 4) Seed daily stats (sync_stats_daily)
--    INSERT IGNORE avoids overwriting existing rows.
-- =========================
INSERT IGNORE INTO sync_stats_daily (stat_date, total_events, applied_ok, applied_fail, conflicts, avg_lag_ms) VALUES
  (CURDATE() - INTERVAL 9 DAY,  8, 14,  2, 1, 180),
  (CURDATE() - INTERVAL 8 DAY, 12, 22,  3, 2, 240),
  (CURDATE() - INTERVAL 7 DAY, 10, 18,  1, 0, 120),
  (CURDATE() - INTERVAL 6 DAY, 16, 28,  4, 3, 310),
  (CURDATE() - INTERVAL 5 DAY,  6, 10,  0, 0,  95),
  (CURDATE() - INTERVAL 4 DAY, 14, 24,  2, 1, 160),
  (CURDATE() - INTERVAL 3 DAY, 20, 34,  6, 4, 420),
  (CURDATE() - INTERVAL 2 DAY,  9, 15,  2, 1, 210),
  (CURDATE() - INTERVAL 1 DAY,  7, 12,  1, 0, 130),
  (CURDATE(),               5,  8,  2, 1, 260);

-- =========================
-- 5) Quick checks (optional)
-- =========================
SELECT processed, COUNT(*) AS cnt
FROM change_log
WHERE source_db = 'DEMO_SYNC_SEED'
GROUP BY processed
ORDER BY processed;

SELECT target_db, status, COUNT(*) AS cnt
FROM sync_applied sa
JOIN change_log cl ON cl.id = sa.change_id
WHERE cl.source_db = 'DEMO_SYNC_SEED'
GROUP BY target_db, status
ORDER BY target_db, status;

