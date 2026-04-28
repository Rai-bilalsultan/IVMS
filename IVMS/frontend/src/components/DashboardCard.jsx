/** @format */

import "./styles/DashboardCard.css";

const DashboardCard = ({ title, value, icon }) => {
  return (
    <div className="dash-card">
      <div className="card-icon">{icon}</div>
      <div>
        <h3>{title}</h3>
        <p>{value}</p>
      </div>
    </div>
  );
};

export default DashboardCard;
