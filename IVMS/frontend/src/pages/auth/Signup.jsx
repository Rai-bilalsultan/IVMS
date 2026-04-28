/** @format */

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { registerUser } from "../../../api/authApi";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import "../../styles/Auth.css";
import AuthLinks from "../../components/AuthLinks";
import PasswordInput from "../../components/PasswordInput";

export default function Signup() {
  const navigate = useNavigate();

  const [role, setRole] = useState("user"); // default role

  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    phoneNumber: "",
    password: "",
    cnic: "",
    organizationName: "",
    organizationCode: "",
    role: "user",
  });

  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  // Universal change handler
  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

  // When user changes the dropdown role
  const handleRoleChange = (e) => {
    const selectedRole = e.target.value;
    setRole(selectedRole);

    // Update role inside formData
    setFormData((prev) => ({
      ...prev,
      role: selectedRole,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");

    try {
      await registerUser(formData);
      setMessage("Account created successfully!");
      setTimeout(() => navigate("/login"), 1500);
    } catch (err) {
      console.error("Error response:", err);
      setError(err.response?.data || "Something went wrong");
    }
  };

  return (
    <div className="auth-container">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h2>Create Account</h2>

        {error && <p className="error">{error}</p>}
        {message && <p className="success">{message}</p>}

        {/* Role Dropdown */}
        <div className="mb-4">
          <label>Select Role</label>
          <select name="role" value={role} onChange={handleRoleChange}>
            <option value="user">User</option>
            <option value="admin">Admin (Organization)</option>
          </select>
        </div>

        <InputField
          label="Full Name"
          name="fullName"
          value={formData.fullName}
          onChange={handleChange}
        />

        <InputField
          label="Email"
          name="email"
          type="email"
          value={formData.email}
          onChange={handleChange}
        />

        <InputField
          label="Phone Number"
          name="phoneNumber"
          type="number"
          value={formData.phoneNumber}
          onChange={handleChange}
        />

        {/* USER FIELDS */}
        {role === "user" && (
          <InputField
            label="CNIC"
            name="cnic"
            type="text"
            value={formData.cnic}
            onChange={handleChange}
          />
        )}

        {/* ADMIN FIELDS */}
        {role === "admin" && (
          <>
            <InputField
              label="Organization Name"
              name="organizationName"
              type="text"
              value={formData.organizationName}
              onChange={handleChange}
            />

            <InputField
              label="Organization Code"
              name="organizationCode"
              type="text"
              value={formData.organizationCode}
              onChange={handleChange}
            />
          </>
        )}

        <PasswordInput
          label="Password"
          name="password"
          value={formData.password}
          onChange={handleChange}
        />

        <Button type="submit" label="Sign Up" style={{color:"#fff"}}/>

        <AuthLinks rightText="Already have an account" rightTo="/login" />
      </form>
    </div>
  );
}
