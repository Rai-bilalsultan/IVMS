/** @format */

import { useEffect, useState } from "react";
import { fetchDetections } from "../../../api/detectionApi";
import "../../styles/Detections.css";
import { Link } from "react-router-dom";

export default function DetectionsPage() {
    const [detections, setDetections] = useState([]);
    const [loading, setLoading] = useState(true);

    const loadDetections = async () => {
        try {
            setLoading(true);
            const data = await fetchDetections();
            setDetections(data || []);
        } catch (err) {
            console.error("Failed to load detections:", err);
            setDetections([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadDetections();
    }, []);

    return (
        <div className="detections-container">
            <h2>Detections</h2>

            {loading ? (
                <p>Loading...</p>
            ) : detections.length === 0 ? (
                <p>No detections found.</p>
            ) : (
                <div className="detections-grid">
                    {detections.map((d) => (
                        <div key={d.id} className="detection-card">
                            {d.image && (
                                <img
                                    src={`http://127.0.0.1:8000${d.image}`}
                                    alt="Detected Vehicle"
                                    className="detection-image"
                                />
                            )}
                            <div className="detection-info">
                                <p><strong>Plate:</strong> {d.plateNumber || "Unknown"}</p>
                                <p><strong>Model:</strong> {d.vehicleModel || "N/A"}</p>
                                <p><strong>Color:</strong> {d.vehicleColor || "N/A"}</p>
                                <p><strong>Status:</strong> {d.status}</p>
                                <p><strong>Location:</strong> {d.location}</p>
                                <p><strong>Owner:</strong> {d.ownerName || "N/A"}</p>
                                <p>
                                    <strong>Date:</strong>{" "}
                                    {new Date(d.detectedAt).toLocaleString()}
                                </p>
                            </div>
                            <div className="detection-footer">
                                <span className={`status ${d.status?.toLowerCase()}`}>
                                    {d.status}
                                </span>

                                <Link to={`${d.id}`}>View Details</Link>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
