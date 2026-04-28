/** @format */
import { useState } from "react";
import "../../styles/Complain.css";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import { registerComplaint } from "../../../api/complaintApi";
import { ArrowLeft } from "lucide-react";
import { useNavigate } from "react-router-dom";
import Loader from "../../components/Loader";

export default function SubmitComplaintPage() {
  const navigate = useNavigate();
  const user = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user"))
    : null;
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    ownerName: "",
    ownerEmail: "",
    ownerPhone: "",
    ownerCnic: "",
    vehicleMake: "",
    vehicleModel: "",
    vehicleVariant: "",
    vehicleColor: "",
    plateNumber: "",
    chassisNumber: "",
    complaintDescription: "",
    vehiclePicture: null,
  });

  const handleChange = (e) => {
    const { name, value, files } = e.target;
    setFormData({
      ...formData,
      [name]: files ? files[0] : value,
    });
  };

  const goBack = () => {
    if (window.history.length > 1) {
      navigate(-1);
    } else {
      navigate("/"); // fallback route if no history
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    // Auto fill user data if user is normal user
    let finalData = { ...formData };
    if (user && user.role === "user") {
      finalData.ownerName = user.fullName;
      finalData.ownerEmail = user.email;
      finalData.ownerPhone = user.phoneNumber;
      finalData.ownerCnic = user.cnic;
    }

    const form = new FormData();
    for (let key in finalData) {
      form.append(key, finalData[key]);
    }

    try {
      console.log(finalData)
      const response = await registerComplaint(finalData);
      if (response.data.email_status.includes("Failed")) {
        setMessage(
          "Complaint registered successfully, but email could not be sent."
        );
      } else {
        setMessage("Complaint registered successfully and email sent!");
      }
      // Reset form
      setFormData({
        ownerEmail: "",
        ownerPhone: "",
        ownerCnic: "",
        vehicleMake: "",
        vehicleModel: "",
        vehicleVariant: "",
        vehicleColor: "",
        plateNumber: "",
        chassisNumber: "",
        complaintDescription: "",
        vehiclePicture: null,
      });
    } catch (error) {
      setError("Something went wrong! Try again");
      console.error("Error submitting complaint:", error);
    } finally {
      setLoading(false);
    }
  };
  if (loading) return <Loader />;
  return (
    <div className="complaint-container">
      <button className="back-button" onClick={goBack}>
        <ArrowLeft size={18} /> Back
      </button>
      <h2>Submit a Complaint</h2>
      {error && <p className="error">{error}</p>}
      {message && <p className="success">{message}</p>}
      <form className="complaint-form" onSubmit={handleSubmit}>
        {user?.role === "admin" && (
          <>
            <h3>Owner Details</h3>
            <div className="form-row">
              <InputField
                label="Owner Email"
                name="ownerEmail"
                type="email"
                value={formData.ownerEmail}
                placeholder={"Ex. example@example.com"}
                onChange={handleChange}
                style={{ width: "90%" }}
              />
              <InputField
                label="Owner Name"
                name="ownerName"
                type="text"
                value={formData.ownerName}
                placeholder={"Ex. Ali"}
                onChange={handleChange}
                style={{ width: "90%" }}
              />

              <InputField
                label="Owner Phone"
                name="ownerPhone"
                type="text"
                value={formData.ownerPhone}
                placeholder={"Ex. 0332332332"}
                onChange={handleChange}
                style={{ width: "90%" }}
              />
            </div>

            <InputField
              label="Owner CNIC"
              name="ownerCnic"
              type="text"
              value={formData.ownerCnic}
              placeholder={"Ex. 32123-1233231-2"}
              onChange={handleChange}
              style={{ width: "90%" }}
            />
          </>
        )}

        <h3>Vehicle Details</h3>

        <div className="form-row">
          <InputField
            label="Make"
            name="vehicleMake"
            value={formData.vehicleMake}
            placeholder={"Ex. Honda"}
            onChange={handleChange}
            style={{ width: "90%" }}
          />

          <InputField
            label="Model"
            name="vehicleModel"
            value={formData.vehicleModel}
            placeholder={"Ex. 2025"}
            onChange={handleChange}
            style={{ width: "90%" }}
          />
        </div>

        <div className="form-row">
          <InputField
            label="Variant"
            name="vehicleVariant"
            value={formData.vehicleVariant}
            placeholder={"Ex. VXL"}
            onChange={handleChange}
            style={{ width: "90%" }}
          />

          <InputField
            label="Color"
            name="vehicleColor"
            value={formData.vehicleColor}
            onChange={handleChange}
            placeholder={"Ex. Black"}
            style={{ width: "90%" }}
          />
        </div>

        <div className="form-row">
          <InputField
            label="Plate Number"
            name="plateNumber"
            value={formData.plateNumber}
            placeholder={"Ex. AAA-123"}
            onChange={handleChange}
            style={{ width: "90%" }}
          />

          <InputField
            label="Chassis Number"
            name="chassisNumber"
            value={formData.chassisNumber}
            placeholder={"Ex. 4562ASA5621"}
            onChange={handleChange}
            style={{ width: "90%" }}
          />
        </div>

        <label>Complaint Description</label>
        <textarea
          name="complaintDescription"
          rows="4"
          value={formData.complaintDescription}
          placeholder={"Ex. White Honda Civic got stolen on 12th May from main murree road..."}
          onChange={handleChange}
        />

        <InputField
          label="Upload Vehicle Image"
          type="file"
          name="vehiclePicture"
          onChange={handleChange}
          style={{ width: "90%" }}
        />

        <Button label="Submit Complaint" type="submit" />
      </form>
    </div>
  );
}
