import { useMemo } from "react";

type Point = { xLabel: string; y: number | null };

export type TimeSeries = {
  name: string;
  color: string;
  points: Point[];
};

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

function formatNumber(v: number) {
  if (!Number.isFinite(v)) return "-";
  if (Math.abs(v) >= 1_000_000) return `${(v / 1_000_000).toFixed(1)}M`;
  if (Math.abs(v) >= 1_000) return `${(v / 1_000).toFixed(1)}k`;
  return String(Math.round(v));
}

export default function TimeSeriesChart(props: { series: TimeSeries[]; height?: number }) {
  const height = props.height ?? 260;
  const width = 900;

  const { labels, minY, maxY } = useMemo(() => {
    const labels2 = props.series[0]?.points.map((p) => p.xLabel) ?? [];
    let min = Number.POSITIVE_INFINITY;
    let max = Number.NEGATIVE_INFINITY;
    for (const s of props.series) {
      for (const p of s.points) {
        if (p.y === null) continue;
        if (p.y < min) min = p.y;
        if (p.y > max) max = p.y;
      }
    }
    if (!Number.isFinite(min) || !Number.isFinite(max)) {
      min = 0;
      max = 1;
    }
    if (min === max) {
      // create a visible range
      min = min - 1;
      max = max + 1;
    }
    return { labels: labels2, minY: min, maxY: max };
  }, [props.series]);

  const pad = { l: 44, r: 16, t: 16, b: 28 };
  const plotW = width - pad.l - pad.r;
  const plotH = height - pad.t - pad.b;

  const tickIdx = useMemo(() => {
    const n = labels.length;
    if (n <= 1) return [0];
    const raw = [0, Math.floor(n / 2), n - 1];
    return Array.from(new Set(raw)).filter((i) => i >= 0 && i < n);
  }, [labels]);

  const yTicks = useMemo(() => {
    const mid = (minY + maxY) / 2;
    return [maxY, mid, minY];
  }, [minY, maxY]);

  function xAt(i: number) {
    const n = Math.max(1, labels.length - 1);
    return pad.l + (plotW * i) / n;
  }

  function yAt(v: number) {
    const t = (v - minY) / (maxY - minY);
    const inv = 1 - t;
    return pad.t + plotH * clamp(inv, 0, 1);
  }

  function toPolyline(points: Array<{ x: number; y: number }>) {
    return points.map((p) => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(" ");
  }

  const polylines = useMemo(() => {
    return props.series.map((s) => {
      const segments: Array<Array<{ x: number; y: number }>> = [];
      let current: Array<{ x: number; y: number }> = [];
      s.points.forEach((p, idx) => {
        if (p.y === null || !Number.isFinite(p.y)) {
          if (current.length >= 2) segments.push(current);
          current = [];
          return;
        }
        current.push({ x: xAt(idx), y: yAt(p.y) });
      });
      if (current.length >= 2) segments.push(current);
      return { ...s, segments };
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [props.series, labels, minY, maxY]);

  return (
    <div style={{ width: "100%" }}>
      <svg viewBox={`0 0 ${width} ${height}`} width="100%" height={height} style={{ display: "block" }}>
        <rect x={0} y={0} width={width} height={height} fill="#ffffff" />

        {/* Y grid + labels */}
        {yTicks.map((t, idx) => {
          const y = yAt(t);
          return (
            <g key={idx}>
              <line x1={pad.l} y1={y} x2={width - pad.r} y2={y} stroke="rgba(17, 24, 39, 0.08)" strokeWidth={1} />
              <text x={pad.l - 8} y={y + 4} textAnchor="end" fontSize={12} fill="rgba(17, 24, 39, 0.55)">
                {formatNumber(t)}
              </text>
            </g>
          );
        })}

        {/* X labels */}
        {tickIdx.map((i) => (
          <text key={i} x={xAt(i)} y={height - 8} textAnchor="middle" fontSize={12} fill="rgba(17, 24, 39, 0.55)">
            {labels[i] ?? ""}
          </text>
        ))}

        {/* Lines */}
        {polylines.flatMap((s) =>
          s.segments.map((seg, idx) => (
            <polyline key={`${s.name}-${idx}`} points={toPolyline(seg)} fill="none" stroke={s.color} strokeWidth={2.5} />
          )),
        )}
      </svg>

      {/* Legend */}
      <div className="row" style={{ marginTop: 8, gap: 12 }}>
        {props.series.map((s) => (
          <div key={s.name} className="row" style={{ gap: 8 }}>
            <span style={{ width: 12, height: 12, borderRadius: 3, background: s.color, display: "inline-block" }} />
            <span className="muted" style={{ fontWeight: 700 }}>
              {s.name}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

