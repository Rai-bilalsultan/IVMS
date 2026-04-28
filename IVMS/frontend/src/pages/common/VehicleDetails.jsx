import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import "../../styles/VehicleDetails.css";
import { fetchComplaintById } from "../../../api/complaintApi";
import Loader from "../../components/Loader";
import { ArrowLeft } from "lucide-react";

export default function VehicleDetailsPage() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [complaint, setComplaint] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

    const goBack = () => {
      if (window.history.length > 1) {
        navigate(-1);
      } else {
        navigate("/"); // fallback route if no history
      }
    };
  useEffect(() => {
    const getComplaint = async () => {
      try {
        setLoading(true);
        const response = await fetchComplaintById(id); // axios call
        setComplaint(response.data);
      } catch (err) {
        setError("Failed to fetch vehicle details.");
        console.error("Error fetching vehicle details:", err);
      } finally {
        setLoading(false);
      }
    };

    getComplaint();
  }, [id]);

  if (loading) return <Loader />;
  if (error) return <p>{error}</p>;
  if (!complaint) return <p>No vehicle found.</p>;

  return (
    <div className="vehicle-details-container">
      <button className="back-button" onClick={goBack}>
        <ArrowLeft size={18} /> Back
      </button>
      {/* <h2 className="page-title">Vehicle Details</h2> */}

      {/* Vehicle Information */}
      <div className="details-card">
        <h3>Vehicle Information</h3>
        <div className="details-grid">
          <div className="detail-item">
            <label>Make:</label>
            <p>{complaint.vehicleMake}</p>
          </div>
          <div className="detail-item">
            <label>Model:</label>
            <p>{complaint.vehicleModel}</p>
          </div>
          <div className="detail-item">
            <label>Variant:</label>
            <p>{complaint.vehicleVariant}</p>
          </div>
          <div className="detail-item">
            <label>Color:</label>
            <p>{complaint.vehicleColor}</p>
          </div>
          <div className="detail-item">
            <label>Plate No:</label>
            <p>{complaint.plateNumber}</p>
          </div>
          <div className="detail-item">
            <label>Chassis No:</label>
            <p>{complaint.chassisNumber}</p>
          </div>

          {complaint.vehiclePicture && (
            <div className="vehicle-image-box">
              <img
                src={`http://localhost:8000${complaint.vehiclePicture}`}
                alt="Vehicle"
                className="vehicle-image"
              />
            </div>
          )}
        </div>
      </div>

      {/* Owner Information */}
      <div className="details-card">
        <h3>Owner Details</h3>
        <div className="details-grid">
          <div className="detail-item">
            <label>Name:</label>
            <p>{complaint.ownerName}</p>
          </div>
          <div className="detail-item">
            <label>Email:</label>
            <p>{complaint.ownerEmail}</p>
          </div>
          <div className="detail-item">
            <label>Phone:</label>
            <p>{complaint.ownerPhone}</p>
          </div>
          <div className="detail-item">
            <label>CNIC:</label>
            <p>{complaint.ownerCnic}</p>
          </div>
        </div>
      </div>

      {/* You can add Last Detection and Predicted Routes dynamically if available */}
    </div>
  );
}
