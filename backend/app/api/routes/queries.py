from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from app.api.deps import require_admin
from app.db.clients import get_db_clients

router = APIRouter()

DbName = Literal["mysql", "postgres", "oracle"]


@dataclass(frozen=True)
class _QueryParam:
    name: str
    kind: Literal["int", "str"]
    default: int | str | None = None
    description: str = ""


@dataclass(frozen=True)
class _QueryTemplate:
    id: str
    title: str
    description: str
    sql_by_db: dict[DbName, str]
    optimization_notes: list[str]
    params: list[_QueryParam] = ()


def _templates() -> list[_QueryTemplate]:
    """
    Query templates for the "Complex query + optimization proof" requirement.

    Most templates are based on `que_plan.docx` (advanced scenarios for the video conference business schema).
    """

    # S1 会议室概览（主持人：最近会议效果）
    s1_mysql = """
SELECT
  r.id,
  r.meeting_code,
  r.name,
  u.username AS host_username,
  r.status,
  r.actual_start,
  r.actual_end,
  TIMESTAMPDIFF(MINUTE, r.actual_start, COALESCE(r.actual_end, NOW())) AS duration_min,
  COALESCE(p.participant_cnt, 0) AS participant_cnt,
  COALESCE(m.msg_cnt, 0) AS msg_cnt,
  lm.last_msg_time
FROM rooms r
JOIN users u ON u.id = r.host_id
LEFT JOIN (
  SELECT room_id, COUNT(*) AS participant_cnt
  FROM room_participants
  GROUP BY room_id
) p ON p.room_id = r.id
LEFT JOIN (
  SELECT room_id, COUNT(*) AS msg_cnt
  FROM messages
  WHERE created_at >= :since
  GROUP BY room_id
) m ON m.room_id = r.id
LEFT JOIN (
  SELECT room_id, MAX(created_at) AS last_msg_time
  FROM messages
  GROUP BY room_id
) lm ON lm.room_id = r.id
WHERE r.host_id = :host_id
  AND r.actual_start >= :since
ORDER BY r.actual_start DESC
LIMIT :limit
""".strip()

    s1_postgres = """
SELECT
  r.id,
  r.meeting_code,
  r.name,
  u.username AS host_username,
  r.status,
  r.actual_start,
  r.actual_end,
  ROUND(EXTRACT(EPOCH FROM (COALESCE(r.actual_end, now()) - r.actual_start)) / 60.0)::int AS duration_min,
  COALESCE(p.participant_cnt, 0) AS participant_cnt,
  COALESCE(m.msg_cnt, 0) AS msg_cnt,
  lm.last_msg_time
FROM rooms r
JOIN users u ON u.id = r.host_id
LEFT JOIN (
  SELECT room_id, COUNT(*) AS participant_cnt
  FROM room_participants
  GROUP BY room_id
) p ON p.room_id = r.id
LEFT JOIN (
  SELECT room_id, COUNT(*) AS msg_cnt
  FROM messages
  WHERE created_at >= :since
  GROUP BY room_id
) m ON m.room_id = r.id
LEFT JOIN (
  SELECT room_id, MAX(created_at) AS last_msg_time
  FROM messages
  GROUP BY room_id
) lm ON lm.room_id = r.id
WHERE r.host_id = :host_id
  AND r.actual_start >= :since
ORDER BY r.actual_start DESC
LIMIT :limit
""".strip()

    s1_oracle = """
SELECT *
FROM (
  SELECT
    r.id,
    r.meeting_code,
    r.name,
    u.username AS host_username,
    r.status,
    r.actual_start,
    r.actual_end,
    ROUND((CAST(COALESCE(r.actual_end, SYSTIMESTAMP) AS DATE) - CAST(r.actual_start AS DATE)) * 24 * 60) AS duration_min,
    COALESCE(p.participant_cnt, 0) AS participant_cnt,
    COALESCE(m.msg_cnt, 0) AS msg_cnt,
    lm.last_msg_time
  FROM rooms r
  JOIN users u ON u.id = r.host_id
  LEFT JOIN (
    SELECT room_id, COUNT(*) AS participant_cnt
    FROM room_participants
    GROUP BY room_id
  ) p ON p.room_id = r.id
  LEFT JOIN (
    SELECT room_id, COUNT(*) AS msg_cnt
    FROM messages
    WHERE created_at >= :since
    GROUP BY room_id
  ) m ON m.room_id = r.id
  LEFT JOIN (
    SELECT room_id, MAX(created_at) AS last_msg_time
    FROM messages
    GROUP BY room_id
  ) lm ON lm.room_id = r.id
  WHERE r.host_id = :host_id
    AND r.actual_start >= :since
  ORDER BY r.actual_start DESC
)
WHERE ROWNUM <= :limit
""".strip()

    # S2 会议实时参会者列表（带角色与窗口活跃度）
    s2_mysql_pg = """
SELECT
  u.id,
  u.username,
  u.display_name,
  rp.participant_status,
  rp.is_muted,
  rp.is_video_enabled,
  rp.is_screen_sharing,
  rp.last_activity,
  pr.role_name,
  COALESCE(msgw.msg_cnt_window, 0) AS msg_cnt_window
FROM room_participants rp
JOIN users u ON u.id = rp.user_id
LEFT JOIN meeting_permissions mp ON mp.meeting_id = rp.room_id AND mp.user_id = rp.user_id
LEFT JOIN permission_roles pr ON pr.id = mp.role_id
LEFT JOIN (
  SELECT room_id, user_id, COUNT(*) AS msg_cnt_window
  FROM messages
  WHERE created_at >= :since
  GROUP BY room_id, user_id
) msgw ON msgw.room_id = rp.room_id AND msgw.user_id = rp.user_id
WHERE rp.room_id = :room_id
  AND rp.participant_status = 'active'
ORDER BY rp.is_screen_sharing DESC, msg_cnt_window DESC, rp.last_activity DESC
LIMIT :limit
""".strip()

    s2_oracle = """
SELECT *
FROM (
  SELECT
    u.id,
    u.username,
    u.display_name,
    rp.participant_status,
    rp.is_muted,
    rp.is_video_enabled,
    rp.is_screen_sharing,
    rp.last_activity,
    pr.role_name,
    COALESCE(msgw.msg_cnt_window, 0) AS msg_cnt_window
  FROM room_participants rp
  JOIN users u ON u.id = rp.user_id
  LEFT JOIN meeting_permissions mp ON mp.meeting_id = rp.room_id AND mp.user_id = rp.user_id
  LEFT JOIN permission_roles pr ON pr.id = mp.role_id
  LEFT JOIN (
    SELECT room_id, user_id, COUNT(*) AS msg_cnt_window
    FROM messages
    WHERE created_at >= :since
    GROUP BY room_id, user_id
  ) msgw ON msgw.room_id = rp.room_id AND msgw.user_id = rp.user_id
  WHERE rp.room_id = :room_id
    AND rp.participant_status = 'active'
  ORDER BY rp.is_screen_sharing DESC, msg_cnt_window DESC, rp.last_activity DESC
)
WHERE ROWNUM <= :limit
""".strip()

    # S3 等待室审批页（带“是否为主持人好友”的标记）
    s3_mysql = """
SELECT
  wr.room_id,
  u.id AS user_id,
  u.username,
  wr.joined_at,
  TIMESTAMPDIFF(SECOND, wr.joined_at, NOW()) AS wait_seconds,
  wr.status,
  wr.admitted_at,
  adm.username AS admitted_by_name,
  EXISTS(
    SELECT 1
    FROM friendships f
    WHERE f.user_id = r.host_id AND f.friend_id = u.id
  ) AS is_friend_of_host
FROM waiting_room wr
JOIN rooms r ON r.id = wr.room_id
JOIN users u ON u.id = wr.user_id
LEFT JOIN users adm ON adm.id = wr.admitted_by
WHERE wr.room_id = :room_id
ORDER BY wr.joined_at ASC
LIMIT :limit
""".strip()

    s3_postgres = """
SELECT
  wr.room_id,
  u.id AS user_id,
  u.username,
  wr.joined_at,
  (EXTRACT(EPOCH FROM (now() - wr.joined_at))::int) AS wait_seconds,
  wr.status,
  wr.admitted_at,
  adm.username AS admitted_by_name,
  EXISTS(
    SELECT 1
    FROM friendships f
    WHERE f.user_id = r.host_id AND f.friend_id = u.id
  ) AS is_friend_of_host
FROM waiting_room wr
JOIN rooms r ON r.id = wr.room_id
JOIN users u ON u.id = wr.user_id
LEFT JOIN users adm ON adm.id = wr.admitted_by
WHERE wr.room_id = :room_id
ORDER BY wr.joined_at ASC
LIMIT :limit
""".strip()

    s3_oracle = """
SELECT *
FROM (
  SELECT
    wr.room_id,
    u.id AS user_id,
    u.username,
    wr.joined_at,
    ROUND((CAST(SYSTIMESTAMP AS DATE) - CAST(wr.joined_at AS DATE)) * 86400) AS wait_seconds,
    wr.status,
    wr.admitted_at,
    adm.username AS admitted_by_name,
    CASE
      WHEN EXISTS(
        SELECT 1
        FROM friendships f
        WHERE f.user_id = r.host_id AND f.friend_id = u.id
      ) THEN 1
      ELSE 0
    END AS is_friend_of_host
  FROM waiting_room wr
  JOIN rooms r ON r.id = wr.room_id
  JOIN users u ON u.id = wr.user_id
  LEFT JOIN users adm ON adm.id = wr.admitted_by
  WHERE wr.room_id = :room_id
  ORDER BY wr.joined_at ASC
)
WHERE ROWNUM <= :limit
""".strip()

    # S4 好友推荐（共同好友最多，排除已好友与已发请求）
    s4_mysql_pg = """
SELECT
  f2.friend_id AS candidate_id,
  COUNT(*) AS mutual_cnt
FROM friendships f1
JOIN friendships f2 ON f1.friend_id = f2.user_id
WHERE f1.user_id = :uid
  AND f2.friend_id <> :uid
  AND NOT EXISTS (
    SELECT 1 FROM friendships fx
    WHERE fx.user_id = :uid AND fx.friend_id = f2.friend_id
  )
  AND NOT EXISTS (
    SELECT 1 FROM friend_requests fr
    WHERE fr.from_user_id = :uid AND fr.to_user_id = f2.friend_id
      AND fr.status IN ('pending','accepted')
  )
GROUP BY f2.friend_id
HAVING COUNT(*) >= :min_mutual
ORDER BY mutual_cnt DESC, candidate_id ASC
LIMIT :limit
""".strip()

    s4_oracle = """
SELECT *
FROM (
  SELECT
    f2.friend_id AS candidate_id,
    COUNT(*) AS mutual_cnt
  FROM friendships f1
  JOIN friendships f2 ON f1.friend_id = f2.user_id
  WHERE f1.user_id = :uid
    AND f2.friend_id <> :uid
    AND NOT EXISTS (
      SELECT 1 FROM friendships fx
      WHERE fx.user_id = :uid AND fx.friend_id = f2.friend_id
    )
    AND NOT EXISTS (
      SELECT 1 FROM friend_requests fr
      WHERE fr.from_user_id = :uid AND fr.to_user_id = f2.friend_id
        AND fr.status IN ('pending','accepted')
    )
  GROUP BY f2.friend_id
  HAVING COUNT(*) >= :min_mutual
  ORDER BY mutual_cnt DESC, candidate_id ASC
)
WHERE ROWNUM <= :limit
""".strip()

    # S5 每个会议的最后一条消息（会话列表）
    s5_mysql_pg = """
SELECT m.*
FROM messages m
JOIN (
  SELECT room_id, MAX(created_at) AS max_time
  FROM messages
  GROUP BY room_id
) t ON t.room_id = m.room_id AND t.max_time = m.created_at
ORDER BY m.created_at DESC
LIMIT :limit
""".strip()

    s5_oracle = """
SELECT *
FROM (
  SELECT m.*
  FROM messages m
  JOIN (
    SELECT room_id, MAX(created_at) AS max_time
    FROM messages
    GROUP BY room_id
  ) t ON t.room_id = m.room_id AND t.max_time = m.created_at
  ORDER BY m.created_at DESC
)
WHERE ROWNUM <= :limit
""".strip()

    # S6 会议活跃度排行榜（用于统计/可视化）
    s6_mysql_pg = """
SELECT
  r.id AS room_id,
  r.meeting_code,
  r.name AS room_name,
  COALESCE(p.participant_cnt, 0) AS participant_cnt,
  COALESCE(m.msg_cnt, 0) AS msg_cnt,
  (COALESCE(m.msg_cnt, 0) * 2 + COALESCE(p.participant_cnt, 0)) AS score
FROM rooms r
LEFT JOIN (
  SELECT room_id, COUNT(*) AS participant_cnt
  FROM room_participants
  WHERE participant_status = 'active'
  GROUP BY room_id
) p ON p.room_id = r.id
LEFT JOIN (
  SELECT room_id, COUNT(*) AS msg_cnt
  FROM messages
  WHERE created_at >= :since
  GROUP BY room_id
) m ON m.room_id = r.id
WHERE r.status = 'active'
ORDER BY score DESC, r.id DESC
LIMIT :limit
""".strip()

    s6_oracle = """
SELECT *
FROM (
  SELECT
    r.id AS room_id,
    r.meeting_code,
    r.name AS room_name,
    COALESCE(p.participant_cnt, 0) AS participant_cnt,
    COALESCE(m.msg_cnt, 0) AS msg_cnt,
    (COALESCE(m.msg_cnt, 0) * 2 + COALESCE(p.participant_cnt, 0)) AS score
  FROM rooms r
  LEFT JOIN (
    SELECT room_id, COUNT(*) AS participant_cnt
    FROM room_participants
    WHERE participant_status = 'active'
    GROUP BY room_id
  ) p ON p.room_id = r.id
  LEFT JOIN (
    SELECT room_id, COUNT(*) AS msg_cnt
    FROM messages
    WHERE created_at >= :since
    GROUP BY room_id
  ) m ON m.room_id = r.id
  WHERE r.status = 'active'
  ORDER BY score DESC, r.id DESC
)
WHERE ROWNUM <= :limit
""".strip()

    # S7 权限审计 / 异常权限排查
    s7_mysql_pg = """
SELECT 'missing_permission' AS issue, rp.room_id, rp.user_id
FROM room_participants rp
WHERE rp.room_id = :room_id
  AND rp.participant_status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM meeting_permissions mp
    WHERE mp.meeting_id = rp.room_id AND mp.user_id = rp.user_id
  )
UNION ALL
SELECT 'missing_participant' AS issue, mp.meeting_id AS room_id, mp.user_id
FROM meeting_permissions mp
WHERE mp.meeting_id = :room_id
  AND NOT EXISTS (
    SELECT 1 FROM room_participants rp
    WHERE rp.room_id = mp.meeting_id AND rp.user_id = mp.user_id
  )
LIMIT :limit
""".strip()

    s7_oracle = """
SELECT *
FROM (
  SELECT 'missing_permission' AS issue, rp.room_id, rp.user_id
  FROM room_participants rp
  WHERE rp.room_id = :room_id
    AND rp.participant_status = 'active'
    AND NOT EXISTS (
      SELECT 1 FROM meeting_permissions mp
      WHERE mp.meeting_id = rp.room_id AND mp.user_id = rp.user_id
    )
  UNION ALL
  SELECT 'missing_participant' AS issue, mp.meeting_id AS room_id, mp.user_id
  FROM meeting_permissions mp
  WHERE mp.meeting_id = :room_id
    AND NOT EXISTS (
      SELECT 1 FROM room_participants rp
      WHERE rp.room_id = mp.meeting_id AND rp.user_id = mp.user_id
    )
)
WHERE ROWNUM <= :limit
""".strip()

    # S8 参会时长 TopN（按时间窗）
    s8_mysql = """
SELECT
  rp.user_id,
  u.username,
  SUM(TIMESTAMPDIFF(MINUTE, rp.joined_at, COALESCE(rp.left_at, NOW()))) AS total_minutes
FROM room_participants rp
JOIN users u ON u.id = rp.user_id
WHERE rp.joined_at >= :since
GROUP BY rp.user_id, u.username
ORDER BY total_minutes DESC
LIMIT :limit
""".strip()

    s8_postgres = """
SELECT
  rp.user_id,
  u.username,
  SUM(ROUND(EXTRACT(EPOCH FROM (COALESCE(rp.left_at, now()) - rp.joined_at)) / 60.0))::int AS total_minutes
FROM room_participants rp
JOIN users u ON u.id = rp.user_id
WHERE rp.joined_at >= :since
GROUP BY rp.user_id, u.username
ORDER BY total_minutes DESC
LIMIT :limit
""".strip()

    s8_oracle = """
SELECT *
FROM (
  SELECT
    rp.user_id,
    u.username,
    SUM(ROUND((CAST(COALESCE(rp.left_at, SYSTIMESTAMP) AS DATE) - CAST(rp.joined_at AS DATE)) * 24 * 60)) AS total_minutes
  FROM room_participants rp
  JOIN users u ON u.id = rp.user_id
  WHERE rp.joined_at >= :since
  GROUP BY rp.user_id, u.username
  ORDER BY total_minutes DESC
)
WHERE ROWNUM <= :limit
""".strip()

    # S9 录制审计（录制次数与最近录制时间）
    s9_mysql_pg = """
SELECT
  r.meeting_code,
  r.name,
  COUNT(mr.id) AS recording_cnt,
  MAX(mr.created_at) AS last_recorded_at
FROM meeting_recordings mr
JOIN rooms r ON r.id = mr.meeting_id
GROUP BY r.meeting_code, r.name
ORDER BY last_recorded_at DESC
LIMIT :limit
""".strip()

    s9_oracle = """
SELECT *
FROM (
  SELECT
    r.meeting_code,
    r.name,
    COUNT(mr.id) AS recording_cnt,
    MAX(mr.created_at) AS last_recorded_at
  FROM meeting_recordings mr
  JOIN rooms r ON r.id = mr.meeting_id
  GROUP BY r.meeting_code, r.name
  ORDER BY last_recorded_at DESC
)
WHERE ROWNUM <= :limit
""".strip()

    return [
        _QueryTemplate(
            id="qp_s1_host_recent_meetings",
            title="S1 会议室概览（主持人：最近会议效果）",
            description="主持人查看近时间窗内自己创建的会议列表：参会人数、消息数、最后消息时间、会议时长等。",
            sql_by_db={"mysql": s1_mysql, "postgres": s1_postgres, "oracle": s1_oracle},
            optimization_notes=[
                "建议索引：rooms(host_id, actual_start), messages(room_id, created_at), room_participants(room_id)",
                "展示方式：对该 SQL 做 EXPLAIN（优化前后对比），截图执行计划与耗时。",
            ],
            params=[_QueryParam(name="host_id", kind="int", default=1, description="主持人 user_id")],
        ),
        _QueryTemplate(
            id="qp_s2_live_participants",
            title="S2 实时参会者列表（带角色与窗口活跃度）",
            description="会议在线成员列表：角色、音视频状态，并统计时间窗内消息数作为“活跃度”。",
            sql_by_db={"mysql": s2_mysql_pg, "postgres": s2_mysql_pg, "oracle": s2_oracle},
            optimization_notes=[
                "建议索引：room_participants(room_id, participant_status, last_activity), meeting_permissions(meeting_id, user_id), messages(room_id, created_at, user_id)",
                "可通过调整时间窗口（since_minutes）演示性能差异。",
            ],
            params=[_QueryParam(name="room_id", kind="int", default=1, description="会议 room_id")],
        ),
        _QueryTemplate(
            id="qp_s3_waiting_room",
            title="S3 等待室审批（标记是否为主持人好友）",
            description="等待室列表按进入时间排序，并用 EXISTS 标记该用户是否为主持人的好友。",
            sql_by_db={"mysql": s3_mysql, "postgres": s3_postgres, "oracle": s3_oracle},
            optimization_notes=["建议索引：waiting_room(room_id, status, joined_at), friendships(user_id, friend_id)"],
            params=[_QueryParam(name="room_id", kind="int", default=1, description="会议 room_id")],
        ),
        _QueryTemplate(
            id="qp_s4_friend_recommendation",
            title="S4 好友推荐（共同好友最多）",
            description="推荐“可能认识的人”：共同好友越多排名越靠前，并过滤已好友与已发请求。",
            sql_by_db={"mysql": s4_mysql_pg, "postgres": s4_mysql_pg, "oracle": s4_oracle},
            optimization_notes=[
                "建议索引：friendships(user_id, friend_id) + friendships(friend_id, user_id)；friend_requests(from_user_id, to_user_id, status)",
                "适合做优化前后对比：自连接与 NOT EXISTS 在无索引时会很慢。",
            ],
            params=[
                _QueryParam(name="uid", kind="int", default=1, description="当前用户 user_id"),
                _QueryParam(name="min_mutual", kind="int", default=2, description="最小共同好友数阈值"),
            ],
        ),
        _QueryTemplate(
            id="qp_s5_last_message_per_room",
            title="S5 每个会议的最后一条消息（会话列表）",
            description="会话列表展示每个会议室的最后发言时间与内容（子查询取 MAX(created_at) 再 JOIN 回 messages）。",
            sql_by_db={"mysql": s5_mysql_pg, "postgres": s5_mysql_pg, "oracle": s5_oracle},
            optimization_notes=["建议索引：messages(room_id, created_at)"],
        ),
        _QueryTemplate(
            id="qp_s6_room_hot_ranking",
            title="S6 会议活跃度排行榜（统计/可视化）",
            description="管理端统计“最热会议 TOPN”，可用于柱状图/折线图展示（score=msg_cnt*2+participant_cnt）。",
            sql_by_db={"mysql": s6_mysql_pg, "postgres": s6_mysql_pg, "oracle": s6_oracle},
            optimization_notes=[
                "建议索引：messages(room_id, created_at), room_participants(room_id, participant_status)",
                "数据量大时可做预聚合：将结果写入日报表（类似 sync_stats_daily 思路）。",
            ],
        ),
        _QueryTemplate(
            id="qp_s7_permission_audit",
            title="S7 权限审计（参会状态与权限不一致）",
            description="排查异常：参会(active)但权限表缺失；或权限表有记录但参会记录不存在。",
            sql_by_db={"mysql": s7_mysql_pg, "postgres": s7_mysql_pg, "oracle": s7_oracle},
            optimization_notes=[
                "建议索引：meeting_permissions(meeting_id, user_id), room_participants(room_id, user_id, participant_status)"
            ],
            params=[_QueryParam(name="room_id", kind="int", default=1, description="会议 room_id")],
        ),
        _QueryTemplate(
            id="qp_s8_attendance_duration_top",
            title="S8 参会时长 TopN（按时间窗）",
            description="统计用户在时间窗内的总参会时长（分钟），用于考勤/活跃用户榜。",
            sql_by_db={"mysql": s8_mysql, "postgres": s8_postgres, "oracle": s8_oracle},
            optimization_notes=["建议索引：room_participants(user_id, joined_at) 或 room_participants(joined_at)"],
        ),
        _QueryTemplate(
            id="qp_s9_recording_audit",
            title="S9 录制审计（录制次数与最近录制时间）",
            description="审计会议录制情况：每个会议的录制次数与最近录制时间。",
            sql_by_db={"mysql": s9_mysql_pg, "postgres": s9_mysql_pg, "oracle": s9_oracle},
            optimization_notes=["建议索引：meeting_recordings(meeting_id, created_at)"],
        ),
    ]


