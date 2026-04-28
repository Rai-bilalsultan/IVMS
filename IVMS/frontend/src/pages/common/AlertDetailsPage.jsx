/** @format */
import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import "../../styles/AlertDetails.css";
import Loader from "../../components/Loader";
import Button from "../../components/Button";
import { fetchAlertDetails, markAlertAsRead } from "../../../api/alertApi";
import { ArrowLeft } from "lucide-react";

export default function AlertDetailsPage() {
  const navigate = useNavigate();
  const { alertId } = useParams();
  const [alert, setAlert] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isRead, setIsRead] = useState(false);

  useEffect(() => {
    fetchDetails();
  }, []);

  const fetchDetails = async () => {
    try {
      const data = await fetchAlertDetails(alertId);
      console.log(data)
      setAlert(data);
      setIsRead(data.isRead);
    } catch (err) {
      console.error("Error fetching alert details:", err);
      setAlert(null);
    } finally {
      setLoading(false);
    }
  };

  const goBack = () => {
    if (window.history.length > 1) {
      navigate(-1);
    } else {
      navigate("/alerts");
    }
  };

  const handleMarkAsRead = async () => {
    try {
      await markAlertAsRead(alertId);
      setIsRead(true);
    } catch (err) {
      console.error("Error marking alert as read:", err);
    }
  };

  if (loading) return <Loader />;

  if (!alert) return <p className="alert-error">Alert not found or has been deleted.</p>;

  return (
    <div className="alert-details-container">
      <button className="back-button" onClick={goBack}>
        <ArrowLeft size={18} /> Back
      </button>
      <h2>Alert Details</h2>

      <div className="alert-card">
        <div className="alert-info">
          <h3>Alert Information</h3>
          <p><strong>Message:</strong> {alert.alertMessage || "N/A"}</p>
          <p><strong>Type:</strong> {alert.alertType || "N/A"}</p>
          <p><strong>Sent At:</strong> {alert.sentAt ? new Date(alert.sentAt).toLocaleString() : "N/A"}</p>

          <div className="alert-status">
            <span className={isRead ? "status-read" : "status-unread"}>
              {isRead ? "Read" : "Unread"}
            </span>
          </div>

          {!isRead && (
            <Button
              label="Mark as Read"
              onClick={handleMarkAsRead}
              style={{ width: "auto", color: "#FFF" }}
            />
          )}
        </div>

        {alert.alertImage && (
          <div className="alert-image">
            <img src={alert.alertImage} alt="Alert" />
          </div>
        )}
      </div>
    </div>
  );
}