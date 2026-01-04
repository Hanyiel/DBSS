-- Stored function for "meeting activity score" demo
-- Name: fn_room_score(room_id, since_ts)
--
-- This file runs during MySQL container initialization (docker-entrypoint-initdb.d).
-- It is used by the "会议活跃度排行榜" query template (backend/app/api/routes/queries.py).

USE video_conference;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_room_score $$
CREATE FUNCTION fn_room_score(p_room_id INT, p_since_ts DATETIME)
RETURNS BIGINT
NOT DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN
  DECLARE v_participant_cnt BIGINT DEFAULT 0;
  DECLARE v_total_minutes BIGINT DEFAULT 0;

  SELECT
    COUNT(DISTINCT user_id) AS participant_cnt,
    COALESCE(
      SUM(
        GREATEST(
          TIMESTAMPDIFF(
            MINUTE,
            GREATEST(joined_at, p_since_ts),
            LEAST(COALESCE(left_at, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
          ),
          0
        )
      ),
      0
    ) AS total_minutes
  INTO v_participant_cnt, v_total_minutes
  FROM room_participants
  WHERE room_id = p_room_id
    AND joined_at <= CURRENT_TIMESTAMP
    AND COALESCE(left_at, CURRENT_TIMESTAMP) >= p_since_ts;

  RETURN COALESCE(v_participant_cnt, 0) * 10 + COALESCE(v_total_minutes, 0);
END $$

DELIMITER ;

