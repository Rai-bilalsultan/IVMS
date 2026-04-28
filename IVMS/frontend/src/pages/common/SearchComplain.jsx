/** @format */
import { useState } from "react";
import "../../styles/SearchComplaint.css";
import InputField from "../../components/InputField";
import Button from "../../components/Button";
import {
  searchComplaintForAdmin,
  searchComplaintForUser,
} from "../../../api/complaintApi";
import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";

const PAGE_SIZE = 5;

export default function SearchComplaintPage() {
  const navigate = useNavigate();

  const [searchQuery, setSearchQuery] = useState("");
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);

  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const role = user.role;
  const email = user.email;

  const fetchResults = async (pageNumber = 1) => {
    if (!searchQuery.trim()) {
      setError("Please enter Plate Number, CNIC or Chassis Number.");
      return;
    }

    setLoading(true);
    setError("");
    setSuccessMessage("");

    try {
      let res;

      const params = {
        q: searchQuery,
        role,
        email,
        page: pageNumber,
        limit: PAGE_SIZE,
      };

      if (role === "admin") {
        res = await searchComplaintForAdmin(params);
      } else {
        res = await searchComplaintForUser(params);
      }

      setResults(res.data.complaints);
      setPage(res.data.page);
      setTotalPages(res.data.totalPages);

      setSuccessMessage(
        `Showing page ${res.data.page} of ${res.data.totalPages}`
      );
    } catch (err) {
      setResults([]);
      setError("No matching vehicle found.");
      console.error("Error searching complaints:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = () => {
    setPage(1);
    fetchResults(1);
  };

  const goBack = () => {
    navigate(-1);
  };

  return (
    <div className="complaint-container">
      <button className="back-button" onClick={goBack}>
        <ArrowLeft size={18} /> Back
      </button>

      <h2>Search Complaint</h2>

      {error && <p className="alert-error">{error}</p>}
      {successMessage && <p className="alert-success">{successMessage}</p>}

      {/* SEARCH BAR */}
      <div className="search-bar">
        <InputField
          style={{ width: "180%" }}
          type="text"
          placeholder="Enter Plate / CNIC / Chassis Number"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />

        <Button
          label={loading ? "Searching..." : "Search"}
          style={{ width: "20%", color: "#fff" }}
          onClick={handleSearch}
          disabled={loading}
        />
      </div>

      {/* RESULTS */}
      <div className="search-results">
        {results.length === 0 && !loading ? (
          <p className="hint-text">No results found.</p>
        ) : (
          results.map((item) => (
            <div key={item.id} className="search-result-item">
              <p>
                <strong>Owner:</strong> {item.ownerName}
              </p>
              <p>
                <strong>Email:</strong> {item.ownerEmail}
              </p>
              <p>
                <strong>Plate:</strong> {item.plateNumber}
              </p>

              <p>
                <strong>Status:</strong>{" "}
                <span className={`status ${item.status}`}>
                  {item.status.toUpperCase()}
                </span>
              </p>

              <Link
                to={`/${role}/dashboard/vehicle-details/${item.id}`}
                className="view-more-link"
              >
                View More
              </Link>
            </div>
          ))
        )}
      </div>

      {/* PAGINATION */}
      {totalPages > 1 && (
        <div className="pagination">
          <button disabled={page === 1} onClick={() => fetchResults(page - 1)}>
            Prev
          </button>

          <span>
            Page {page} of {totalPages}
          </span>

          <button
            disabled={page === totalPages}
            onClick={() => fetchResults(page + 1)}
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
}
