import openrouteservice
from django.conf import settings

client = openrouteservice.Client(key=settings.OPENROUTE_API_KEY)


def predict_routes(lat, lng):
    origin = [lng, lat]  # ORS uses [lng, lat]

    # Simulated escape directions
    destinations = [
        [lng + 0.02, lat],   # east
        [lng - 0.02, lat],   # west
        [lng, lat + 0.02],   # north
        [lng, lat - 0.02],   # south
    ]

    routes = []

    for dest in destinations:
        try:
            result = client.directions(
                coordinates=[origin, dest],
                profile="driving-car",
                format="geojson"
            )

            route = result["features"][0]

            summary = route["properties"]["summary"]
            geometry = route["geometry"]

            routes.append({
                "distance": round(summary["distance"] / 1000, 2),  # km
                "duration": round(summary["duration"] / 60, 2),   # mins
                "geometry": geometry,  # full path
            })

        except Exception as e:
            print("ORS error:", e)

    return routes