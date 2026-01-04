import { useEffect, useMemo, useState } from "react";

import { fetchQueryTemplates, runQueryTemplate } from "../api/client";
import JsonTable from "../components/JsonTable";

type DbName = "mysql" | "postgres" | "oracle";

type TemplateParam = {
  name: string;
  kind: "int" | "str";
  default?: number | string | null;
  description?: string;
};

function formatCell(v: unknown) {
  if (v === null || v === undefined) return "";
  if (typeof v === "string" || typeof v === "number" || typeof v === "boolean") return String(v);
  return JSON.stringify(v);
}

export default function QueriesPage() {
  const [db, setDb] = useState<DbName>("mysql");
  const [templates, setTemplates] = useState<Awaited<ReturnType<typeof fetchQueryTemplates>>["templates"]>([]);
  const [templateId, setTemplateId] = useState<string>("");

  const [sinceMinutes, setSinceMinutes] = useState<number>(60 * 24 * 7);
  const [limit, setLimit] = useState<number>(20);
  const [withExplain, setWithExplain] = useState<boolean>(true);

  const [paramValues, setParamValues] = useState<Record<string, string>>({});

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<Awaited<ReturnType<typeof runQueryTemplate>> | null>(null);

  useEffect(() => {
    async function load() {
      setBusy(true);
      setError(null);
      try {
        const res = await fetchQueryTemplates();
        const list = res.templates ?? [];
        setTemplates(list);
        const first = (list[0]?.id ?? "") as string;
        setTemplateId(first);
      } catch (e) {
        setError(String(e));
      } finally {
        setBusy(false);
      }
    }
    void load();
  }, []);

  const selected = useMemo(() => templates.find((t) => t.id === templateId) ?? null, [templates, templateId]);
  const displaySql = useMemo(() => (selected ? (selected.sql_by_db?.[db] ?? "") : ""), [selected, db]);

  const selectedParams = useMemo(() => ((selected as any)?.params ?? []) as TemplateParam[], [selected]);

  useEffect(() => {
    if (!selected) return;
    const next: Record<string, string> = {};
    for (const p of selectedParams) {
      const existing = paramValues[p.name];
      if (existing !== undefined) {
        next[p.name] = existing;
        continue;
      }
      if (p.default === null || p.default === undefined) next[p.name] = "";
      else next[p.name] = String(p.default);
    }
    setParamValues(next);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [templateId]);

  const columns = useMemo(() => {
    const rows = result?.rows ?? [];
    if (rows.length === 0) return [];
    return Object.keys(rows[0] ?? {});
  }, [result]);

  function buildParamsForRequest() {
    const out: Record<string, unknown> = {};
    for (const p of selectedParams) {
      const raw = paramValues[p.name] ?? "";
      if (p.kind === "int") {
        const n = Number(raw);
        out[p.name] = Number.isFinite(n) ? n : raw;
      } else {
        out[p.name] = raw;
      }
    }
    return out;
  }

  async function run() {
    if (!templateId) return;
    setBusy(true);
    setError(null);
    setResult(null);
    try {
      const res = await runQueryTemplate({
        db,
        template_id: templateId,
        since_minutes: sinceMinutes,
        limit,
        with_explain: withExplain,
        params: buildParamsForRequest(),
      });
      setResult(res);
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="stack">
      <div className="card">
        <h2>查询展示</h2>
        {error ? (
          <div className="error" style={{ marginTop: 10 }}>
            {error}
          </div>
        ) : null}

        <div className="form" style={{ marginTop: 12 }}>
          <div className="row">
            <label style={{ minWidth: 220 }}>
              <span>数据库</span>
              <select value={db} onChange={(e) => setDb(e.target.value as DbName)} disabled={busy}>
                <option value="mysql">mysql</option>
                <option value="postgres">postgres</option>
                <option value="oracle">oracle</option>
              </select>
            </label>

            <label style={{ minWidth: 360 }}>
              <span>查询模板</span>
              <select value={templateId} onChange={(e) => setTemplateId(e.target.value)} disabled={busy}>
                {templates.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.title}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <div className="row">
            <label style={{ minWidth: 140 }}>
              <span>返回条数</span>
              <input type="number" min={1} max={200} value={limit} onChange={(e) => setLimit(Number(e.target.value))} disabled={busy} />
            </label>

            <button onClick={run} disabled={busy || !templateId}>
              运行
            </button>
          </div>

          {selectedParams.length ? (
            <div style={{ marginTop: 10 }}>
              <div className="muted" style={{ fontWeight: 700 }}>
                模板参数
              </div>
              <div className="row" style={{ marginTop: 8, flexWrap: "wrap" }}>
                {selectedParams.map((p) => (
                  <label key={p.name} style={{ minWidth: 240 }}>
                    <span>
                      {p.name}
                      {p.description ? `（${p.description}）` : ""}
                    </span>
                    <input
                      type={p.kind === "int" ? "number" : "text"}
                      value={paramValues[p.name] ?? ""}
                      onChange={(e) => setParamValues((prev) => ({ ...prev, [p.name]: e.target.value }))}
                      disabled={busy}
                    />
                  </label>
                ))}
              </div>
            </div>
          ) : null}
        </div>
      </div>

      <div className="card">
        <h2>SQL（展示）</h2>
        <div className="muted">{selected?.description ?? ""}</div>
        <pre className="pre" style={{ marginTop: 10, whiteSpace: "pre-wrap" }}>
          {displaySql || "（请选择模板）"}
        </pre>
        {selected?.optimization_notes?.length ? (
          <div style={{ marginTop: 12 }}>
            <div className="muted" style={{ fontWeight: 700 }}>
              优化要点
            </div>
            <ul className="table-list">
              {selected.optimization_notes.map((n, i) => (
                <li key={i}>{n}</li>
              ))}
            </ul>
          </div>
        ) : null}
      </div>

      <div className="card">
        <h2>结果</h2>
        {result ? (
          <>
            <div className="muted">
              db={result.db} | rows={result.rows?.length ?? 0}
            </div>
            <div className="table-wrap" style={{ marginTop: 10 }}>
              <table className="data-table">
                <thead>
                  <tr>
                    {columns.map((c) => (
                      <th key={c}>{c}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {(result.rows ?? []).map((r, idx) => (
                    <tr key={idx}>
                      {columns.map((c) => (
                        <td key={c}>{formatCell((r as any)[c])}</td>
                      ))}
                    </tr>
                  ))}
                  {(result.rows ?? []).length === 0 ? (
                    <tr>
                      <td colSpan={Math.max(1, columns.length)} className="muted">
                        无数据
                      </td>
                    </tr>
                  ) : null}
                </tbody>
              </table>
            </div>
          </>
        ) : (
          <div className="muted">尚未运行。</div>
        )}
      </div>

    </div>
  );
}

