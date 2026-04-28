/** @format */

import axios from "axios";

const API_BASE = import.meta.env.VITE_API_URL || "http://127.0.0.1:8000/";

export const registerUser = async (data) => {
  return await axios.post(`${API_BASE}signup/`, data);
};

export const loginUser = async (data) => {
  return await axios.post(`${API_BASE}login/`, data);
};

export const requestPasswordReset = async (data) => {
  return await axios.post(`${API_BASE}forgot-password/`, data);
};

export const verifyOTP = async (data) => {
  return await axios.post(`${API_BASE}verify-otp/`, data);
};

export const resetPassword = async (data) => {
  return await axios.post(`${API_BASE}reset-password/`, data);
};

export const getUser = async (email) => {
  return await axios.get(`${API_BASE}user/profile/`, {
    params: { email: email },
  });
};

export const updateProfile = async (form, email) => {
  return await axios.put(`${API_BASE}user/profile/update/`, form, email);
};
