import { useEffect, useMemo, useState } from "react";

import { fetchConflicts, resolveConflict } from "../api/client";

type Status = "open" | "resolved" | "all";
type DbName = "mysql" | "postgres" | "oracle";

function asString(v: unknown) {
  if (v === null || v === undefined) return "";
  return String(v);
}

export default function ConflictsPage() {
  const [status, setStatus] = useState<Status>("open");
  const [sourceDb, setSourceDb] = useState<DbName | "all">("all");
  const [rows, setRows] = useState<Array<Record<string, unknown>>>([]);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [lastAction, setLastAction] = useState<unknown>(null);

  const displayRows = useMemo(() => rows, [rows]);

  async function reload() {
    setBusy(true);
    setError(null);
    try {
      const res = await fetchConflicts({
        status,
        source_db: sourceDb === "all" ? undefined : sourceDb,
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
  }, [status, sourceDb]);

  async function onResolve(r: Record<string, unknown>) {
    const storeDb = asString(r.store_db);
    const id = Number(r.id);
    if (!storeDb || !Number.isFinite(id)) return;
    setBusy(true);
    setError(null);
    setLastAction(null);
    try {
      const res = await resolveConflict(storeDb, id, { action: "mark_resolved" });
      setLastAction(res);
      await reload();
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  async function onRetryKeepSource(r: Record<string, unknown>) {
    const storeDb = asString(r.store_db);
    const id = Number(r.id);
    if (!storeDb || !Number.isFinite(id)) return;
    setBusy(true);
    setError(null);
    setLastAction(null);
    try {
      const res = await resolveConflict(storeDb, id, { action: "retry_keep_source", op: "U", mark_resolved_on_success: true });
      setLastAction(res);
      await reload();
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="stack">
      <div className="card">
        <h2>冲突</h2>
        <div className="muted">展示同步过程中写入的 `conflicts` 记录，并提供“标记已解决 / 以源库为准重试”操作。</div>

        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="form" style={{ marginTop: 12 }}>
          <div className="row">
            <label style={{ minWidth: 220 }}>
              <span>状态</span>
              <select value={status} onChange={(e) => setStatus(e.target.value as Status)} disabled={busy}>
                <option value="open">open</option>
                <option value="resolved">resolved</option>
                <option value="all">all</option>
              </select>
            </label>

            <label style={{ minWidth: 220 }}>
              <span>库（conflicts 存放处）</span>
              <select value={sourceDb} onChange={(e) => setSourceDb(e.target.value as any)} disabled={busy}>
                <option value="all">all</option>
                <option value="mysql">mysql</option>
                <option value="postgres">postgres</option>
                <option value="oracle">oracle</option>
              </select>
            </label>

            <button onClick={reload} disabled={busy}>
              刷新
            </button>
          </div>
        </div>
      </div>

      <div className="card">
        <h2>冲突列表</h2>
        <div className="table-wrap" style={{ marginTop: 10 }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>store_db</th>
                <th>id</th>
                <th>table</th>
                <th>pk</th>
                <th>target</th>
                <th>status</th>
                <th>detected_at</th>
                <th>reason</th>
                <th>action</th>
              </tr>
            </thead>
            <tbody>
              {displayRows.length === 0 ? (
                <tr>
                  <td colSpan={9} className="muted">
                    暂无数据
                  </td>
                </tr>
              ) : (
                displayRows.map((r) => (
                  <tr key={`${asString(r.store_db)}-${asString(r.id)}`}>
                    <td>{asString(r.store_db)}</td>
                    <td>{asString(r.id)}</td>
                    <td>{asString(r.table_name)}</td>
                    <td>{asString(r.pk_value)}</td>
                    <td>{asString(r.resolution_db)}</td>
                    <td>{asString(r.status)}</td>
                    <td>{asString(r.detected_at)}</td>
                    <td title={asString(r.reason)} style={{ maxWidth: 420 }}>
                      {asString(r.reason)}
                    </td>
                    <td style={{ whiteSpace: "nowrap" }}>
                      <button onClick={() => onRetryKeepSource(r)} disabled={busy}>
                        以源库为准重试
                      </button>
                      <button className="danger" onClick={() => onResolve(r)} disabled={busy} style={{ marginLeft: 8 }}>
                        标记已解决
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {lastAction ? (
        <div className="card">
          <h2>最近一次操作结果</h2>
          <pre className="pre" style={{ marginTop: 10 }}>
            {JSON.stringify(lastAction, null, 2)}
          </pre>
        </div>
      ) : null}
    </div>
  );
}

