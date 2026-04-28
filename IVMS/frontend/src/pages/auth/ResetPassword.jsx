/** @format */

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { resetPassword } from "../../../api/authApi";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import "../../styles/Auth.css";

export default function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ new_password: "" });
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");
    try {
      await resetPassword({
        ...formData,
        email: localStorage.getItem("email"),
      });
      localStorage.removeItem("email");

      setMessage("Password reset successful!");
      setTimeout(() => navigate("/login"), 1500);
    } catch (err) {
      console.error(err);
      setError("Failed to reset password, please try again.");
    }
  };

  return (
    <div className="auth-container">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h2>Reset Password</h2>
        {error && <p className="error">{error}</p>}
        {message && <p className="success">{message}</p>}
        <InputField
          label="Password"
          name="new_password"
          type="password"
          value={formData.new_password}
          onChange={handleChange}
        />
        <Button type="submit" label="Reset" style={{color:"#fff"}} />
      </form>
    </div>
  );
}
