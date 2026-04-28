/** @format */

import axios from "axios";

const API_BASE = import.meta.env.VITE_API_URL || "http://127.0.0.1:8000/";

export const registerComplaint = async (data) => {
  return axios.post(`${API_BASE}complaints/register/`, data, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
};

export const searchComplaintForUser = async (query) => {
  return axios.get(`${API_BASE}complaints/search/`, {
    params: { ...query },
  });
};

export const searchComplaintForAdmin = async (query) => {
  return axios.get(`${API_BASE}complaints/search/`, {
    params: { ...query },
  });
};

export const fetchUserComplaints = (userEmail) => {
  return axios.get(`${API_BASE}complaints`, {
    params: { email: userEmail },
  });
};

export const fetchAllComplaints = () => {
  return axios.get(`${API_BASE}complaints`);
};

export const fetchComplaintById = async (id) => {
  return axios.get(`${API_BASE}complaints/${id}/`);
};
