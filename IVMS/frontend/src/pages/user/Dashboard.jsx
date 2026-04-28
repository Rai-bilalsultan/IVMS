import { useNavigate } from "react-router-dom";
import DashboardCard from "../../components/DashboardCard";
import "../../styles/Dashboard.css";
import { FileText, Search, CheckCircle, FileCheck } from "lucide-react";
import { useEffect, useState } from "react";
import Loader from "../../components/Loader";
import { fetchUserComplaints } from "../../../api/complaintApi";
import VehicleTable from "../../components/VehicleTable";
import MapPreview from "../../components/MapPreview";
import axios from "axios";
import { formatTime } from "../../lib/formatTime";

const Dashboard = () => {
  const navigate = useNavigate();

  const [complaints, setComplaints] = useState([]);
  const [detections, setDetections] = useState([]);
  const [loading, setLoading] = useState(true);

  const user = JSON.parse(localStorage.getItem("user") || "null");

  useEffect(() => {
    if (!user) {
      navigate("/login");
      return;
    }

    const fetchData = async () => {
      try {
        setLoading(true);

        // =====================
        // USER COMPLAINTS
        // =====================
        const complaintsRes = await fetchUserComplaints(user.email);
        const userComplaints = complaintsRes?.data?.complaints || [];
        setComplaints(userComplaints);

        // =====================
        // DETECTIONS
        // =====================
        const detectionsRes = await axios.get(
          "http://127.0.0.1:8000/detections/",
          {
            params: {
              role: user.role,
              email: user.email,
            },
          }
        );

        const list = Array.isArray(detectionsRes.data)
          ? detectionsRes.data
          : [];

        const formatted = list.map((d) => ({
          plate: d.plateNumber,
          model: d.vehicleModel || "Unknown",
          status: d.status || "Detected",
          lastSeen: formatTime(d.detectedAt),
          location: d.location,
        }));

        setDetections(formatted);
      } catch (err) {
        console.error("Dashboard error:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [navigate, user?.email, user?.role]);

  // =====================
  // STATS
  // =====================
  const totalReports = complaints.length;
  const pending = complaints.filter(c => c.status === "investigating").length;
  const resolved = complaints.filter(c => c.status === "resolved").length;
  const closed = complaints.filter(c => c.status === "closed").length;

  if (loading) return <Loader />;

  return (
    <div className="dashboard-page">
      <div className="dashboard-header">
        <h2>User Dashboard</h2>
      </div>

      {/* SAME AS ADMIN */}
      <div className="overview-cards">
        <DashboardCard title="Reports Submitted" value={totalReports} icon={<FileText />} />
        <DashboardCard title="Pending Investigations" value={pending} icon={<Search />} />
        <DashboardCard title="Resolved Cases" value={resolved} icon={<CheckCircle />} />
        <DashboardCard title="Closed Cases" value={closed} icon={<FileCheck />} />
      </div>

      {/* SAME GRID AS ADMIN */}
      <div className="dashboard-grid">
        <div className="vehicle-card">
          <VehicleTable
            vehicles={detections}
            limit={10}
            title="Latest Detections"
          />
        </div>

        <div className="map-card">
          <MapPreview height={320} />
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
