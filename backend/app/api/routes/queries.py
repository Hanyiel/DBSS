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
    params: list[_QueryParam] = ()


def _templates() -> list[_QueryTemplate]:
    """
    Query templates for the "Complex query + optimization proof" requirement.

    Most templates are based on `que_plan.docx` (advanced scenarios for the video conference business schema).
    """

    # S1 会议室概览
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

    # S6 会议活跃度排行榜（用于统计/可视化）
    s6_mysql = """
SELECT
  r.id AS room_id,
  r.meeting_code,
  r.name AS room_name,
  fn_room_score(r.id, :since) AS score
FROM rooms r
WHERE r.status = 'active'
ORDER BY score DESC, r.id DESC
LIMIT :limit
""".strip()

    s6_postgres = """
SELECT
  r.id AS room_id,
  r.meeting_code,
  r.name AS room_name,
  COALESCE(p.participant_cnt, 0) AS participant_cnt,
  COALESCE(p.total_minutes, 0) AS total_minutes,
  (COALESCE(p.participant_cnt, 0) * 10 + COALESCE(p.total_minutes, 0)) AS score
FROM rooms r
LEFT JOIN (
  SELECT
    room_id,
    COUNT(DISTINCT user_id) AS participant_cnt,
    SUM(
      GREATEST(
        EXTRACT(EPOCH FROM (LEAST(COALESCE(left_at, now()), now()) - GREATEST(joined_at, :since))) / 60.0,
        0
      )
    )::int AS total_minutes
  FROM room_participants
  WHERE joined_at <= now()
    AND COALESCE(left_at, now()) >= :since
  GROUP BY room_id
) p ON p.room_id = r.id
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
    COALESCE(p.total_minutes, 0) AS total_minutes,
    (COALESCE(p.participant_cnt, 0) * 10 + COALESCE(p.total_minutes, 0)) AS score
  FROM rooms r
  LEFT JOIN (
    SELECT
      room_id,
      COUNT(DISTINCT user_id) AS participant_cnt,
      SUM(
        CASE
          WHEN LEAST(NVL(left_at, SYSTIMESTAMP), SYSTIMESTAMP) > GREATEST(joined_at, :since) THEN
            (CAST(LEAST(NVL(left_at, SYSTIMESTAMP), SYSTIMESTAMP) AS DATE) - CAST(GREATEST(joined_at, :since) AS DATE)) * 24 * 60
          ELSE 0
        END
      ) AS total_minutes
    FROM room_participants
    WHERE joined_at <= SYSTIMESTAMP
      AND NVL(left_at, SYSTIMESTAMP) >= :since
    GROUP BY room_id
  ) p ON p.room_id = r.id
  WHERE r.status = 'active'
  ORDER BY score DESC, r.id DESC
)
WHERE ROWNUM <= :limit
""".strip()

    return [
        _QueryTemplate(
            id="qp_s1_host_recent_meetings",
            title="S1 会议室概览",
            description="主持人查看其创建的会议列表及统计信息：会议状态、参会人数、消息数量、最后消息时间、会议持续时间等。",
            sql_by_db={"mysql": s1_mysql, "postgres": s1_postgres, "oracle": s1_oracle},
            params=[_QueryParam(name="host_id", kind="int", default=1, description="主持人 user_id")],
        ),
        _QueryTemplate(
            id="qp_s4_friend_recommendation",
            title="S2 好友推荐",
            description="为用户推荐“可能认识的好友”：存在共同好友；排除已好友与未处理好友请求；按共同好友数量排序。",
            sql_by_db={"mysql": s4_mysql_pg, "postgres": s4_mysql_pg, "oracle": s4_oracle},
            params=[
                _QueryParam(name="uid", kind="int", default=1, description="当前用户 user_id"),
                _QueryParam(name="min_mutual", kind="int", default=2, description="最小共同好友数阈值"),
            ],
        ),
        _QueryTemplate(
            id="qp_s6_room_hot_ranking",
            title="S3 会议活跃度排行榜",
            description="统计时间窗内各会议的活跃程度：综合参会人数与参会时长计算评分，用于生成活跃度排行榜。",
            sql_by_db={"mysql": s6_mysql, "postgres": s6_postgres, "oracle": s6_oracle},
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
    params: dict[str, Any] = {"limit": req.limit}
    if ":since" in sql:
        params["since"] = since

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
