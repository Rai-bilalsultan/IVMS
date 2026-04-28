# views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from .models import Alert
from .serializers import AlertSerializer

# 1️⃣ List alerts for a user
class UserAlertsView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        role = request.query_params.get("role")
        email = request.query_params.get("email")
        if not email:
            return Response({"error": "Email is required"}, status=400)
        
        if role == "admin":
            alerts = Alert.objects.all().order_by("-sentAt")

        else:
            alerts = Alert.objects.filter(
            detection__complaint__ownerEmail=email
        ).order_by("-sentAt")

        serializer = AlertSerializer(alerts, many=True)
        return Response(serializer.data, status=200)


# 2️⃣ Single alert detail & mark read
class AlertDetailView(APIView):
    permission_classes = [AllowAny]

    def get_object(self, alert_id):
        try:
            return Alert.objects.select_related("detection__complaint").get(id=alert_id)
        except Alert.DoesNotExist:
            return None

    def get(self, request, alert_id):
        alert = self.get_object(alert_id)
        if not alert:
            return Response({"error": "Alert not found"}, status=status.HTTP_404_NOT_FOUND)

        # Serialize alert
        serializer = AlertSerializer(alert)
        data = serializer.data

        # Add detection image URL if available
        if alert.detection:
            if hasattr(alert.detection, "detectedImage") and alert.detection.detectedImage:
                # Include full URL if using Django storage
                request_scheme = request.scheme
                request_host = request.get_host()
                data["alertImage"] = f"{request_scheme}://{request_host}{alert.detection.detectedImage.url}"
            else:
                data["alertImage"] = None
        else:
            data["alertImage"] = None

        return Response(data, status=200) 

    def patch(self, request, alert_id):
        alert = self.get_object(alert_id)
        if not alert:
            return Response({"error": "Alert not found"}, status=status.HTTP_404_NOT_FOUND)

        alert.isRead = True
        alert.save()
        return Response({"message": "Marked as read", "id": alert.id, "isRead": alert.isRead}, status=200)