-- DBSS demo seed data (manual run)
-- NOTE:
-- - This file used to be executed automatically during Docker DB initialization.
-- - It was moved here so a freshly created database starts with NO business data,
--   avoiding startup sync backlogs / constraint-order issues that could create conflicts.
--
-- If you want demo data later, run this script manually on ONE source DB (recommended: MySQL),
-- then let the sync worker replicate (or use the migration feature to copy full tables).

-- 1) users
INSERT INTO users (id, username, email, password, display_name, status)
VALUES
  (1, 'alice', 'alice@example.com', 'pwd', 'Alice', 'online'),
  (2, 'bob', 'bob@example.com', 'pwd', 'Bob', 'online'),
  (3, 'carol', 'carol@example.com', 'pwd', 'Carol', 'offline'),
  (4, 'dave', 'dave@example.com', 'pwd', 'Dave', 'busy'),
  (5, 'erin', 'erin@example.com', 'pwd', 'Erin', 'offline'),
  (6, 'frank', 'frank@example.com', 'pwd', 'Frank', 'online')
ON DUPLICATE KEY UPDATE username = username;

-- 2) rooms
INSERT INTO rooms (
  id, meeting_code, name, description, host_id, password, max_participants,
  is_waiting_room_enabled, room_settings, scheduled_start, scheduled_end, status
)
VALUES
  (101, 'MTC100001', 'Daily Standup', 'Daily sync-up meeting', 1, NULL, 20, TRUE, JSON_OBJECT('recording', TRUE, 'chat', 'enabled'),
   NOW() + INTERVAL 1 HOUR, NOW() + INTERVAL 2 HOUR, 'active'),
  (102, 'MTC100002', 'Project Demo', 'Weekly demo & Q/A', 2, '1234', 50, TRUE, JSON_OBJECT('recording', FALSE, 'chat', 'enabled'),
   NOW() + INTERVAL 3 HOUR, NOW() + INTERVAL 4 HOUR, 'active'),
  (103, 'MTC100003', 'Closed Room', 'Ended meeting', 3, NULL, 10, FALSE, JSON_OBJECT('recording', TRUE, 'chat', 'disabled'),
   NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 7 DAY + INTERVAL 1 HOUR, 'ended')
ON DUPLICATE KEY UPDATE meeting_code = meeting_code;

-- 3) permission_roles (role_name is UNIQUE)
INSERT INTO permission_roles (
  role_name, description,
  can_mute_others, can_assign_cohost, can_kick_participants, can_record_meeting, can_manage_chat, can_end_meeting
)
VALUES
  ('host', 'Host', TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
  ('co-host', 'Co-host', TRUE, FALSE, TRUE, TRUE, TRUE, FALSE),
  ('participant', 'Participant', FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)
ON DUPLICATE KEY UPDATE role_name = role_name;

-- 4) meeting_permissions (use subquery to avoid depending on role_id values)
INSERT INTO meeting_permissions (id, meeting_id, user_id, role_id, assigned_by, expires_at)
VALUES
  (201, 101, 1, (SELECT id FROM permission_roles WHERE role_name='host' LIMIT 1), 1, NULL),
  (202, 101, 2, (SELECT id FROM permission_roles WHERE role_name='co-host' LIMIT 1), 1, NULL),
  (203, 101, 3, (SELECT id FROM permission_roles WHERE role_name='participant' LIMIT 1), 1, NULL),
  (204, 102, 2, (SELECT id FROM permission_roles WHERE role_name='host' LIMIT 1), 2, NULL),
  (205, 102, 1, (SELECT id FROM permission_roles WHERE role_name='participant' LIMIT 1), 2, NULL)
ON DUPLICATE KEY UPDATE id = id;

-- 5) room_participants
INSERT INTO room_participants (id, room_id, user_id, participant_status)
VALUES
  (301, 101, 1, 'active'),
  (302, 101, 2, 'active'),
  (303, 101, 3, 'active'),
  (304, 101, 4, 'inactive'),
  (305, 102, 2, 'active'),
  (306, 102, 1, 'active'),
  (307, 102, 5, 'active'),
  (308, 102, 6, 'left'),
  (309, 103, 3, 'left')
ON DUPLICATE KEY UPDATE id = id;

