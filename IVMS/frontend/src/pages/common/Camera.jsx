/** @format */
import { useNavigate } from "react-router-dom";
import "../../styles/Complain.css";

export default function CameraMainPage() {
  const role = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user"))?.role
    : null;
  const navigate = useNavigate();

  return (
    <div className="complaint-main-container">
      <h2>Scan Vehicle Live</h2>
      <p>Select an option to proceed:</p>

      <div className="complaint-options">
        {role === "admin" && (
          <div
            className="complaint-card"
            onClick={() => navigate("/admin/dashboard/camera/configure")}
          >
            <h3>Connect IP Camera</h3>
            <p>Connect with esisting IP camera to see live.</p>
          </div>
        )}

        <div className="complaint-card">
          <h3>Scan with mobile</h3>
          <p>
            Install the App from App/Playstore to scan with your mobbile camera.
          </p>
        </div>
      </div>
    </div>
  );
}
