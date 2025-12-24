import axios from "axios";

const baseURL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000/api";

export const api = axios.create({
  baseURL,
  timeout: 10_000,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("access_token");
  if (token) {
    config.headers = config.headers ?? {};
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export async function fetchHealth() {
  const res = await api.get("/health");
  return res.data as {
    ok: boolean;
    databases: Record<string, { ok: boolean; error?: string }>;
  };
}

export async function fetchTables() {
  const res = await api.get("/schema/tables");
  return res.data as { tables: string[] };
}

export async function fetchDbTables(dbName: string) {
  const res = await api.get(`/db/${dbName}/tables`, { params: { scope: "business" } });
  return res.data as { db: string; schema?: string | null; tables: string[] };
}

export async function fetchDbTableInfo(dbName: string, tableName: string) {
  const res = await api.get(`/db/${dbName}/tables/${tableName}`);
  return res.data as {
    db: string;
    table: string;
    schema_name?: string | null;
    columns: Array<{ name: string; type: string; nullable: boolean; default?: string | null }>;
    primary_key: string[];
  };
}

export async function fetchDbRows(dbName: string, tableName: string, limit = 20, offset = 0) {
  const res = await api.get(`/db/${dbName}/tables/${tableName}/rows`, { params: { limit, offset } });
  return res.data as {
    db: string;
    table: string;
    limit: number;
    offset: number;
    rows: Array<Record<string, unknown>>;
  };
}

export async function insertDbRow(dbName: string, tableName: string, values: Record<string, unknown>) {
  const res = await api.post(`/db/${dbName}/tables/${tableName}/rows`, { values });
  return res.data as { ok: boolean; inserted_primary_key: string[]; sync?: unknown };
}

export async function deleteDbRow(dbName: string, tableName: string, rowId: string) {
  const res = await api.delete(`/db/${dbName}/tables/${tableName}/rows/${rowId}`);
  return res.data as { ok: boolean; deleted: number; sync?: unknown };
}

export async function login(username: string, password: string) {
  const body = new URLSearchParams();
  body.set("username", username);
  body.set("password", password);
  const res = await api.post("/auth/token", body, {
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
  });
  return res.data as { access_token: string; token_type: string };
}

export async function fetchMe() {
  const res = await api.get("/auth/me");
  return res.data as { sub?: string; role?: string };
}

export async function migrateTable(req: {
  source_db: string;
  target_db: string;
  table_name: string;
  truncate_target: boolean;
  batch_size: number;
}) {
  const res = await api.post("/migration/table", req);
  return res.data as {
    table: string;
    source_db: string;
    target_db: string;
    rows_read: number;
    rows_written: number;
    seconds: number;
  };
}

export async function migrateDatabase(req: {
  source_db: string;
  target_db: string;
  tables: string[];
  truncate_target: boolean;
  batch_size: number;
}) {
  const res = await api.post("/migration/database", req);
  return res.data as {
    source_db: string;
    target_db: string;
    results: Array<{
      table: string;
      rows_read: number;
      rows_written: number;
      seconds: number;
    }>;
  };
}

export async function fetchConflicts(params?: { status?: "open" | "resolved" | "all"; source_db?: string; limit?: number }) {
  const res = await api.get("/conflicts", { params });
  return res.data as { conflicts: Array<Record<string, unknown>> };
}

export async function resolveConflict(
  sourceDb: string,
  conflictId: number,
  body: { action: "mark_resolved" | "retry_keep_source"; op?: "I" | "U" | "D"; mark_resolved_on_success?: boolean },
) {
  const res = await api.post(`/conflicts/${sourceDb}/${conflictId}/resolve`, body);
  return res.data as { ok: boolean; action: string; apply?: unknown };
}

export async function fetchMonitorOverview() {
  const res = await api.get("/monitor/overview");
  return res.data as Record<
    string,
    {
      ok: boolean;
      schema?: string | null;
      backlog_unprocessed?: number;
      open_conflicts?: number;
      today?: Record<string, unknown> | null;
      error?: string;
    }
  >;
}

export async function fetchMonitorDaily(days = 14) {
  const res = await api.get("/monitor/daily", { params: { days } });
  return res.data as Record<string, { ok: boolean; rows?: Array<Record<string, unknown>>; error?: string }>;
}
