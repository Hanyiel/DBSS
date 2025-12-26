import { useMemo } from "react";

type Props = {
  value: unknown;
  title?: string;
  maxRows?: number;
  maxCols?: number;
};

function isPlainObject(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

function formatCell(v: unknown) {
  if (v === null || v === undefined) return "";
  if (typeof v === "string" || typeof v === "number" || typeof v === "boolean") return String(v);
  return JSON.stringify(v);
}

export default function JsonTable({ value, title, maxRows = 100, maxCols = 30 }: Props) {
  const model = useMemo(() => {
    if (Array.isArray(value)) {
      const rows = value.slice(0, maxRows);
      const allObjects = rows.every((r) => isPlainObject(r));
      if (allObjects) {
        const keys = new Set<string>();
        for (const r of rows as Array<Record<string, unknown>>) {
          for (const k of Object.keys(r)) keys.add(k);
          if (keys.size >= maxCols) break;
        }
        const columns = Array.from(keys).slice(0, maxCols);
        return { kind: "table" as const, columns, rows: rows as Array<Record<string, unknown>> };
      }
      return {
        kind: "kv" as const,
        rows: rows.map((r, idx) => ({ key: String(idx), value: r })),
      };
    }

    if (isPlainObject(value)) {
      const keys = Object.keys(value).sort();
      return { kind: "kv" as const, rows: keys.map((k) => ({ key: k, value: (value as any)[k] })) };
    }

    return { kind: "scalar" as const, value };
  }, [value, maxRows, maxCols]);

  if (model.kind === "scalar") {
    return <div className="muted">{formatCell(model.value)}</div>;
  }

  if (model.kind === "kv") {
    return (
      <div className="table-wrap">
        {title ? <div className="muted" style={{ padding: "10px 12px", borderBottom: "1px solid var(--border)" }}>{title}</div> : null}
        <table className="data-table">
          <thead>
            <tr>
              <th style={{ width: 240 }}>key</th>
              <th>value</th>
            </tr>
          </thead>
          <tbody>
            {model.rows.length === 0 ? (
              <tr>
                <td colSpan={2} className="muted">
                  无数据
                </td>
              </tr>
            ) : (
              model.rows.map((r) => (
                <tr key={r.key}>
                  <td style={{ fontWeight: 700 }}>{r.key}</td>
                  <td title={formatCell(r.value)}>{formatCell(r.value)}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    );
  }

  return (
    <div className="table-wrap">
      {title ? <div className="muted" style={{ padding: "10px 12px", borderBottom: "1px solid var(--border)" }}>{title}</div> : null}
      <table className="data-table">
        <thead>
          <tr>
            {model.columns.map((c) => (
              <th key={c}>{c}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {model.rows.length === 0 ? (
            <tr>
              <td colSpan={Math.max(1, model.columns.length)} className="muted">
                无数据
              </td>
            </tr>
          ) : (
            model.rows.map((r, idx) => (
              <tr key={idx}>
                {model.columns.map((c) => (
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
  );
}

