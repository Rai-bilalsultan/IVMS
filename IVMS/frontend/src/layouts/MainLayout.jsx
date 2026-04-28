/** @format */
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import "../styles/Dashboard.css";
import { Outlet } from "react-router-dom";

export default function MainLayout() {
  const user = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user"))
    : null;

  return (
    <>
      <div className="layout-container">
        <Navbar user={user} />

        <div className="dashboard-body">
            <Sidebar />
          <div className="dashboard-content">
            <Outlet />
          </div>
        </div>
      </div>
    </>
  );
}
