import { useEffect, useMemo, useState } from "react";

import { fetchConflictsReport, fetchMonitorDaily } from "../api/client";
import TimeSeriesChart, { type TimeSeries } from "../components/TimeSeriesChart";

type DbName = "mysql" | "postgres" | "oracle";
type SyncMetricKey = "total_events" | "applied_ok" | "applied_fail" | "conflicts" | "avg_lag_ms";
type ConflictMetricKey = "created" | "resolved";

const dbs: DbName[] = ["mysql", "postgres", "oracle"];

const syncMetricName: Record<SyncMetricKey, string> = {
  total_events: "每日变更事件数（source change_log）",
  applied_ok: "每日同步成功次数（target apply ok）",
  applied_fail: "每日同步失败次数（target apply fail）",
  conflicts: "每日冲突数（sync_stats_daily）",
  avg_lag_ms: "平均延迟（ms）",
};

const conflictMetricName: Record<ConflictMetricKey, string> = {
  created: "新增冲突（按 detected_at）",
  resolved: "解决冲突（按 resolved_at）",
};

const dbColor: Record<DbName, string> = {
  mysql: "#2563eb",
  postgres: "#16a34a",
  oracle: "#b42318",
};

function asNumber(v: unknown): number | null {
  if (v === null || v === undefined) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function parseDateKey(s: string) {
  const d = new Date(s);
  if (Number.isFinite(d.getTime())) return d.getTime();
  return s;
}

export default function ReportsPage() {
  const [daily, setDaily] = useState<Awaited<ReturnType<typeof fetchMonitorDaily>> | null>(null);
  const [conflictsReport, setConflictsReport] = useState<Awaited<ReturnType<typeof fetchConflictsReport>> | null>(null);

  const [days, setDays] = useState(14);
  const [syncMetric, setSyncMetric] = useState<SyncMetricKey>("conflicts");
  const [conflictMetric, setConflictMetric] = useState<ConflictMetricKey>("created");

  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function reload() {
    setBusy(true);
    setError(null);
    try {
      const [d, c] = await Promise.all([fetchMonitorDaily(days), fetchConflictsReport(days)]);
      setDaily(d);
      setConflictsReport(c);
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

  const syncChart = useMemo(() => {
    const rowsByDb: Record<DbName, Array<Record<string, unknown>>> = {
      mysql: (daily?.mysql?.ok ? daily.mysql.rows : []) ?? [],
      postgres: (daily?.postgres?.ok ? daily.postgres.rows : []) ?? [],
      oracle: (daily?.oracle?.ok ? daily.oracle.rows : []) ?? [],
    };

    const allDates = new Set<string>();
    dbs.forEach((db) => {
      rowsByDb[db].forEach((r) => {
        const d = String((r as any).stat_date ?? "");
        if (d) allDates.add(d);
      });
    });

    const dates = Array.from(allDates).sort((a, b) => {
      const pa = parseDateKey(a);
      const pb = parseDateKey(b);
      if (typeof pa === "number" && typeof pb === "number") return pa - pb;
      return String(pa).localeCompare(String(pb));
    });

    const series: TimeSeries[] = dbs.map((db) => {
      const map = new Map<string, Record<string, unknown>>();
      rowsByDb[db].forEach((r) => map.set(String((r as any).stat_date ?? ""), r));
      return {
        name: db,
        color: dbColor[db],
        points: dates.map((d) => {
          const row = map.get(d);
          const y = row ? asNumber((row as any)[syncMetric]) : null;
          return { xLabel: d, y };
        }),
      };
    });

    return { dates, series };
  }, [daily, syncMetric]);

  const conflictChart = useMemo(() => {
    const byDb = conflictsReport?.by_db ?? {};
    const allDates = new Set<string>();

    dbs.forEach((db) => {
      const v = byDb[db];
      if (!v || !(v as any).ok) return;
      const rows = conflictMetric === "created" ? (v as any).created_daily : (v as any).resolved_daily;
      (rows as Array<{ date: string; count: number }>).forEach((r) => {
        if (r.date) allDates.add(String(r.date));
      });
    });

    const dates = Array.from(allDates).sort((a, b) => {
      const pa = parseDateKey(a);
      const pb = parseDateKey(b);
      if (typeof pa === "number" && typeof pb === "number") return pa - pb;
      return String(pa).localeCompare(String(pb));
    });

    const series: TimeSeries[] = dbs.map((db) => {
      const v = byDb[db];
      const map = new Map<string, number>();
      if (v && (v as any).ok) {
        const rows = conflictMetric === "created" ? (v as any).created_daily : (v as any).resolved_daily;
        (rows as Array<{ date: string; count: number }>).forEach((r) => map.set(String(r.date), Number(r.count) || 0));
      }
      return {
        name: db,
        color: dbColor[db],
        points: dates.map((d) => ({ xLabel: d, y: map.has(d) ? map.get(d)! : 0 })),
      };
    });

    return { dates, series };
  }, [conflictsReport, conflictMetric]);

  return (
    <div className="stack">
      <div className="card">
        <h2>报表</h2>
        <div className="muted">同步趋势来自 `sync_stats_daily`；冲突报表来自 `conflicts`。</div>

        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="row" style={{ marginTop: 12 }}>
          <label style={{ minWidth: 120 }}>
            <span>天数</span>
            <input type="number" min={1} max={90} value={days} onChange={(e) => setDays(Number(e.target.value))} disabled={busy} />
          </label>
          <label style={{ minWidth: 260 }}>
            <span>同步趋势指标</span>
            <select value={syncMetric} onChange={(e) => setSyncMetric(e.target.value as SyncMetricKey)} disabled={busy}>
              <option value="conflicts">{syncMetricName.conflicts}</option>
              <option value="applied_fail">{syncMetricName.applied_fail}</option>
              <option value="applied_ok">{syncMetricName.applied_ok}</option>
              <option value="total_events">{syncMetricName.total_events}</option>
              <option value="avg_lag_ms">{syncMetricName.avg_lag_ms}</option>
            </select>
          </label>
          <label style={{ minWidth: 260 }}>
            <span>冲突趋势指标</span>
            <select value={conflictMetric} onChange={(e) => setConflictMetric(e.target.value as ConflictMetricKey)} disabled={busy}>
              <option value="created">{conflictMetricName.created}</option>
              <option value="resolved">{conflictMetricName.resolved}</option>
            </select>
          </label>
          <button onClick={reload} disabled={busy}>
            刷新
          </button>
        </div>
      </div>

      <div className="card">
        <h2>冲突趋势（真实数据）</h2>
        <div className="muted">从各库 `conflicts` 表按天聚合（不依赖 `sync_stats_daily`）。</div>
        <div style={{ marginTop: 10 }}>
          <TimeSeriesChart series={conflictChart.series} height={260} />
        </div>

      </div>

      <div className="card">
        <h2>同步趋势（图形）</h2>
        <div className="muted">每条折线代表一个数据库。</div>
        <div style={{ marginTop: 10 }}>
          <TimeSeriesChart series={syncChart.series} height={280} />
        </div>
      </div>

      <details className="card">
        <summary style={{ cursor: "pointer", fontWeight: 900 }}>查看原始同步统计（sync_stats_daily）</summary>
        <div className="muted" style={{ marginTop: 8 }}>
          说明：`applied_ok/applied_fail` 按“目标库应用次数”计数（一次变更会尝试写入另外两库）。
        </div>
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
                    <td>{String((r as any).stat_date ?? "")}</td>
                    <td>{String((r as any).total_events ?? 0)}</td>
                    <td>{String((r as any).applied_ok ?? 0)}</td>
                    <td>{String((r as any).applied_fail ?? 0)}</td>
                    <td>{String((r as any).conflicts ?? 0)}</td>
                    <td>{String((r as any).avg_lag_ms ?? 0)}</td>
                  </tr>
                ));
              })}
            </tbody>
          </table>
        </div>
      </details>
    </div>
  );
}

