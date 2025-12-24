import { NavLink, Route, Routes } from "react-router-dom";

import ConflictsPage from "./pages/ConflictsPage";
import DbOpsPage from "./pages/DbOpsPage";
import DashboardPage from "./pages/DashboardPage";
import LoginPage from "./pages/LoginPage";
import MigrationPage from "./pages/MigrationPage";
import ReportsPage from "./pages/ReportsPage";
import SchemaPage from "./pages/SchemaPage";

export default function App() {
  return (
    <div className="app">
      <header className="topbar">
        <div className="brand">DBSS</div>
        <nav className="nav">
          <NavLink to="/" end>
            首页
          </NavLink>
          <NavLink to="/schema">表结构</NavLink>
          <NavLink to="/db">数据库操作</NavLink>
          <NavLink to="/migration">迁移</NavLink>
          <NavLink to="/conflicts">冲突</NavLink>
          <NavLink to="/reports">报表</NavLink>
          <NavLink to="/login">登录</NavLink>
        </nav>
      </header>

      <main className="content">
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/schema" element={<SchemaPage />} />
          <Route path="/db" element={<DbOpsPage />} />
          <Route path="/migration" element={<MigrationPage />} />
          <Route path="/conflicts" element={<ConflictsPage />} />
          <Route path="/reports" element={<ReportsPage />} />
          <Route path="/login" element={<LoginPage />} />
        </Routes>
      </main>
    </div>
  );
}
