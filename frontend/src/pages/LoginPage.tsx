import { useState } from "react";

import { fetchMe, login } from "../api/client";

export default function LoginPage() {
  const [username, setUsername] = useState("admin");
  const [password, setPassword] = useState("admin123");
  const [status, setStatus] = useState<string | null>(null);
  const [me, setMe] = useState<{ sub?: string; role?: string } | null>(null);

  async function onLogin() {
    setStatus(null);
    try {
      const token = await login(username, password);
      localStorage.setItem("access_token", token.access_token);
      setStatus("登录成功，已保存 token 到 localStorage。");
      setMe(await fetchMe());
    } catch (e) {
      setStatus(`登录失败：${String(e)}`);
    }
  }

  async function onCheckMe() {
    setStatus(null);
    try {
      setMe(await fetchMe());
      setStatus("已验证 token。");
    } catch (e) {
      setStatus(`请求失败：${String(e)}`);
    }
  }

  function onLogout() {
    localStorage.removeItem("access_token");
    setMe(null);
    setStatus("已清除 token。");
  }

  return (
    <div className="card">
      <h2>登录（管理员）</h2>
      <div className="muted">
        默认账号来自 `backend/.env`：`ADMIN_USERNAME` / `ADMIN_PASSWORD`。登录后可访问迁移接口（需要 admin）。
      </div>

      <div className="form">
        <label>
          <span>用户名</span>
          <input value={username} onChange={(e) => setUsername(e.target.value)} />
        </label>
        <label>
          <span>密码</span>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </label>
        <div className="row">
          <button onClick={onLogin}>登录</button>
          <button className="secondary" onClick={onCheckMe}>
            验证 token
          </button>
          <button className="danger" onClick={onLogout}>
            退出
          </button>
        </div>
      </div>

      {status ? <div className="muted" style={{ marginTop: 10 }}>{status}</div> : null}
      {me ? (
        <div className="muted" style={{ marginTop: 10 }}>
          当前：sub={me.sub ?? "-"}，role={me.role ?? "-"}
        </div>
      ) : null}
    </div>
  );
}
