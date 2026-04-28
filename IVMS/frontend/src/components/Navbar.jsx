/** @format */

import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import AlertsDropdown from "./AlertsDropdown";
import ProfileDropdown from "./ProfileDropdown";
import "./styles/Navbar.css";
import logoImage from "../assets/logo.png";

const Navbar = ({ user }) => {
  const navigate = useNavigate();
  const [alertsOpen, setAlertsOpen] = useState(false);
  const [profileOpen, setProfileOpen] = useState(false);
  const [darkMode, setDarkMode] = useState(
    localStorage.getItem("theme") === "dark"
  );

  const wrapperRef = useRef(null);

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target)) {
        setAlertsOpen(false);
        setProfileOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Apply theme
  useEffect(() => {
    document.body.setAttribute("data-theme", darkMode ? "dark" : "light");
    localStorage.setItem("theme", darkMode ? "dark" : "light");
  }, [darkMode]);

  const onLogout = () => {
    document.body.setAttribute("data-theme", "light");
    localStorage.clear();
    navigate("/login");
  };

  return (
    <header className="ivms-navbar" ref={wrapperRef}>
      {/* Left: Logo & App Name */}
      <div className="nav-left">
        <img src={logoImage} alt="Logo" className="nav-logo" />
        <div className="nav-appname">
          <span className="app-name">Track Vision</span>
          <small className="app-sub">Intelligent Vehicle Monitoring</small>
        </div>
      </div>

      {/* Center: optional */}
      <div className="nav-center"></div>

      {/* Right: Alerts, Profile, Dark Mode */}
      <div className="nav-right">
        {/* Dark/Light Mode Toggle */}
        <div className="nav-item">
          <button
            className="toggle-btn"
            aria-label="Toggle Dark Mode"
            onClick={() => setDarkMode((prev) => !prev)}
          >
            <span className={`slider ${darkMode ? "dark" : ""}`} />
          </button>
        </div>

        {/* Alerts */}
        <div className="nav-item">
          <button
            className="icon-btn"
            aria-label="Alerts"
            onClick={() => {
              setAlertsOpen((v) => !v);
              setProfileOpen(false);
            }}
          >
            <span className="bell-dot" aria-hidden />
            <svg
              width="20"
              height="20"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
            >
              <path
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6 6 0 10-12 0v3.159c0 .538-.214 1.055-.595 1.436L4 17h5"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
              <path
                d="M13.73 21a2 2 0 01-3.46 0"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </button>
          {alertsOpen && <AlertsDropdown onClose={() => setAlertsOpen(false)} />}
        </div>

        {/* Profile */}
        <div className="nav-item profile-area">
          <button
            className="profile-btn"
            onClick={() => {
              setProfileOpen((v) => !v);
              setAlertsOpen(false);
            }}
            aria-haspopup="true"
            aria-expanded={profileOpen}
          >
            <div className="avatar-placeholder">
              {(user?.fullName || "U").charAt(0)}
            </div>
            <div className="profile-name">
              <span className="small">Hi,</span>
              <strong>{user?.fullName?.split(" ")[0] || "User"}</strong>
            </div>
            <svg
              className="chev"
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
            >
              <path d="M6 9l6 6 6-6" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </button>

          {profileOpen && (
            <ProfileDropdown
              user={user}
              onEdit={() => {
                navigate(`edit-profile`);
                setProfileOpen(false);
              }}
              onLogout={onLogout}
              onClose={() => setProfileOpen(false)}
            />
          )}
        </div>
      </div>
    </header>
  );
};

export default Navbar;
