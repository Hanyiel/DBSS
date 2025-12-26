import { useEffect, useMemo, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";

import { fetchMe } from "../api/client";

function getParam(search: string, name: string) {
  const sp = new URLSearchParams(search);
  const v = sp.get(name);
  return v ?? "";
}

export default function EmailLoginPage() {
  const location = useLocation();
  const navigate = useNavigate();
  const token = useMemo(() => getParam(location.search, "token"), [location.search]);
  const storeDb = useMemo(() => getParam(location.search, "store_db"), [location.search]);
  const conflictId = useMemo(() => getParam(location.search, "conflict_id"), [location.search]);

  const [status, setStatus] = useState<string>("正在验证链接…");

  useEffect(() => {
    async function run() {
      if (!token) {
        setStatus("链接缺少 token 参数。");
        return;
      }
      localStorage.setItem("access_token", token);
      try {
        const me = await fetchMe();
        if (me.role !== "admin") {
          setStatus("token 无管理员权限，无法查看冲突。");
          return;
        }
        setStatus("验证成功，正在跳转到冲突页面…");
        const qs = new URLSearchParams();
        if (storeDb) qs.set("store_db", storeDb);
        if (conflictId) qs.set("conflict_id", conflictId);
        navigate(`/conflicts?${qs.toString()}`, { replace: true });
      } catch (e) {
        setStatus(`验证失败：${String(e)}`);
      }
    }
    void run();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token]);

  return (
    <div className="card">
      <h2>邮件链接登录</h2>
      <div className="muted" style={{ marginTop: 6 }}>
        {status}
      </div>
      {!token ? (
        <div className="muted" style={{ marginTop: 10 }}>
          请确认邮件链接是否完整，或联系管理员重新发送。
        </div>
      ) : null}
    </div>
  );
}

