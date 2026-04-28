/** @format */

import { useState } from "react";
import { Eye, EyeOff } from "lucide-react";
import InputField from "./InputField";

export default function PasswordInput({ label, name, value, onChange }) {
  const [showPassword, setShowPassword] = useState(false);

  const togglePassword = () => setShowPassword((prev) => !prev);

  return (
    <div
      className="input-field"
      style={{ position: "relative", marginBottom: "1rem" }}
    >
      <label
        htmlFor={name}
        style={{ display: "block", marginBottom: "0.3rem" }}
      >
        {label}
      </label>
      <InputField
        id={name}
        name={name}
        type={showPassword ? "text" : "password"}
        value={value}
        onChange={onChange}
      />
      <span
        onClick={togglePassword}
        style={{
          position: "absolute",
          right: "1rem",
          top: "56%",
          transform: "translateY(-50%)",
          cursor: "pointer",
          color: "#555",
          fontSize: "1.2rem",
        }}
      >
        {showPassword ? <EyeOff /> : <Eye />}
      </span>
    </div>
  );
}
