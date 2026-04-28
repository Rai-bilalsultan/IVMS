/** @format */

import { useEffect, useState } from "react";
import { fetchUnknownVehicles } from "../../../api/detectionApi";
import "../../styles/UnknownVehicles.css";

export default function UnknownVehiclesPage() {
    const [vehicles, setVehicles] = useState([]);
    const [loading, setLoading] = useState(true);

    const loadVehicles = async () => {
        try {
            setLoading(true);
            const data = await fetchUnknownVehicles();
            setVehicles(data || []);
        } catch (err) {
            console.error("Failed to load unknown vehicles:", err);
            setVehicles([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadVehicles();
    }, []);

    return (
        <div className="unknown-container">
            <h2>Unknown Vehicles</h2>

            {loading ? (
                <p>Loading...</p>
            ) : vehicles.length === 0 ? (
                <p>No unknown vehicles found.</p>
            ) : (
                <div className="unknown-grid">
                    {vehicles.map((v) => (
                        <div key={v.id} className="unknown-card">
                            {v.image ? (
                                <img
                                    src={`http://127.0.0.1:8000${v.image}`}
                                    alt="Unknown Vehicle"
                                />
                            ) : (
                                <div className="no-image">No Image</div>
                            )}

                            <div className="unknown-info">
                                <p>
                                    <strong>Color:</strong> {v.vehicleColor || "Unknown"}
                                </p>
                                <p>
                                    <strong>Location:</strong> {v.location || "N/A"}
                                </p>
                                <p>
                                    <strong>Date:</strong>{" "}
                                    {new Date(v.detectedAt).toLocaleString()}
                                </p>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}