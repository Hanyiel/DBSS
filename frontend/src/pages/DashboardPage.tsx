import { useEffect, useState } from "react";

import { fetchHealth } from "../api/client";

export default function DashboardPage() {
  const [loading, setLoading] = useState(true);
  const [health, setHealth] = useState<Awaited<ReturnType<typeof fetchHealth>> | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        setLoading(true);
        const data = await fetchHealth();
        if (!cancelled) setHealth(data);
      } catch (e) {
        if (!cancelled) setError(String(e));
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (loading) return <div className="card">加载中…</div>;
  if (error) return <div className="card error">请求失败：{error}</div>;
  if (!health) return null;

  return (
    <div className="stack">
      <div className="card">
        <h2>三库连通性</h2>
        <div className="grid">
          {Object.entries(health.databases).map(([name, v]) => (
            <div key={name} className="status">
              <div className="status-title">{name}</div>
              <div className={v.ok ? "ok" : "bad"}>{v.ok ? "OK" : "FAIL"}</div>
              {!v.ok && v.error ? <div className="muted">{v.error}</div> : null}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

