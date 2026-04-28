/** @format */
import ReactDOM from "react-dom";
import "./styles/ComplaintDetailModal.css";

export default function ComplaintDetailModal({ complaint, onClose }) {
  if (!complaint) return null;

  return ReactDOM.createPortal(
    <div className="modal-backdrop" onClick={onClose}>
      <div
        className="modal-content"
        onClick={(e) => e.stopPropagation()} // Prevent closing when clicking inside
      >
        <div className="modal-body">
          {/* Left: Details */}
          <div className="modal-details">
            <h2>Complaint Details</h2>
            <p>
              <strong>Plate Number:</strong> {complaint.plateNumber}
            </p>
            <p>
              <strong>Vehicle Make:</strong> {complaint.vehicleMake}
            </p>
            <p>
              <strong>Vehicle Model:</strong> {complaint.vehicleVariant}
            </p>
            <p>
              <strong>Color:</strong> {complaint.vehicleColor}
            </p>
            <p>
              <strong>Status:</strong> {complaint.status}
            </p>
            <p>
              <strong>Reported At:</strong>{" "}
              {new Date(complaint.createdAt).toLocaleString()}
            </p>
            <p>
              <strong>Additional Info:</strong>{" "}
              {complaint.complaintDescription || "N/A"}
            </p>
            <button className="close-btn" onClick={onClose}>
              Close
            </button>
          </div>

          {/* Right: Vehicle Picture */}
          <div className="modal-image">
            {complaint.vehiclePicture ? (
              <img
                src={`http://localhost:8000${complaint.vehiclePicture}`}
                alt="Vehicle"
              />
            ) : (
              <p>No Image Available</p>
            )}
          </div>
        </div>
      </div>
    </div>,
    document.body
  );
}
