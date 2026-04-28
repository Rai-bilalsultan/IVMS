/** @format */

import { useState, useEffect } from "react";
import "../../styles/EditPage.css";
import Loader from "../../components/Loader";
import { getUser, updateProfile } from "../../../api/authApi";
import InputField from "../../components/InputField";
import Button from "../../components/Button";

export default function EditProfile() {
  const [form, setForm] = useState({
    fullName: "",
    phoneNumber: "",
  });
  const [error, setError] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const email = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user")).email
    : null;

  const [user, setUser] = useState(null);

  // Fetch user details
  useEffect(() => {
    const fetchUser = async () => {
      const res = await getUser(email);
      setUser(res.data);
      setForm({
        fullName: res.data.fullName,
        phoneNumber: res.data.phoneNumber,
      });
    };
    fetchUser();
  }, [email]);

  const initials =
    user?.fullName
      ?.split(" ")
      .map((word) => word[0])
      .join("")
      .substring(0, 3)
      .toUpperCase() || "";

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccessMessage("");

    try {
      await updateProfile({ ...form, email });
      setSuccessMessage("Profile updated successfully!");
      setTimeout(() => {
        window.location.reload();
      }, 2000);
    } catch (error) {
      console.error("Error updating profile:", error);
      setError("Failed to update profile.");
    }
  };

  if (!user) return <Loader />;

  return (
    <div className="edit-profile-container">
      {/* ALERT MESSAGES */}
      {error && <p className="alert-error">{error}</p>}
      {successMessage && <p className="alert-success">{successMessage}</p>}

      <div className="profile-header">
        <div className="profile-avatar">{initials}</div>
        <h2>{user.fullName}</h2>
        <p>{user.email}</p>
      </div>

      <form onSubmit={handleSubmit} className="edit-profile-form">
        <InputField
          type="text"
          label="Full Name"
          name="fullName"
          value={form.fullName}
          onChange={handleChange}
          required
        />

        <InputField
          type="text"
          label="Phone Number"
          name="phoneNumber"
          value={form.phoneNumber}
          onChange={handleChange}
        />

        <Button type="submit" label="Save Changes" />
      </form>
    </div>
  );
}
