import { useEffect, useState } from "react";

import { fetchMonitorDaily, fetchMonitorOverview } from "../api/client";

type DbName = "mysql" | "postgres" | "oracle";

export default function ReportsPage() {
  const [overview, setOverview] = useState<Awaited<ReturnType<typeof fetchMonitorOverview>> | null>(null);
  const [daily, setDaily] = useState<Awaited<ReturnType<typeof fetchMonitorDaily>> | null>(null);
  const [days, setDays] = useState(14);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function reload() {
    setBusy(true);
    setError(null);
    try {
      const [o, d] = await Promise.all([fetchMonitorOverview(), fetchMonitorDaily(days)]);
      setOverview(o);
      setDaily(d);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => {
    void reload();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [days]);

  const dbs: DbName[] = ["mysql", "postgres", "oracle"];

  return (
    <div className="stack">
      <div className="card">
        <h2>监控与报表</h2>
        <div className="muted">来自后端 `sync_stats_daily` / `change_log` / `conflicts` 的聚合统计。</div>

        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="row" style={{ marginTop: 12 }}>
          <label style={{ minWidth: 220 }}>
            <span>天数</span>
            <input
              type="number"
              min={1}
              max={90}
              value={days}
              onChange={(e) => setDays(Number(e.target.value))}
              disabled={busy}
            />
          </label>
          <button onClick={reload} disabled={busy}>
            刷新
          </button>
        </div>
      </div>

      <div className="card">
        <h2>概览</h2>
        <div className="table-wrap" style={{ marginTop: 10 }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>db</th>
                <th>schema</th>
                <th>backlog_unprocessed</th>
                <th>open_conflicts</th>
                <th>today.total_events</th>
                <th>today.applied_ok</th>
                <th>today.applied_fail</th>
                <th>today.conflicts</th>
                <th>today.avg_lag_ms</th>
              </tr>
            </thead>
            <tbody>
              {dbs.map((db) => {
                const v = overview?.[db];
                if (!v) {
                  return (
                    <tr key={db}>
                      <td>{db}</td>
                      <td colSpan={8} className="muted">
                        -
                      </td>
                    </tr>
                  );
                }
                if (!v.ok) {
                  return (
                    <tr key={db}>
                      <td>{db}</td>
                      <td colSpan={8} className="error">
                        {v.error ?? "error"}
                      </td>
                    </tr>
                  );
                }
                const today = v.today ?? {};
                return (
                  <tr key={db}>
                    <td>{db}</td>
                    <td>{v.schema ?? ""}</td>
                    <td>{v.backlog_unprocessed ?? 0}</td>
                    <td>{v.open_conflicts ?? 0}</td>
                    <td>{(today as any).total_events ?? 0}</td>
                    <td>{(today as any).applied_ok ?? 0}</td>
                    <td>{(today as any).applied_fail ?? 0}</td>
                    <td>{(today as any).conflicts ?? 0}</td>
                    <td>{(today as any).avg_lag_ms ?? 0}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <h2>日统计（sync_stats_daily）</h2>
        <div className="muted">说明：`applied_ok/applied_fail` 按“目标库应用次数”计数（一次变更会尝试写入另外两库）。</div>
        <div className="table-wrap" style={{ marginTop: 10 }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>db</th>
                <th>stat_date</th>
                <th>total_events</th>
                <th>applied_ok</th>
                <th>applied_fail</th>
                <th>conflicts</th>
                <th>avg_lag_ms</th>
              </tr>
            </thead>
            <tbody>
              {dbs.flatMap((db) => {
                const block = daily?.[db];
                if (!block) return [];
                if (!block.ok) {
                  return [
                    <tr key={`${db}-err`}>
                      <td>{db}</td>
                      <td colSpan={6} className="error">
                        {block.error ?? "error"}
                      </td>
                    </tr>,
                  ];
                }
                const rows = block.rows ?? [];
                if (rows.length === 0) {
                  return [
                    <tr key={`${db}-empty`}>
                      <td>{db}</td>
                      <td colSpan={6} className="muted">
                        无数据
                      </td>
                    </tr>,
                  ];
                }
                return rows.map((r, idx) => (
                  <tr key={`${db}-${idx}`}>
                    <td>{db}</td>
                    <td>{String(r.stat_date ?? "")}</td>
                    <td>{String(r.total_events ?? 0)}</td>
                    <td>{String(r.applied_ok ?? 0)}</td>
                    <td>{String(r.applied_fail ?? 0)}</td>
                    <td>{String(r.conflicts ?? 0)}</td>
                    <td>{String(r.avg_lag_ms ?? 0)}</td>
                  </tr>
                ));
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

