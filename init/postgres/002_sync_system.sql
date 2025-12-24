-- Sync system tables (shared concept across MySQL/Postgres/Oracle)

CREATE TABLE IF NOT EXISTS change_log (
  id BIGSERIAL PRIMARY KEY,
  source_db TEXT NOT NULL,
  table_name TEXT NOT NULL,
  pk_value TEXT NOT NULL,
  op CHAR(1) NOT NULL CHECK (op IN ('I','U','D')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_change_log_processed ON change_log (processed, id);
CREATE INDEX IF NOT EXISTS idx_change_log_table_pk ON change_log (table_name, pk_value, id);

CREATE TABLE IF NOT EXISTS sync_applied (
  id BIGSERIAL PRIMARY KEY,
  change_id BIGINT NOT NULL REFERENCES change_log(id) ON DELETE CASCADE,
  target_db TEXT NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status TEXT NOT NULL CHECK (status IN ('ok','fail')),
  error_text TEXT,
  UNIQUE (change_id, target_db)
);

CREATE TABLE IF NOT EXISTS conflicts (
  id BIGSERIAL PRIMARY KEY,
  table_name TEXT NOT NULL,
  pk_value TEXT NOT NULL,
  detected_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','resolved')),
  reason TEXT,
  source_db TEXT,
  resolution_db TEXT,
  resolved_by TEXT,
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_conflicts_status ON conflicts (status, detected_at);

CREATE TABLE IF NOT EXISTS sync_stats_daily (
  stat_date DATE PRIMARY KEY,
  total_events INT NOT NULL DEFAULT 0,
  applied_ok INT NOT NULL DEFAULT 0,
  applied_fail INT NOT NULL DEFAULT 0,
  conflicts INT NOT NULL DEFAULT 0,
  avg_lag_ms INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

