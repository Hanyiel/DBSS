import { useEffect, useMemo, useState } from "react";
import { useLocation } from "react-router-dom";

import { createDemoConflict, fetchConflictDetail, fetchConflicts, resolveConflict } from "../api/client";

type Status = "open" | "resolved" | "all";
type DbName = "mysql" | "postgres" | "oracle";
type SortMode = "newest" | "oldest";

function asString(v: unknown) {
  if (v === null || v === undefined) return "";
  return String(v);
}

function classifyConflict(reason: unknown) {
  const r = asString(reason).toLowerCase();
  if (r.includes("updated_at conflict")) return { label: "并发更新冲突", color: "#7c3aed" };
  if (r.includes("duplicate") || r.includes("unique") || r.includes("ora-00001")) return { label: "唯一键冲突", color: "#b42318" };
  if (r.includes("foreign key") || r.includes("ora-02291") || r.includes("ora-02292")) return { label: "外键冲突", color: "#b45309" };
  if (r.includes("table not found") || r.includes("no such table")) return { label: "缺表/结构不一致", color: "#b42318" };
  return { label: "同步失败", color: "#4b5563" };
}

function formatCell(v: unknown) {
  if (v === null || v === undefined) return "";
  if (typeof v === "string" || typeof v === "number" || typeof v === "boolean") return String(v);
  return JSON.stringify(v);
}

function normalizeRowCandidate(v: unknown): { row: Record<string, unknown> | null; error?: string } {
  if (!v) return { row: null };
  if (typeof v !== "object") return { row: null, error: String(v) };
  const obj = v as Record<string, unknown>;
  const err = obj["_error"];
  if (typeof err === "string" && err) return { row: null, error: err };
  return { row: obj };
}

function safeOp(v: unknown): "I" | "U" | "D" {
  const op = asString(v).toUpperCase();
  if (op === "I" || op === "U" || op === "D") return op;
  return "U";
}

