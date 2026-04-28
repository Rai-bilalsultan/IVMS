/** @format */

import "./styles/MapPreview.css";

const MapPreview = ({
  height = 250,
  locations = [
    { name: "Blue Area", latitude: 33.6844, longitude: 73.0479 },
  ],
}) => {
  // Generate marker string for Google Maps embed
  const markers = locations
    .map((loc) => `${loc.latitude},${loc.longitude}`)
    .join("|");

  const mapUrl = `https://maps.google.com/maps?q=${markers}&t=&z=13&ie=UTF8&iwloc=&output=embed`;

  return (
    <div className="map-preview">
      <h2>Map Preview</h2>
      <iframe
        title="Map"
        src={mapUrl}
        width="100%"
        height={height}
        style={{ border: 0, borderRadius: "10px" }}
        allowFullScreen
        loading="lazy"
      ></iframe>
    </div>
  );
};

export default MapPreview;
