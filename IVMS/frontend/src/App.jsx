/** @format */
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import ProtectedRoute from "./ProtectedRoute";
import "./App.css";
import DashboardLayout from "./layouts/MainLayout";
import Signup from "./pages/auth/Signup";
import Login from "./pages/auth/Login";
import ForgotPassword from "./pages/auth/ForgotPassword";
import ResetPassword from "./pages/auth/ResetPassword";
import VerifyOTP from "./pages/auth/VerifyOtp";
import ComplaintMainPage from "./pages/common/MainComplaint";
import SearchComplaintPage from "./pages/common/SearchComplain";
import SubmitComplaintPage from "./pages/common/SubmitComplain";
import CameraMainPage from "./pages/common/Camera";
import VehicleDetailsPage from "./pages/common/VehicleDetails";
import EditProfile from "./pages/common/EditPage";
import AlertsPage from "./pages/common/AlertPage";
import NotFound from "./pages/common/NotFoundPage";
import UserDashboard from "./pages/user/Dashboard";
import UserComplaints from "./pages/user/CompaintPage";
import AdminDashboard from "./pages/admin/AdminDashboard";
import AdminComplaints from "./pages/admin/AdminComplaint";
import ConfigureCamera from "./pages/admin/ConfigureCamera";
import AlertDetailsPage from "./pages/common/AlertDetailsPage";
import UnknownVehiclesPage from "./pages/admin/UnknownVehiclesPage";
import DetectionsPage from "./pages/common/DetectionsPage";
import DetectionDetailsPage from "./pages/common/DetectionDetailsPage";
import AdminComplaintReview from "./pages/admin/AdminComplaintReview";

const renderSharedDashboardRoutes = () => (
  <>
    <Route path="complain" element={<ComplaintMainPage />} />
    <Route path="complain/search" element={<SearchComplaintPage />} />
    <Route path="complain/submit" element={<SubmitComplaintPage />} />
    <Route path="camera" element={<CameraMainPage />} />
    <Route path="vehicle-details/:id" element={<VehicleDetailsPage />} />
    <Route path="alerts" element={<AlertsPage />} />
    <Route path="edit-profile" element={<EditProfile />} />
    <Route path="detections" element={<DetectionsPage />} />
    <Route path="detections/:id" element={<DetectionDetailsPage />} />
  </>
);

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/verify-otp" element={<VerifyOTP />} />
        <Route path="/reset-password" element={<ResetPassword />} />
        <Route element={<ProtectedRoute allowedRoles={["user"]} />}>
          <Route path="/user/dashboard" element={<DashboardLayout />}>
            <Route index element={<UserDashboard />} />
            <Route path="home" element={<UserDashboard />} />
            {renderSharedDashboardRoutes()}
            <Route path="my-complaints" element={<UserComplaints />} />
            <Route path="alerts/:alertId" element={<AlertDetailsPage />} />
          </Route>
        </Route>
        <Route element={<ProtectedRoute allowedRoles={["admin"]} />}>
          <Route path="/admin/dashboard" element={<DashboardLayout />}>
            <Route index element={<AdminDashboard />} />
            <Route path="home" element={<AdminDashboard />} />
            {renderSharedDashboardRoutes()}
            <Route path="camera/configure" element={<ConfigureCamera />} />
            <Route path="my-complaints" element={<AdminComplaints />} />
            <Route path="alerts/:alertId" element={<AlertDetailsPage />} />
            <Route path="unknown-vehicles" element={<UnknownVehiclesPage />} />
            <Route path="verify-complains" element={<AdminComplaintReview />} />
          </Route>
        </Route>
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