export default function ConflictsPage() {
  const location = useLocation();
  const [status, setStatus] = useState<Status>("open");
  const [storeDb, setStoreDb] = useState<DbName | "all">("all");
  const [sortMode, setSortMode] = useState<SortMode>("newest");
  const [rows, setRows] = useState<Array<Record<string, unknown>>>([]);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const [detail, setDetail] = useState<Awaited<ReturnType<typeof fetchConflictDetail>> | null>(null);
  const [manualWinner, setManualWinner] = useState<DbName>("mysql");
  const [deepLinkHandled, setDeepLinkHandled] = useState(false);

  const displayRows = useMemo(() => {
    const copy = [...rows];
    copy.sort((a, b) => {
      const da = new Date(asString(a.detected_at) || 0).getTime();
      const db = new Date(asString(b.detected_at) || 0).getTime();
      return sortMode === "newest" ? db - da : da - db;
    });
    return copy;
  }, [rows, sortMode]);

  async function reload() {
    setBusy(true);
    setError(null);
    try {
      const res = await fetchConflicts({
        status,
        source_db: storeDb === "all" ? undefined : storeDb,
        limit: 100,
      });
      setRows((res.conflicts ?? []) as Array<Record<string, unknown>>);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => {
    void reload();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status, storeDb]);

  // Deep link support: /conflicts?store_db=mysql&conflict_id=123
  useEffect(() => {
    if (deepLinkHandled) return;
    const sp = new URLSearchParams(location.search);
    const qStore = (sp.get("store_db") || "").toLowerCase();
    const qId = sp.get("conflict_id") || "";
    if (qStore === "mysql" || qStore === "postgres" || qStore === "oracle") {
      setStoreDb(qStore as any);
    }
    if (qId && Number.isFinite(Number(qId)) && (qStore === "mysql" || qStore === "postgres" || qStore === "oracle")) {
      (async () => {
        setBusy(true);
        setError(null);
        try {
          const res = await fetchConflictDetail(qStore as DbName, Number(qId));
          setDetail(res);
          const candidate = (asString(res.conflict?.resolution_db) || asString(res.conflict?.source_db) || qStore) as DbName;
          if (candidate === "mysql" || candidate === "postgres" || candidate === "oracle") setManualWinner(candidate);
        } catch (e) {
          setError(String(e));
        } finally {
          setBusy(false);
          setDeepLinkHandled(true);
        }
      })();
      return;
    }
    setDeepLinkHandled(true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [location.search, deepLinkHandled]);

  async function openDetail(r: Record<string, unknown>) {
    const db = asString(r.store_db) as DbName;
    const id = Number(r.id);
    if (!db || !Number.isFinite(id)) return;
    setBusy(true);
    setError(null);
    try {
      const res = await fetchConflictDetail(db, id);
      setDetail(res);
      const candidate = (asString(res.conflict?.resolution_db) || asString(res.conflict?.source_db) || db) as DbName;
      if (candidate === "mysql" || candidate === "postgres" || candidate === "oracle") setManualWinner(candidate);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  async function doResolve(r: Record<string, unknown>, body: Parameters<typeof resolveConflict>[2]) {
    const db = asString(r.store_db) as DbName;
    const id = Number(r.id);
    if (!db || !Number.isFinite(id)) return;
    setBusy(true);
    setError(null);
    try {
      await resolveConflict(db, id, body);
      setDetail(null);
      await reload();
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  async function createDemo() {
    setBusy(true);
    setError(null);
    try {
      await createDemoConflict({ source_db: "mysql", target_db: "postgres", table_name: "users", run_sync: true });
      await reload();
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  const detailKind = useMemo(() => {
    if (!detail) return null;
    return classifyConflict(detail.conflict?.reason);
  }, [detail]);

  const compare = useMemo(() => {
    if (!detail) return null;
    const rb = (detail.rows_by_db ?? {}) as Record<string, unknown>;
    const perDb: Record<DbName, { row: Record<string, unknown> | null; error?: string }> = {
      mysql: normalizeRowCandidate(rb.mysql),
      postgres: normalizeRowCandidate(rb.postgres),
      oracle: normalizeRowCandidate(rb.oracle),
    };

    const keys = new Set<string>();
    (["mysql", "postgres", "oracle"] as DbName[]).forEach((db) => {
      const row = perDb[db].row;
      if (!row) return;
      Object.keys(row).forEach((k) => keys.add(k));
    });

    return { perDb, keys: Array.from(keys).sort() };
  }, [detail]);

  return (
    <div className="stack">
      <div className="card">
        <h2>冲突</h2>
        <div className="muted">只展示冲突类型、详细数据，以及选择“以哪个数据库为准”进行修复。</div>

        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="row" style={{ marginTop: 12 }}>
          <label style={{ minWidth: 160 }}>
            <span>状态</span>
            <select value={status} onChange={(e) => setStatus(e.target.value as Status)} disabled={busy}>
              <option value="open">未解决</option>
              <option value="resolved">已解决</option>
              <option value="all">全部</option>
            </select>
          </label>

          <label style={{ minWidth: 180 }}>
            <span>冲突存储库（store_db）</span>
            <select value={storeDb} onChange={(e) => setStoreDb(e.target.value as any)} disabled={busy}>
              <option value="all">all</option>
              <option value="mysql">mysql</option>
              <option value="postgres">postgres</option>
              <option value="oracle">oracle</option>
            </select>
          </label>

          <label style={{ minWidth: 140 }}>
            <span>排序</span>
            <select value={sortMode} onChange={(e) => setSortMode(e.target.value as SortMode)} disabled={busy}>
              <option value="newest">最新</option>
              <option value="oldest">最旧</option>
            </select>
          </label>

          <button onClick={reload} disabled={busy}>
            刷新
          </button>
          <button className="secondary" onClick={createDemo} disabled={busy}>
            制造演示冲突（updated_at）
          </button>
        </div>
      </div>

      <div className="card">
        <h2>冲突列表</h2>
        <div className="table-wrap" style={{ marginTop: 10 }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>时间</th>
                <th>类型</th>
                <th>表</th>
                <th>主键</th>
                <th>状态</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {displayRows.length === 0 ? (
                <tr>
                  <td colSpan={6} className="muted">
                    无数据
                  </td>
                </tr>
              ) : (
                displayRows.map((r) => {
                  const kind = classifyConflict(r.reason);
                  const tip = `store_db=${asString(r.store_db)} source_db=${asString(r.source_db)} target_db=${asString(r.resolution_db)}`;
                  return (
                    <tr key={`${asString(r.store_db)}-${asString(r.id)}`}>
                      <td title={asString(r.detected_at)}>{asString(r.detected_at)}</td>
                      <td>
                        <span
                          style={{
                            display: "inline-block",
                            padding: "2px 8px",
                            borderRadius: 999,
                            background: "rgba(17, 24, 39, 0.04)",
                            border: "1px solid rgba(17, 24, 39, 0.10)",
                            color: kind.color,
                            fontWeight: 800,
                          }}
                          title={asString(r.reason)}
                        >
                          {kind.label}
                        </span>
                      </td>
                      <td title={tip}>{asString(r.table_name)}</td>
                      <td>{asString(r.pk_value)}</td>
                      <td>{asString(r.status)}</td>
                      <td>
                        <button onClick={() => openDetail(r)} disabled={busy}>
                          处理
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {detail ? (
        <div
          style={{
            position: "fixed",
            inset: 0,
            background: "rgba(17, 24, 39, 0.25)",
            zIndex: 9999,
            display: "flex",
            justifyContent: "center",
            alignItems: "flex-start",
            padding: 24,
            overflow: "auto",
          }}
          onClick={() => setDetail(null)}
        >
          <div className="card" style={{ width: "min(1080px, 100%)", zIndex: 10000 }} onClick={(e) => e.stopPropagation()}>
            <div className="row" style={{ justifyContent: "space-between", alignItems: "baseline" }}>
              <h2 style={{ margin: 0 }}>冲突处理</h2>
              <button className="secondary" onClick={() => setDetail(null)} disabled={busy}>
                关闭
              </button>
            </div>

            <div className="row" style={{ marginTop: 10, alignItems: "center", justifyContent: "space-between" }}>
              <div className="row" style={{ gap: 10, alignItems: "center" }}>
                {detailKind ? (
                  <span
                    style={{
                      display: "inline-block",
                      padding: "2px 10px",
                      borderRadius: 999,
                      background: "rgba(17, 24, 39, 0.04)",
                      border: "1px solid rgba(17, 24, 39, 0.10)",
                      color: detailKind.color,
                      fontWeight: 900,
                    }}
                    title={asString(detail.conflict?.reason)}
                  >
                    {detailKind.label}
                  </span>
                ) : null}
                <div className="muted">
                  表={asString(detail.conflict?.table_name)} | 主键={asString(detail.conflict?.pk_value)} | store_db={asString(detail.store_db)}
                </div>
              </div>

              <div className="row" style={{ gap: 8, alignItems: "flex-end" }}>
                <label style={{ minWidth: 180 }}>
                  <span>以哪个数据库为准</span>
                  <select value={manualWinner} onChange={(e) => setManualWinner(e.target.value as DbName)} disabled={busy}>
                    <option value="mysql">mysql</option>
                    <option value="postgres">postgres</option>
                    <option value="oracle">oracle</option>
                  </select>
                </label>
                <button
                  onClick={() =>
                    doResolve(
                      { ...detail.conflict, store_db: detail.store_db },
                      { action: "sync_from_db", winner_db: manualWinner, op: safeOp(detail.conflict?.op) },
                    )
                  }
                  disabled={busy}
                >
                  应用该库数据修复
                </button>
                <button className="secondary" onClick={() => doResolve({ ...detail.conflict, store_db: detail.store_db }, { action: "mark_resolved" })} disabled={busy}>
                  仅标记已解决
                </button>
              </div>
            </div>

            <div style={{ marginTop: 12 }}>
              <div style={{ fontWeight: 900, marginBottom: 8 }}>冲突详细数据</div>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th style={{ width: 180 }}>字段</th>
                      <th>mysql</th>
                      <th>postgres</th>
                      <th>oracle</th>
                    </tr>
                  </thead>
                  <tbody>
                    {compare && compare.keys.length > 0 ? (
                      compare.keys.map((k) => {
                        const mv = compare.perDb.mysql.row ? (compare.perDb.mysql.row as any)[k] : undefined;
                        const pv = compare.perDb.postgres.row ? (compare.perDb.postgres.row as any)[k] : undefined;
                        const ov = compare.perDb.oracle.row ? (compare.perDb.oracle.row as any)[k] : undefined;
                        const values = [formatCell(mv), formatCell(pv), formatCell(ov)].filter((x) => x !== "");
                        const diff = new Set(values).size > 1;
                        return (
                          <tr key={k} style={diff ? { background: "rgba(255, 107, 107, 0.08)" } : undefined}>
                            <td style={{ fontWeight: 700 }}>{k}</td>
                            <td title={formatCell(mv)}>{formatCell(mv)}</td>
                            <td title={formatCell(pv)}>{formatCell(pv)}</td>
                            <td title={formatCell(ov)}>{formatCell(ov)}</td>
                          </tr>
                        );
                      })
                    ) : (
                      <tr>
                        <td colSpan={4} className="muted">
                          暂无可对比数据（可能无法按主键读取该表的行数据）。
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>

              {compare ? (
                <div className="muted" style={{ marginTop: 8, lineHeight: 1.6 }}>
                  {(["mysql", "postgres", "oracle"] as DbName[]).map((db) => {
                    const err = compare.perDb[db].error;
                    if (!err) return null;
                    return (
                      <div key={db}>
                        {db} 读取错误：{err}
                      </div>
                    );
                  })}
                </div>
              ) : null}
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
}
