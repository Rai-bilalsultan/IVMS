/** @format */
import axios from "axios";

const API_BASE = import.meta.env.VITE_API_URL || "http://127.0.0.1:8000/";

// Fetch all detections
export const fetchDetections = async (role) => {
    const user = JSON.parse(localStorage.getItem("user"));
    const accessToken = localStorage.getItem("access") || null;

    try {
        const response = await axios.get(`${API_BASE}detections/`, {
            params: {
                role: user.role,
                email: user.email
            },
        });

        return response.data; // return data directly
    } catch (error) {
        console.error("Error fetching detections:", error);
        throw error;
    }
};

// Get single detection
export const getDetectionDetails = async (id) => {
    return axios.get(`${API_BASE}detections/${id}/`);
};

// Fetch unknown vehicles (admin only)
export const fetchUnknownVehicles = async () => {
    try {
        const res = await axios.get(`${API_BASE}unknown-vehicles/`, {
            params: { role: "admin" },
        });

        return res.data;
    } catch (error) {
        console.error("Error fetching unknown vehicles:", error);
        throw error;
    }
};