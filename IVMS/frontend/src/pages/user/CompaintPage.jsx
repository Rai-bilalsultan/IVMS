/** @format */
import { useEffect, useState } from "react";
import axios from "axios";
import Loader from "../../components/Loader";
import ComplaintCard from "../../components/ComplaintCard";
import ComplaintDetailModal from "../../components/ComplaintDetailModal";
import "../../styles/ComplaintsPage.css";

const API = import.meta.env.VITE_API_URL || "http://localhost:8000/";

export default function ComplaintsPage() {
  const [complaints, setComplaints] = useState([]);
  const [selectedComplaint, setSelectedComplaint] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const limit = 5; // complaints per page

  const user = JSON.parse(localStorage.getItem("user"));
  const email = user?.email;

  useEffect(() => {
    const fetchComplaints = async () => {
      setLoading(true);
      try {
        const res = await axios.get(`${API}complaints/`, {
          params: { email, page: currentPage, limit },
        });
        setComplaints(res.data.complaints || []);
        const total = res.data.total || 0;
        setTotalPages(Math.ceil(total / limit));
      } catch (err) {
        console.error("Error fetching complaints:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchComplaints();
  }, [email, currentPage]);

  if (loading) return <Loader />;

  const handlePrev = () => setCurrentPage((p) => Math.max(p - 1, 1));
  const handleNext = () => setCurrentPage((p) => Math.min(p + 1, totalPages));

  return (
    <div className="complaints-container">
      <h2>My Complaints</h2>
      {complaints.length === 0 ? (
        <p>No complaints posted yet.</p>
      ) : (
        complaints.map((c) => (
          <ComplaintCard
            key={c.id}
            complaint={c}
            onView={(complaint) => setSelectedComplaint(complaint)}
          />
        ))
      )}

      <div className="pagination">
        <button onClick={handlePrev} disabled={currentPage === 1}>
          Previous
        </button>
        <span>
          {currentPage} of {totalPages}
        </span>
        <button onClick={handleNext} disabled={currentPage === totalPages}>
          Next
        </button>
      </div>

      <ComplaintDetailModal
        complaint={selectedComplaint}
        onClose={() => setSelectedComplaint(null)}
      />
    </div>
  );
}
