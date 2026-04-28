/** @format */

import { useEffect, useState } from "react";
import "../../styles/AlertPage.css"
import Button from "../../components/Button";
import { fetchUserAlerts, markAlertAsRead } from "../../../api/alertApi";
import { formatTime } from "../../lib/formatTime";
import { useNavigate } from "react-router-dom";

export default function AlertsPage() {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  const user = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user"))
    : null;

  // ✅ Load alerts from backend
  const loadAlerts = async () => {
    try {
      setLoading(true);
      const data = await fetchUserAlerts();

      const formatted = data.map((a) => ({
        id: a.id,
        alertMessage: a.alertMessage || "Stolen vehicle detected",
        alertImage: a.alertImage || null,
        time: formatTime(a.sentAt),
        isRead: a.isRead,
        detection: a.detection, // keep for detail display if needed
      }));

      setAlerts(formatted);
    } catch (error) {
      console.error("Failed to load alerts:", error);
      setAlerts([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAlerts();
  }, [user?.email]);

  // ✅ Mark single alert as read
  const handleMarkRead = async (id) => {
    try {
      await markAlertAsRead(id);
      setAlerts((prev) =>
        prev.map((a) => (a.id === id ? { ...a, isRead: true } : a))
      );
    } catch (error) {
      console.error("Error marking alert as read:", error);
    }
  };

  // ✅ Mark all alerts as read
  const handleMarkAllRead = async () => {
    try {
      await Promise.all(alerts.map((a) => markAlertAsRead(a.id)));
      setAlerts((prev) => prev.map((a) => ({ ...a, isRead: true })));
    } catch (error) {
      console.error("Error marking all alerts:", error);
    }
  };

  return (
    <div className="alerts-container">
      <div className="alerts-header">
        <h2>Alerts</h2>
        <Button label="Mark all read" style={{ width: '100px', marginLeft: 'auto', color: '#FFF' }} onClick={handleMarkAllRead} />
      </div>

      {loading ? (
        <p>Loading alerts...</p>
      ) : alerts.length === 0 ? (
        <p>No alerts available.</p>
      ) : (
        alerts.map((alert) => (
          <div
            key={alert.id}
            className={`alert-card ${alert.isRead ? "read" : "unread"}`}
            onClick={() => handleMarkRead(alert.id)}
          >
            <p>{alert.alertMessage}</p>
            <small>{alert.time}</small>
            <Button label="View Detail" style={{ width: '100px', marginLeft: '20px', color: '#FFF' }} onClick={() => navigate(`${alert.id}`)} />
          </div>
        ))
      )}
    </div>
  );
}