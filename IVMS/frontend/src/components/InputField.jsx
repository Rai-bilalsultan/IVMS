/** @format */
import "../styles/Auth.css";
export default function InputField({ label, type, value, onChange, name, placeholder, style }) {
  return (
    <div className="">
      <label>{label}</label>
      <input
        type={type}
        placeholder={placeholder}
        name={name}
        value={value}
        onChange={onChange}
        style={style}
      />
    </div>
  );
}
