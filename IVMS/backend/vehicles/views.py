from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db.models import Q

from .models import Vehicle
from .serializers import VehicleSerializer


# ➕ ADD VEHICLE
class VehicleCreateView(generics.CreateAPIView):
    queryset = Vehicle.objects.all()
    serializer_class = VehicleSerializer


# 🔍 SEARCH VEHICLE
class VehicleSearchView(APIView):

    def get(self, request):
        query = request.GET.get("q")

        if not query:
            return Response({"error": "q parameter required"}, status=400)

        vehicles = Vehicle.objects.filter(
            Q(chassis_number__icontains=query) |
            Q(number_plate__icontains=query)
        )

        serializer = VehicleSerializer(vehicles, many=True)
        return Response(serializer.data)