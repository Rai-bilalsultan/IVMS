/** @format */

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { requestPasswordReset } from "../../../api/authApi";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import "../../styles/Auth.css";
import AuthLinks from "../../components/AuthLinks";

export default function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ email: "" });
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");
    try {
      await requestPasswordReset(formData);
      localStorage.setItem("email", formData.email);
      setMessage("OTP sent to your email.");
      setTimeout(() => navigate("/verify-otp"), 1500);
    } catch (err) {
      console.error(err);
      setError("Falied to send OTP, please try again.");
    }
  };

  return (
    <div className="auth-container">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h2>Forgot Password</h2>
        {error && <p className="error">{error}</p>}
        {message && <p className="success">{message}</p>}
        <InputField
          label="Email"
          name="email"
          value={formData.email}
          onChange={handleChange}
        />
        <Button type="submit" label="Forgot" style={{ color: "#fff" }} />
        <AuthLinks
          leftText="Already have an account?"
          leftTo="/login"
          rightText="Register Now!"
          rightTo="/signup/user"
        />
      </form>
    </div>
  );
}
