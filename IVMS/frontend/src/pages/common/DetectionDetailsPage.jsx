/** @format */

import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import {
    MapContainer,
    TileLayer,
    Marker,
    Popup,
    Polyline,
} from "react-leaflet";
import "../../styles/DetectionDetails.css";

const API = "http://127.0.0.1:8000/";

export default function DetectionDetailsPage() {
    const { id } = useParams();
    const navigate = useNavigate();

    const [detection, setDetection] = useState(null);
    const [routes, setRoutes] = useState([]);

    useEffect(() => {
        fetchDetails();
    }, [id]);

    const fetchDetails = async () => {
        try {
            console.log("Fetching ID:", id);

            const res = await axios.get(`${API}detections/${id}/`);

            console.log("Detection detail:", res.data);

            setDetection(res.data);
            setRoutes(res.data.routes || []);
        } catch (err) {
            console.error("Error fetching detection detail:", err);
        }
    };

    if (!detection) return <p>Loading...</p>;

    const position =
        detection.latitude && detection.longitude
            ? [detection.latitude, detection.longitude]
            : [0, 0];

    return (
        <div className="details-container">
            <button className="back-btn" onClick={() => navigate(-1)}>
                ← Back
            </button>

            <h2>Detection Details</h2>

            <div className="details-card">
                {/* LEFT SIDE */}
                <div className="details-info">
                    <p>
                        <strong>Plate:</strong>{" "}
                        {detection.plateNumber || "Unknown"}
                    </p>

                    <p>
                        <strong>Model:</strong>{" "}
                        {detection.vehicleModel || "N/A"}
                    </p>

                    <p>
                        <strong>Color:</strong>{" "}
                        {detection.vehicleColor || "N/A"}
                    </p>

                    <p>
                        <strong>Status:</strong> {detection.status}
                    </p>

                    <p>
                        <strong>Location:</strong>{" "}
                        {detection.location || "N/A"}
                    </p>

                    <p>
                        <strong>Owner:</strong>{" "}
                        {detection.ownerName || "N/A"}
                    </p>

                    <p>
                        <strong>Date:</strong>{" "}
                        {detection.detectedAt
                            ? new Date(detection.detectedAt).toLocaleString()
                            : "N/A"}
                    </p>

                    {detection.image && (
                        <img
                            src={`http://127.0.0.1:8000${detection.image}`}
                            alt="Vehicle"
                            className="details-image"
                        />
                    )}
                </div>

                {/* RIGHT SIDE MAP */}
                <div className="map-container">
                    <MapContainer
                        key={detection.id}
                        center={position}
                        zoom={13}
                        className="map"
                    >
                        <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />

                        <Marker position={position}>
                            <Popup>Detected here</Popup>
                        </Marker>

                        {/* ROUTES */}
                        {routes.map((route, index) => {
                            const coords = route?.geometry?.coordinates;

                            if (!coords || !Array.isArray(coords)) return null;

                            // Convert [lng, lat] → [lat, lng]
                            const fixedCoords = coords.map(([lng, lat]) => [
                                lat,
                                lng,
                            ]);

                            return (
                                <Polyline
                                    key={index}
                                    positions={fixedCoords}
                                    color="red"
                                />
                            );
                        })}
                    </MapContainer>
                </div>
            </div>
        </div>
    );
}
