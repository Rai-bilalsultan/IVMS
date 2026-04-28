/** @format */
import Button from "./Button";
import "./styles/ComplaintCard.css";

export default function ComplaintCard({ complaint, onView }) {
  return (
    <div className="complaint-card">
      <h3>{complaint.plateNumber}</h3>
      <p>
        Status: <strong>{complaint.status.toUpperCase()}</strong>
      </p>
      <p>Make: {complaint.vehicleMake}</p>
      <p>Reported on: {new Date(complaint.createdAt).toLocaleDateString()}</p>
      <Button label="View Details" onClick={() => onView(complaint)} style={{color: "#fff"}} />
    </div>
  );
}
