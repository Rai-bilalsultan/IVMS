/** @format */

import axios from "axios";

const API_BASE = "http://127.0.0.1:8000/";

// ✅ 1. Get user alerts
export const fetchUserAlerts = async () => {
  const user = JSON.parse(localStorage.getItem("user"));
  try {
    const response = await axios.get(`${API_BASE}alerts/`, {
      params: {
        email: user.email,
        role: user.role,
      },
    });

    return response.data;
  } catch (error) {
    console.error("Error fetching alerts:", error);
    throw error;
  }
};


// ✅ 2. Mark alert as read
export const markAlertAsRead = async (alertId) => {
  try {
    const response = await axios.patch(
      `${API_BASE}alerts/${alertId}/mark-read/`
    );

    return response.data;
  } catch (error) {
    console.error("Error marking alert as read:", error);
    throw error;
  }
};


// ✅ 3. Get alert details
export const fetchAlertDetails = async (alertId) => {
  try {
    const response = await axios.get(
      `${API_BASE}alerts/${alertId}/`
    );

    return response.data;
  } catch (error) {
    console.error("Error fetching alert details:", error);
    throw error;
  }
};
