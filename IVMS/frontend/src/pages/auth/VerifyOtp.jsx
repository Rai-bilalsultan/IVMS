/** @format */

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { verifyOTP } from "../../../api/authApi";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import "../../styles/Auth.css";

export default function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ otp: "" });
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");
    try {
      await verifyOTP({
        ...formData,
        email: localStorage.getItem("email"),
      });

      setMessage("OTP verified successfully!");
      setTimeout(() => navigate("/reset-password"), 1500);
    } catch (err) {
      console.error(err);
      setError("Invalid OTP or expired.");
    }
  };

  return (
    <div className="auth-container">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h2>Verify OTP</h2>
        {error && <p className="error">{error}</p>}
        {message && <p className="success">{message}</p>}
        <InputField
          label="OTP"
          name="otp"
          type="text"
          value={formData.otp}
          onChange={handleChange}
        />
        <Button type="submit" label="Verify" style={{color:"#fff"}}/>
      </form>
    </div>
  );
}