-- 6) messages (some within recent days to support time-window queries)
INSERT INTO messages (id, room_id, user_id, message_type, content, created_at, parent_message_id)
VALUES
  (1001, 101, 1, 'text', 'Morning! Standup starts in 5 minutes.', NOW() - INTERVAL 2 DAY, NULL),
  (1002, 101, 2, 'text', 'On my way.', NOW() - INTERVAL 2 DAY, 1001),
  (1003, 101, 3, 'text', 'Today I will finish the sync worker module.', NOW() - INTERVAL 2 DAY, NULL),
  (1004, 101, 1, 'text', 'Great. Any blockers?', NOW() - INTERVAL 2 DAY, 1003),
  (1005, 101, 3, 'text', 'Need to verify Oracle triggers.', NOW() - INTERVAL 2 DAY, 1004),
  (1010, 101, 2, 'text', 'Pushed a fix for conflicts UI.', NOW() - INTERVAL 1 DAY, NULL),
  (1011, 101, 4, 'text', 'I can review after lunch.', NOW() - INTERVAL 1 DAY, NULL),
  (1012, 101, 1, 'text', 'OK.', NOW() - INTERVAL 1 DAY, 1011),

  (1101, 102, 2, 'text', 'Demo agenda: sync, conflicts, reports.', NOW() - INTERVAL 3 DAY, NULL),
  (1102, 102, 1, 'text', 'I will present the query optimization part.', NOW() - INTERVAL 3 DAY, 1101),
  (1103, 102, 5, 'text', 'Can we also show audit_log?', NOW() - INTERVAL 3 DAY, 1101),
  (1104, 102, 2, 'text', 'Yes, included.', NOW() - INTERVAL 3 DAY, 1103),
  (1110, 102, 6, 'text', 'Sorry I missed the meeting.', NOW() - INTERVAL 10 HOUR, NULL),
  (1111, 102, 2, 'text', 'No worries.', NOW() - INTERVAL 9 HOUR, 1110),
  (1112, 102, 1, 'text', 'Next demo is tomorrow.', NOW() - INTERVAL 2 HOUR, NULL)
ON DUPLICATE KEY UPDATE id = id;

-- 7) friendships (category_id choose "other" if exists)
INSERT INTO friendships (id, user_id, friend_id, category_id, note)
VALUES
  (401, 1, 2, COALESCE((SELECT id FROM friend_categories WHERE name='other' ORDER BY id ASC LIMIT 1), 1), 'Teammate'),
  (402, 1, 3, COALESCE((SELECT id FROM friend_categories WHERE name='friend' ORDER BY id ASC LIMIT 1), 1), 'Friend'),
  (403, 2, 3, COALESCE((SELECT id FROM friend_categories WHERE name='workmate' ORDER BY id ASC LIMIT 1), 1), 'Workmate'),
  (404, 4, 5, COALESCE((SELECT id FROM friend_categories WHERE name='classmate' ORDER BY id ASC LIMIT 1), 1), 'Classmate')
ON DUPLICATE KEY UPDATE id = id;

-- 8) friend_requests
INSERT INTO friend_requests (id, from_user_id, to_user_id, message, category_id, status)
VALUES
  (501, 5, 4, 'Hi Dave, add me?', COALESCE((SELECT id FROM friend_categories WHERE name='other' ORDER BY id ASC LIMIT 1), 1), 'pending'),
  (502, 6, 1, 'Alice, can you approve me?', COALESCE((SELECT id FROM friend_categories WHERE name='other' ORDER BY id ASC LIMIT 1), 1), 'pending'),
  (503, 3, 5, 'Erin, welcome!', COALESCE((SELECT id FROM friend_categories WHERE name='friend' ORDER BY id ASC LIMIT 1), 1), 'accepted')
ON DUPLICATE KEY UPDATE id = id;

-- 9) waiting_room
INSERT INTO waiting_room (id, room_id, user_id, status)
VALUES
  (601, 102, 6, 'waiting')
ON DUPLICATE KEY UPDATE id = id;

-- 10) meeting_recordings
INSERT INTO meeting_recordings (id, meeting_id, file_path)
VALUES
  (701, 101, '/recordings/room101_demo.mp4'),
  (702, 102, '/recordings/room102_demo.mp4')
ON DUPLICATE KEY UPDATE id = id;

