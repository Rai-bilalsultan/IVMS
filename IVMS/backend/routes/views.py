from rest_framework.views import APIView
from rest_framework.response import Response
from .route_prediction import predict_routes

class RoutePredictionAPIView(APIView):
    def post(self, request):
        plate = request.data.get("plateNumber")
        location = request.data.get("current_location")

        if not plate or not location:
            return Response({"error": "plateNumber & current_location required"}, status=400)

        predictions = predict_routes(plate, location)
        return Response({"predictions": predictions})
