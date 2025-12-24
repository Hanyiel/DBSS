import { useEffect, useState } from "react";

import { fetchTables, migrateDatabase, migrateTable } from "../api/client";

type Mode = "table" | "database";

export default function MigrationPage() {
  const [tables, setTables] = useState<string[]>([]);
  const [mode, setMode] = useState<Mode>("table");
  const [sourceDb, setSourceDb] = useState("mysql");
  const [targetDb, setTargetDb] = useState("postgres");
  const [tableName, setTableName] = useState("users");
  const [truncateTarget, setTruncateTarget] = useState(true);
  const [batchSize, setBatchSize] = useState(500);
  const [output, setOutput] = useState<string>("");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await fetchTables();
        if (!cancelled) {
          setTables(data.tables);
          if (data.tables.includes("users")) setTableName("users");
          else if (data.tables.length) setTableName(data.tables[0]);
        }
      } catch (e) {
        if (!cancelled) setError(String(e));
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  async function onRun() {
    setError(null);
    setOutput("");
    try {
      if (mode === "table") {
        const res = await migrateTable({
          source_db: sourceDb,
          target_db: targetDb,
          table_name: tableName,
          truncate_target: truncateTarget,
          batch_size: batchSize,
        });
        setOutput(JSON.stringify(res, null, 2));
      } else {
        const res = await migrateDatabase({
          source_db: sourceDb,
          target_db: targetDb,
          tables: tables,
          truncate_target: truncateTarget,
          batch_size: batchSize,
        });
        setOutput(JSON.stringify(res, null, 2));
      }
    } catch (e) {
      setError(String(e));
    }
  }

  return (
    <div className="stack">
      <div className="card">
        <h2>迁移</h2>
        <div className="muted">
          需要先在“登录”页获取管理员 token（接口使用 JWT + RBAC）。此页面用于课程演示：表迁移/整库迁移 + 行数统计。
        </div>

        {error ? <div className="error" style={{ marginTop: 10 }}>{error}</div> : null}

        <div className="form" style={{ marginTop: 12 }}>
          <label>
            <span>模式</span>
            <select value={mode} onChange={(e) => setMode(e.target.value as Mode)}>
              <option value="table">单表迁移</option>
              <option value="database">整库迁移（业务表集合）</option>
            </select>
          </label>

          <div className="row">
            <label>
              <span>源库</span>
              <select value={sourceDb} onChange={(e) => setSourceDb(e.target.value)}>
                <option value="mysql">mysql</option>
                <option value="postgres">postgres</option>
                <option value="oracle">oracle</option>
              </select>
            </label>
            <label>
              <span>目标库</span>
              <select value={targetDb} onChange={(e) => setTargetDb(e.target.value)}>
                <option value="mysql">mysql</option>
                <option value="postgres">postgres</option>
                <option value="oracle">oracle</option>
              </select>
            </label>
          </div>

          {mode === "table" ? (
            <label>
              <span>表名</span>
              <select value={tableName} onChange={(e) => setTableName(e.target.value)}>
                {tables.map((t) => (
                  <option key={t} value={t}>
                    {t}
                  </option>
                ))}
              </select>
            </label>
          ) : null}

          <div className="row">
            <label>
              <span>批大小</span>
              <input
                type="number"
                value={batchSize}
                min={1}
                max={5000}
                onChange={(e) => setBatchSize(Number(e.target.value))}
              />
            </label>
            <label className="checkbox">
              <input checked={truncateTarget} onChange={(e) => setTruncateTarget(e.target.checked)} type="checkbox" />
              <span>迁移前清空目标表</span>
            </label>
          </div>

          <div className="row">
            <button onClick={onRun}>执行迁移</button>
          </div>
        </div>
      </div>

      {output ? (
        <div className="card">
          <h2>结果</h2>
          <pre className="pre">{output}</pre>
        </div>
      ) : null}
    </div>
  );
}
