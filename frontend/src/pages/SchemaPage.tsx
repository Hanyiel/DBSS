import { useEffect, useState } from "react";

import { fetchTables } from "../api/client";

export default function SchemaPage() {
  const [tables, setTables] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await fetchTables();
        if (!cancelled) setTables(data.tables);
      } catch (e) {
        if (!cancelled) setError(String(e));
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="card">
      <h2>业务表</h2>
      {error ? <div className="error">请求失败：{error}</div> : null}
      <ul className="table-list">
        {tables.map((t) => (
          <li key={t}>{t}</li>
        ))}
      </ul>
    </div>
  );
}

