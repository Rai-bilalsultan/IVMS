/** @format */

import { useNavigate } from "react-router-dom";
import "../../styles/Complain.css";

export default function ComplaintMainPage() {
  const navigate = useNavigate();

  // Clean role extraction
  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const role = user.role || "user"; // fallback

  return (
    <div className="complaint-main-container">
      <h2 className="complaint-title">Vehicle Complaints</h2>
      <p className="complaint-subtitle">Select an option to proceed:</p>

      <div className="complaint-options">
        {/* Submit Complaint */}
        <div
          className="complaint-card"
          role="button"
          tabIndex={0}
          onClick={() => navigate(`/${role}/dashboard/complain/submit`)}
          onKeyDown={(e) => e.key === "Enter" && navigate(`/${role}/dashboard/complain/submit`)}
        >
          <h3>Submit Complaint</h3>
          <p>Report a new stolen or lost vehicle.</p>
        </div>

        {/* Search Complaint */}
        <div
          className="complaint-card"
          role="button"
          tabIndex={0}
          onClick={() => navigate(`/${role}/dashboard/complain/search`)}
          onKeyDown={(e) => e.key === "Enter" && navigate(`/${role}/dashboard/complain/search`)}
        >
          <h3>Search Complaint</h3>
          <p>Check status or details of existing complaints.</p>
        </div>
      </div>
    </div>
  );
}
