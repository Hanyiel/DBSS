import { useEffect, useState } from "react";

import { fetchTables, migrateDatabase, migrateTable, runBackup } from "../api/client";
import JsonTable from "../components/JsonTable";

type Mode = "table" | "database";

export default function MigrationPage() {
  const [tables, setTables] = useState<string[]>([]);
  const [mode, setMode] = useState<Mode>("table");
  const [sourceDb, setSourceDb] = useState("mysql");
  const [targetDb, setTargetDb] = useState("postgres");
  const [tableName, setTableName] = useState("users");
  const [truncateTarget, setTruncateTarget] = useState(true);
  const [batchSize, setBatchSize] = useState(500);
  const [output, setOutput] = useState<unknown>(null);

  const [backupBusy, setBackupBusy] = useState(false);
  const [backupResult, setBackupResult] = useState<Awaited<ReturnType<typeof runBackup>> | null>(null);

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
    setOutput(null);
    setBackupResult(null);
    try {
      if (mode === "table") {
        const res = await migrateTable({
          source_db: sourceDb,
          target_db: targetDb,
          table_name: tableName,
          truncate_target: truncateTarget,
          batch_size: batchSize,
        });
        setOutput(res);
      } else {
        const res = await migrateDatabase({
          source_db: sourceDb,
          target_db: targetDb,
          tables: tables,
          truncate_target: truncateTarget,
          batch_size: batchSize,
        });
        setOutput(res);
      }
    } catch (e) {
      setError(String(e));
    }
  }

  async function onBackup() {
    setError(null);
    setOutput(null);
    setBackupResult(null);
    setBackupBusy(true);
    try {
      const res = await runBackup({});
      setBackupResult(res);
    } catch (e) {
      setError(String(e));
    } finally {
      setBackupBusy(false);
    }
  }

  return (
    <div className="stack">
      <div className="card">
        <h2>迁移</h2>
        <div className="muted">需要先在“登录”页获取管理员 token。</div>

        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="form" style={{ marginTop: 12 }}>
          <label>
            <span>模式</span>
            <select value={mode} onChange={(e) => setMode(e.target.value as Mode)}>
              <option value="table">单表迁移</option>
              <option value="database">整库迁移</option>
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
              <input type="number" value={batchSize} min={1} max={5000} onChange={(e) => setBatchSize(Number(e.target.value))} />
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

      <div className="card">
        <h2>备份</h2>
        <div className="row" style={{ marginTop: 12 }}>
          <button onClick={onBackup} disabled={backupBusy}>
            {backupBusy ? "备份中..." : "一键备份（MySQL+Postgres+Oracle）"}
          </button>
        </div>

        {backupResult?.ok ? (
          <div style={{ marginTop: 12 }}>
            <div className="muted">备份目录</div>
            <div className="pre" style={{ marginTop: 6 }}>
              {backupResult.out_dir}
            </div>

            <div className="muted" style={{ marginTop: 10 }}>
              文件列表
            </div>
            <div className="table-wrap" style={{ marginTop: 6 }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>name</th>
                    <th>bytes</th>
                  </tr>
                </thead>
                <tbody>
                  {backupResult.files.map((f) => (
                    <tr key={f.name}>
                      <td>{f.name}</td>
                      <td>{f.bytes}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        ) : null}
      </div>

      {output ? (
        <div className="card">
          <h2>结果</h2>
          <JsonTable value={output} />
        </div>
      ) : null}
    </div>
  );
}

