import { useEffect, useMemo, useState } from "react";

import { deleteDbRow, fetchDbRows, fetchDbTableInfo, fetchDbTables, insertDbRow } from "../api/client";

type DbName = "mysql" | "postgres" | "oracle";
type ViewMode = "table" | "json";

export default function DbOpsPage() {
  const [db, setDb] = useState<DbName>("mysql");
  const [tables, setTables] = useState<string[]>([]);
  const [table, setTable] = useState<string>("users");
  const [info, setInfo] = useState<Awaited<ReturnType<typeof fetchDbTableInfo>> | null>(null);
  const [rows, setRows] = useState<Array<Record<string, unknown>>>([]);
  const [error, setError] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<ViewMode>("table");

  const [insertJson, setInsertJson] = useState<string>(
    '{\n  "username": "u1",\n  "email": "u1@example.com",\n  "password": "pwd"\n}',
  );
  const [deleteId, setDeleteId] = useState<string>("");
  const [busy, setBusy] = useState(false);
  const [lastSync, setLastSync] = useState<unknown>(null);

  const columnNames = useMemo(() => {
    if (info?.columns?.length) return info.columns.map((c) => c.name);
    const set = new Set<string>();
    for (const r of rows) Object.keys(r).forEach((k) => set.add(k));
    return Array.from(set);
  }, [info, rows]);

  function formatCell(v: unknown) {
    if (v === null || v === undefined) return "";
    if (typeof v === "string" || typeof v === "number" || typeof v === "boolean") return String(v);
    return JSON.stringify(v);
  }

  async function reloadTables(nextDb: DbName): Promise<string[]> {
    const t = await fetchDbTables(nextDb);
    setTables(t.tables);
    return t.tables;
  }

  async function reloadTableData(nextDb: DbName, nextTable: string) {
    const [ti, tr] = await Promise.all([fetchDbTableInfo(nextDb, nextTable), fetchDbRows(nextDb, nextTable, 20, 0)]);
    setInfo(ti);
    setRows(tr.rows);
  }

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        setError(null);
        const nextTables = await reloadTables(db);
        if (nextTables.length === 0) {
          if (!cancelled) {
            setTable("");
            setInfo(null);
            setRows([]);
            setError("该数据库下未找到业务表（可能是 Oracle schema 不匹配或未初始化）。");
          }
          return;
        }

        const nextTable = nextTables.includes(table) ? table : nextTables[0];
        if (!cancelled) {
          setTable(nextTable);
          await reloadTableData(db, nextTable);
        }
      } catch (e) {
        if (!cancelled) setError(String(e));
      }
    })();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function onChangeDb(nextDb: DbName) {
    setDb(nextDb);
    setBusy(true);
    setError(null);
    try {
      const nextTables = await reloadTables(nextDb);
      if (nextTables.length === 0) {
        setTable("");
        setInfo(null);
        setRows([]);
        setError("该数据库下未找到业务表（可能是 Oracle schema 不匹配或未初始化）。");
        return;
      }

      const nextTable = nextTables.includes(table) ? table : nextTables[0];
      setTable(nextTable);
      await reloadTableData(nextDb, nextTable);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  async function onChangeTable(nextTable: string) {
    setTable(nextTable);
    setBusy(true);
    setError(null);
    try {
      await reloadTableData(db, nextTable);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  async function onInsert() {
    setBusy(true);
    setError(null);
    setLastSync(null);
    try {
      const obj = JSON.parse(insertJson) as Record<string, unknown>;
      const res = await insertDbRow(db, table, obj);
      setLastSync(res.sync ?? null);
      await reloadTableData(db, table);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  async function onDelete() {
    setBusy(true);
    setError(null);
    setLastSync(null);
    try {
      if (!deleteId.trim()) throw new Error("请输入要删除的 id");
      const res = await deleteDbRow(db, table, deleteId.trim());
      setLastSync(res.sync ?? null);
      setDeleteId("");
      await reloadTableData(db, table);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="stack">
      <div className="card">
        <h2>数据库操作（查询/插入/删除）</h2>
        <div className="muted">需要先在“登录”页获取管理员 token（否则会 401/403）。</div>

        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="form" style={{ marginTop: 12 }}>
          <div className="row">
            <label style={{ minWidth: 220 }}>
              <span>数据库</span>
              <select value={db} onChange={(e) => onChangeDb(e.target.value as DbName)} disabled={busy}>
                <option value="mysql">mysql</option>
                <option value="postgres">postgres</option>
                <option value="oracle">oracle</option>
              </select>
            </label>

            <label style={{ minWidth: 260 }}>
              <span>表</span>
              <select value={table} onChange={(e) => onChangeTable(e.target.value)} disabled={busy}>
                {tables.map((t) => (
                  <option key={t} value={t}>
                    {t}
                  </option>
                ))}
              </select>
            </label>

            <button onClick={() => onChangeTable(table)} disabled={busy || !table}>
              刷新
            </button>
          </div>
        </div>
      </div>

      {info ? (
        <div className="card">
          <h2>表结构</h2>
          <div className="muted" style={{ marginBottom: 10 }}>
            PK: {info.primary_key?.length ? info.primary_key.join(", ") : "-"}
          </div>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>列名</th>
                  <th>类型</th>
                  <th>可空</th>
                  <th>默认值</th>
                </tr>
              </thead>
              <tbody>
                {info.columns.map((c) => (
                  <tr key={c.name}>
                    <td>{c.name}</td>
                    <td title={c.type}>{c.type}</td>
                    <td>{c.nullable ? "YES" : "NO"}</td>
                    <td title={c.default ?? ""}>{c.default ?? ""}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : null}

      <div className="card">
        <h2>查询数据（前 20 条）</h2>
        <div className="row" style={{ marginTop: 8, justifyContent: "space-between" }}>
          <div className="muted">列：{columnNames.length ? columnNames.join(", ") : "-"}</div>
          <label style={{ display: "flex", gap: 8, alignItems: "center" }}>
            <span className="muted">显示</span>
            <select value={viewMode} onChange={(e) => setViewMode(e.target.value as ViewMode)} disabled={busy}>
              <option value="table">表格</option>
              <option value="json">JSON</option>
            </select>
          </label>
        </div>

        {viewMode === "table" ? (
          <div className="table-wrap" style={{ marginTop: 10 }}>
            <table className="data-table">
              <thead>
                <tr>
                  {columnNames.map((c) => (
                    <th key={c}>{c}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.length === 0 ? (
                  <tr>
                    <td colSpan={Math.max(1, columnNames.length)} className="muted">
                      暂无数据
                    </td>
                  </tr>
                ) : (
                  rows.map((r, idx) => (
                    <tr key={idx}>
                      {columnNames.map((c) => (
                        <td key={c} title={formatCell(r[c])}>
                          {formatCell(r[c])}
                        </td>
                      ))}
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        ) : (
          <pre className="pre" style={{ marginTop: 10 }}>
            {JSON.stringify(rows, null, 2)}
          </pre>
        )}
      </div>

      <div className="card">
        <h2>插入</h2>
        <div className="muted">输入 JSON（仅会写入该表存在的列）。</div>
        <textarea
          value={insertJson}
          onChange={(e) => setInsertJson(e.target.value)}
          rows={8}
          style={{
            width: "100%",
            marginTop: 10,
            padding: 12,
            borderRadius: 12,
            border: "1px solid var(--border)",
            background: "#ffffff",
            fontFamily:
              "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
          }}
        />
        <div className="row" style={{ marginTop: 10 }}>
          <button onClick={onInsert} disabled={busy || !table}>
            插入并刷新
          </button>
        </div>
      </div>

      <div className="card">
        <h2>删除</h2>
        <div className="muted">当前仅支持按 `id` 删除。</div>
        <div className="row" style={{ marginTop: 10 }}>
          <input value={deleteId} onChange={(e) => setDeleteId(e.target.value)} placeholder="id" />
          <button className="danger" onClick={onDelete} disabled={busy || !table}>
            删除并刷新
          </button>
        </div>
      </div>

      {lastSync ? (
        <div className="card">
          <h2>同步结果</h2>
          <div className="muted">插入/删除后会自动触发一次从当前库到另外两库的同步。</div>
          <pre className="pre" style={{ marginTop: 10 }}>
            {JSON.stringify(lastSync, null, 2)}
          </pre>
        </div>
      ) : null}
    </div>
  );
}
