/** @format */

import "../styles/VehicleTable.css";

const VehicleTable = ({
  vehicles = [],
  title = "My Registered Vehicles",
  columns,
  limit // 👈 new prop
}) => {
  const defaultColumns = [
    { key: "plate", label: "Plate No" },
    { key: "model", label: "Model" },
    { key: "status", label: "Status" },
    { key: "lastSeen", label: "Last Seen" },
  ];

  const tableColumns = columns || defaultColumns;

  // 👇 apply limit safely
  const displayedVehicles = limit ? vehicles.slice(0, limit) : vehicles;

  return (
    <div className="vehicle-table">
      <div className="table-header">
        <h2>{title}</h2>
        {limit && vehicles.length > limit && (
          <span className="table-count">
            Showing {limit} of {vehicles.length}
          </span>
        )}
      </div>

      <table>
        <thead>
          <tr>
            {tableColumns.map((col) => (
              <th key={col.key}>{col.label}</th>
            ))}
          </tr>
        </thead>

        <tbody>
          {displayedVehicles.length > 0 ? (
            displayedVehicles.map((v, i) => (
              <tr key={i}>
                {tableColumns.map((col) => (
                  <td
                    key={col.key}
                    className={col.key === "status" ? `status ${v.status?.toLowerCase()}` : ""}
                  >
                    {col.key === "status" ? (
                      <span>{v[col.key]}</span>
                    ) : (
                      v[col.key] || "-"
                    )}
                  </td>
                ))}
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={tableColumns.length} className="no-data">
                No vehicles found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default VehicleTable;
