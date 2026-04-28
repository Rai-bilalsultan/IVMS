/** @format */
import "../styles/Auth.css";
import Loader from "./Loader";
export default function Button({
  label,
  onClick,
  type = "button",
  style,
}) {
  return (
    <button
      onClick={onClick}
      type={type}
      style={style}
    >
      {label}
    </button>
  );
}