class QueryParamOut(BaseModel):
    name: str
    kind: Literal["int", "str"]
    default: int | str | None = None
    description: str = ""


class QueryTemplateOut(BaseModel):
    id: str
    title: str
    description: str
    sql_by_db: dict[str, str]
    optimization_notes: list[str]
    params: list[QueryParamOut]


@router.get("/templates")
def list_query_templates(_admin: dict = Depends(require_admin)):
    return {
        "templates": [
            QueryTemplateOut(
                id=t.id,
                title=t.title,
                description=t.description,
                sql_by_db=t.sql_by_db,
                optimization_notes=t.optimization_notes,
                params=[QueryParamOut(name=p.name, kind=p.kind, default=p.default, description=p.description) for p in (t.params or [])],
            ).model_dump()
            for t in _templates()
        ]
    }


class RunQueryRequest(BaseModel):
    db: DbName
    template_id: str
    since_minutes: int = Field(default=60 * 24 * 7, ge=1, le=60 * 24 * 365)
    limit: int = Field(default=20, ge=1, le=200)
    with_explain: bool = True
    params: dict[str, Any] = Field(default_factory=dict, description="extra template params (e.g. room_id/uid/host_id)")


@router.post("/run")
def run_query(req: RunQueryRequest, _admin: dict = Depends(require_admin)):
    tmpl = next((t for t in _templates() if t.id == req.template_id), None)
    if not tmpl:
        raise HTTPException(status_code=404, detail="template not found")

    clients = get_db_clients()
    client = clients[req.db]

    sql = tmpl.sql_by_db[req.db]
    since = datetime.now() - timedelta(minutes=req.since_minutes)
    params: dict[str, Any] = {"since": since, "limit": req.limit}

    allowed = {p.name for p in (tmpl.params or [])}
    unknown = sorted(set(req.params.keys()) - allowed)
    if unknown:
        raise HTTPException(status_code=400, detail=f"unknown params for template {tmpl.id}: {unknown}")

    for p in (tmpl.params or []):
        raw = req.params.get(p.name, p.default)
        if raw is None:
            raise HTTPException(status_code=400, detail=f"missing required param: {p.name}")
        if p.kind == "int":
            try:
                params[p.name] = int(raw)
            except Exception as exc:  # noqa: BLE001
                raise HTTPException(status_code=400, detail=f"param {p.name} must be int") from exc
        else:
            params[p.name] = str(raw)

    out: dict[str, Any] = {
        "db": req.db,
        "template_id": tmpl.id,
        "title": tmpl.title,
        "sql": sql,
        "params": {k: (v.isoformat(sep=" ", timespec="seconds") if hasattr(v, "isoformat") else v) for k, v in params.items()},
        "optimization_notes": tmpl.optimization_notes,
    }

    try:
        with client.engine.connect() as conn:
            rows = conn.execute(text(sql), params).mappings().all()
            out["rows"] = [dict(r) for r in rows]
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail=f"{req.db} unavailable: {exc}") from exc

    if req.with_explain:
        out["explain"] = _run_explain(req.db, client.engine, sql, params)

    return out


def _run_explain(db: DbName, engine, sql: str, params: dict[str, Any]) -> dict[str, Any]:
    try:
        with engine.connect() as conn:
            if db == "mysql":
                plan_rows = conn.execute(text(f"EXPLAIN {sql}"), params).mappings().all()
                return {"ok": True, "rows": [dict(r) for r in plan_rows]}
            if db == "postgres":
                plan_rows = conn.execute(text(f"EXPLAIN {sql}"), params).all()
                return {"ok": True, "lines": [str(r[0]) for r in plan_rows]}
            if db == "oracle":
                conn.execute(text(f"EXPLAIN PLAN FOR {sql}"), params)
                lines = conn.execute(text("SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY())")).all()
                return {"ok": True, "lines": [str(r[0]) for r in lines]}
    except Exception as exc:  # noqa: BLE001
        return {"ok": False, "error": str(exc)}
    return {"ok": False, "error": "unsupported db"}

