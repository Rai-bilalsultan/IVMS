/** @format */
import { Link } from "react-router-dom";
import "../../styles/NotFoundPage.css";

export default function NotFound() {
  return (
    <div className="notfound-container">
      <h1 className="notfound-title">404</h1>
      <p className="notfound-subtitle">Oops! The page you're looking for doesn't exist.</p>

      <Link to="/" className="notfound-btn">
        Go Back Home
      </Link>
    </div>
  );
}
