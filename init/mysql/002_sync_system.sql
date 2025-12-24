-- Sync system tables (shared concept across MySQL/Postgres/Oracle)

CREATE TABLE IF NOT EXISTS change_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  source_db VARCHAR(20) NOT NULL,
  table_name VARCHAR(64) NOT NULL,
  pk_value VARCHAR(128) NOT NULL,
  op ENUM('I','U','D') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  processed TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE INDEX idx_change_log_processed ON change_log (processed, id);
CREATE INDEX idx_change_log_table_pk ON change_log (table_name, pk_value, id);

CREATE TABLE IF NOT EXISTS sync_applied (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  change_id BIGINT NOT NULL,
  target_db VARCHAR(20) NOT NULL,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('ok','fail') NOT NULL,
  error_text TEXT,
  UNIQUE KEY uq_change_target (change_id, target_db),
  CONSTRAINT fk_sync_applied_change FOREIGN KEY (change_id) REFERENCES change_log(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS conflicts (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(64) NOT NULL,
  pk_value VARCHAR(128) NOT NULL,
  detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('open','resolved') NOT NULL DEFAULT 'open',
  reason VARCHAR(255),
  source_db VARCHAR(20),
  resolution_db VARCHAR(20),
  resolved_by VARCHAR(50),
  resolved_at TIMESTAMP NULL
) ENGINE=InnoDB;

CREATE INDEX idx_conflicts_status ON conflicts (status, detected_at);

CREATE TABLE IF NOT EXISTS sync_stats_daily (
  stat_date DATE PRIMARY KEY,
  total_events INT NOT NULL DEFAULT 0,
  applied_ok INT NOT NULL DEFAULT 0,
  applied_fail INT NOT NULL DEFAULT 0,
  conflicts INT NOT NULL DEFAULT 0,
  avg_lag_ms INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

