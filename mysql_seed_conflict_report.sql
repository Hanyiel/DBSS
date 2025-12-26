-- Demo seed data for "Conflict Report"
-- Target DB: MySQL (video_conference)
--
-- Usage (run in MySQL client):
--   USE video_conference;
--   SOURCE /path/to/mysql_seed_conflict_report.sql;
--
-- Notes:
-- - This only inserts rows into the sync system table `conflicts` (no business tables).
-- - All rows are marked with resolution_note = 'DEMO_REPORT_SEED' so you can delete them easily.
-- - `reason` is VARCHAR(255) in MySQL, keep it short.

USE video_conference;

-- Clean previous demo rows (safe rerun)
DELETE FROM conflicts WHERE resolution_note = 'DEMO_REPORT_SEED';

-- Create a visible trend across the last 10 days.
-- Mix of open/resolved, different tables, and different source/resolution DBs.
INSERT INTO conflicts (
  table_name,
  pk_value,
  detected_at,
  status,
  reason,
  source_db,
  resolution_db,
  resolution_method,
  resolution_note,
  resolved_by,
  resolved_at
) VALUES
  -- Day -9
  ('users', '900001', NOW() - INTERVAL 9 DAY, 'resolved', 'updated_at_conflict', 'mysql', 'postgres', 'winner_db', 'DEMO_REPORT_SEED', 'admin', NOW() - INTERVAL 8 DAY),
  ('friend_requests', '800001', NOW() - INTERVAL 9 DAY, 'open', 'fk_missing', 'mysql', 'oracle', NULL, 'DEMO_REPORT_SEED', NULL, NULL),

  -- Day -8
  ('rooms', '700001', NOW() - INTERVAL 8 DAY, 'resolved', 'unique_violation', 'mysql', 'oracle', 'auto_latest', 'DEMO_REPORT_SEED', 'admin', NOW() - INTERVAL 7 DAY),

  -- Day -7
  ('messages', '600001', NOW() - INTERVAL 7 DAY, 'open', 'target_db_unreachable', 'mysql', 'oracle', NULL, 'DEMO_REPORT_SEED', NULL, NULL),
  ('meeting_permissions', '500001', NOW() - INTERVAL 7 DAY, 'resolved', 'fk_missing', 'mysql', 'oracle', 'retry_keep_source', 'DEMO_REPORT_SEED', 'admin', NOW() - INTERVAL 6 DAY),

  -- Day -6
  ('friendships', '400001', NOW() - INTERVAL 6 DAY, 'open', 'updated_at_conflict', 'mysql', 'postgres', NULL, 'DEMO_REPORT_SEED', NULL, NULL),
  ('users', '900002', NOW() - INTERVAL 6 DAY, 'resolved', 'unique_violation', 'mysql', 'postgres', 'sync_from_db', 'DEMO_REPORT_SEED', 'admin', NOW() - INTERVAL 5 DAY),

  -- Day -5
  ('rooms', '700002', NOW() - INTERVAL 5 DAY, 'open', 'updated_at_conflict', 'mysql', 'oracle', NULL, 'DEMO_REPORT_SEED', NULL, NULL),

  -- Day -3
  ('friend_categories', '300001', NOW() - INTERVAL 3 DAY, 'resolved', 'manual_override', 'mysql', 'postgres', 'winner_db', 'DEMO_REPORT_SEED', 'admin', NOW() - INTERVAL 2 DAY),
  ('room_participants', '200001', NOW() - INTERVAL 3 DAY, 'open', 'fk_missing', 'mysql', 'oracle', NULL, 'DEMO_REPORT_SEED', NULL, NULL),

  -- Day -1
  ('audit_log', '100001', NOW() - INTERVAL 1 DAY, 'resolved', 'payload_too_large', 'mysql', 'postgres', 'mark_resolved', 'DEMO_REPORT_SEED', 'admin', NOW() - INTERVAL 1 DAY),

  -- Today
  ('users', '900003', NOW(), 'open', 'updated_at_conflict', 'mysql', 'oracle', NULL, 'DEMO_REPORT_SEED', NULL, NULL);

-- Quick check (optional)
SELECT
  status,
  COUNT(*) AS cnt
FROM conflicts
WHERE resolution_note = 'DEMO_REPORT_SEED'
GROUP BY status
ORDER BY status;
