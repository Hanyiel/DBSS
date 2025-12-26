import { NavLink, Route, Routes } from "react-router-dom";

import ConflictsPage from "./pages/ConflictsPage";
import DbOpsPage from "./pages/DbOpsPage";
import DashboardPage from "./pages/DashboardPage";
import EmailLoginPage from "./pages/EmailLoginPage";
import LoginPage from "./pages/LoginPage";
import MigrationPage from "./pages/MigrationPage";
import QueriesPage from "./pages/QueriesPage";
import ReportsPage from "./pages/ReportsPage";

export default function App() {
  return (
    <div className="app">
      <header className="topbar">
        <div className="brand">DBSS</div>
        <nav className="nav">
          <NavLink to="/" end>
            首页
          </NavLink>
          <NavLink to="/db">数据库操作</NavLink>
          <NavLink to="/migration">迁移</NavLink>
          <NavLink to="/conflicts">冲突</NavLink>
          <NavLink to="/queries">查询</NavLink>
          <NavLink to="/reports">报表</NavLink>
          <NavLink to="/login">登录</NavLink>
        </nav>
      </header>

      <main className="content">
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/db" element={<DbOpsPage />} />
          <Route path="/migration" element={<MigrationPage />} />
          <Route path="/conflicts" element={<ConflictsPage />} />
          <Route path="/email-login" element={<EmailLoginPage />} />
          <Route path="/queries" element={<QueriesPage />} />
          <Route path="/reports" element={<ReportsPage />} />
          <Route path="/login" element={<LoginPage />} />
        </Routes>
      </main>
    </div>
  );
}
