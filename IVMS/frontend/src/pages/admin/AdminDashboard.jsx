/** @format */
import { useNavigate } from "react-router-dom";
import DashboardCard from "../../components/DashboardCard";
import "../../styles/Dashboard.css";
import { FileText, Search, CheckCircle, FileCheck } from "lucide-react";
import { useEffect, useState } from "react";
import Loader from "../../components/Loader";
import { fetchAllComplaints } from "../../../api/complaintApi";
import VehicleTable from "../../components/VehicleTable";
import MapPreview from "../../components/MapPreview";
import { fetchDetections } from "../../../api/detectionApi";
import { formatTime } from "../../lib/formatTime";

const AdminDashboard = () => {
  const navigate = useNavigate();
  const [complaints, setComplaints] = useState([]);
  const [detections, setDetections] = useState([]);
  const [loading, setLoading] = useState(true);

  const user = localStorage.getItem("user")
    ? JSON.parse(localStorage.getItem("user"))
    : null;

  useEffect(() => {
    if (!user) {
      navigate("/login");
      return;
    }

    const fetchData = async () => {
      try {
        setLoading(true);

        const [complaintsRes, detectionsRes] = await Promise.all([
          fetchAllComplaints(),
          fetchDetections(),
        ]);

        setComplaints(complaintsRes.data.complaints);
        console.log(detectionsRes)
        const formattedDetections = detectionsRes.map((d) => ({
          plate: d.plateNumber,
          model: d.vehicleModel || "Unknown",
          status: d.status || "Detected",
          lastSeen: formatTime(d.detectedAt),
          location: d.location,
        }));


        setDetections(formattedDetections);
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [user?.email, navigate]);

  const totalReports = complaints.length;
  const pendingInvestigations = complaints.filter(
    (c) => c.status === "investigating"
  ).length;
  const resolvedCases = complaints.filter((c) => c.status === "resolved").length;
  const closedCases = complaints.filter((c) => c.status === "closed").length;

  if (loading) return <Loader />;

  return (
    <div className="dashboard-page">
      <div className="dashboard-header">
        <h2>Dashboard Overview</h2>
      </div>

      <div className="overview-cards">
        <DashboardCard
          title="Reports Submitted"
          value={totalReports}
          icon={<FileText />}
        />
        <DashboardCard
          title="Pending Investigations"
          value={pendingInvestigations}
          icon={<Search />}
        />
        <DashboardCard
          title="Resolved Cases"
          value={resolvedCases}
          icon={<CheckCircle />}
        />
        <DashboardCard
          title="Closed Cases"
          value={closedCases}
          icon={<FileCheck />}
        />
      </div>

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

export default AdminDashboard;