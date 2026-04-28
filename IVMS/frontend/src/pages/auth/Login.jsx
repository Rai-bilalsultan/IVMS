/** @format */

import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginUser } from "../../../api/authApi";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import "../../styles/Auth.css";
import AuthLinks from "../../components/AuthLinks";
import PasswordInput from "../../components/PasswordInput";
import Loader from "../../components/Loader";

export default function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ email: "", password: "" });
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const user = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user"))
    : null;
  const accessToken = localStorage.getItem("access") || null;
  useEffect(() => {
    if (accessToken && user.role) {
      if (user.role === "admin") {
        navigate("/admin/dashboard/home");
        return;
      }
      navigate("/user/dashboard/home");
    }
  }, [navigate, accessToken, user?.role]);

  const handleChange = (e) =>
    setFormData({ ...formData, [e.target.name]: e.target.value });

 const handleSubmit = async (e) => {
   e.preventDefault();
   setLoading(true);
   setMessage("");
   setError("");

   try {
     const res = await loginUser(formData);
     const { user, access, refresh } = res.data;

     // Save tokens + user
     localStorage.setItem("user", JSON.stringify(user));
     localStorage.setItem("access", access);
     localStorage.setItem("refresh", refresh);

     setMessage("Login successful!");

     // route based on role
     const targetRoute =
       user.role === "admin" ? "/admin/dashboard/home" : "/user/dashboard/home";

     setTimeout(() => navigate(targetRoute), 1200);
   } catch (err) {
     console.error("Login error:", err);
     setError(
       err?.response?.data?.message || "Invalid credentials, please try again."
     );
   } finally {
     setLoading(false);
   }
 };

  if (loading) return <Loader />;
  return (
    <div className="auth-container">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h2>Login</h2>
        {error && <p className="error">{error}</p>}
        {message && <p className="success">{message}</p>}
        <InputField
          label="Email"
          name="email"
          value={formData.email}
          onChange={handleChange}
        />
        <PasswordInput
          label="Password"
          name="password"
          value={formData.password}
          onChange={handleChange}
        />
        <Button type="submit" label="Login" style={{color:"#fff"}}/>
        <AuthLinks
          leftText="Forgot password?"
          leftTo="/forgot-password"
          rightText="Create an account"
          rightTo="/signup"
        />
      </form>
    </div>
  );
}
