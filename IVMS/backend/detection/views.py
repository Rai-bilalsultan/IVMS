import os
import uuid
import cv2

from django.conf import settings
from django.core.files.base import ContentFile
from django.utils.timezone import now
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string

from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework import status

from complaints.models import Complaint
from ai_module.plate_detector import detect_plate_and_read
from users.models import CustomUser
from .models import Detection, UnknownVehicle
from .utils.route_prediction import predict_routes


# Folder for detected vehicle images
DETECTED_IMAGES_FOLDER = os.path.join(settings.BASE_DIR, "media/detected_vehicle_pictures")
os.makedirs(DETECTED_IMAGES_FOLDER, exist_ok=True)


class DetectVehicleAPIView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    permission_classes = [AllowAny]

    def send_alert_email(self, complaint, plate, location):
        admin_emails = list(CustomUser.objects.filter(role="admin").values_list("email", flat=True))
        recipients = [complaint.ownerEmail] + admin_emails

        html_content = render_to_string(
            "email/vehicle_detected_alert.html",
            {
                "ownerName": complaint.ownerName,
                "plateNumber": plate,
                "vehicleModel": complaint.vehicleModel,
                "vehicleColor": complaint.vehicleColor,
                "location": location,
                "time": now(),
                "year": now().year,
            }
        )

        email = EmailMultiAlternatives(
            subject="🚨 Stolen Vehicle Detected",
            body="Your stolen vehicle has been detected.",
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=recipients,
        )

        email.attach_alternative(html_content, "text/html")
        email.send(fail_silently=False)

    # ================== POST (DETECTION) ==================
    def post(self, request):
        image = request.FILES.get("images")
        latitude = request.data.get("latitude")
        longitude = request.data.get("longitude")
        if not image:
            return Response({"error": "Image required"}, status=status.HTTP_400_BAD_REQUEST)
        latitude = float(latitude)
        longitude = float(longitude)
        temp_filename = f"{uuid.uuid4().hex}.jpg"
        temp_path = os.path.join(DETECTED_IMAGES_FOLDER, temp_filename)

        # Save temp image
        with open(temp_path, "wb") as f:
            for chunk in image.chunks():
                f.write(chunk)

        try:
            result = detect_plate_and_read(temp_path)
            plate = None
            if result:
                plate = result

            if plate:
                plate = str(plate).replace(" ", "").replace("-", "").upper()
            print("Detected plate:", plate)

            # =========================================================
            # 🚗 IF NO PLATE → SAVE UNKNOWN VEHICLE
            # =========================================================
            if not plate:

                image_array = cv2.imread(temp_path)
                if image_array is None:
                    return Response({"error": "Invalid image"}, status=400)

                # Simple color detection
                avg_color = image_array.mean(axis=(0, 1))
                blue, green, red = avg_color

                if red > green and red > blue:
                    color = "Red"
                elif blue > red and blue > green:
                    color = "Blue"
                elif green > red and green > blue:
                    color = "Green"
                else:
                    color = "Unknown"

                filename = f"unknown_{uuid.uuid4().hex}.jpg"

                success, buffer = cv2.imencode(".jpg", image_array)
                image_bytes = buffer.tobytes()

                unknown = UnknownVehicle.objects.create(
                    vehicleColor=color,
                    locationText="Camera 1 - Parking Area",
                    latitude=latitude,
                    longitude=longitude,
                )

                unknown.image.save(filename, ContentFile(image_bytes), save=True)

                return Response({
                    "status": "unknown_vehicle_saved",
                    "color": color,
                    "id": unknown.id,
                    "latitude": latitude,
                    "longitude": longitude,
                })

            # =========================================================
            # 🚗 IF PLATE FOUND → NORMAL DETECTION
            # =========================================================
            plate = plate.replace(" ", "").replace("-", "").upper()

            complaint = Complaint.objects.filter(plateNumber__iexact=plate).first()
            location = "Camera 1 - Parking Area"

            detection = Detection.objects.create(
                complaint=complaint if complaint else None,
                deviceId="CAMERA_1",
                locationText=location,
                latitude=latitude,
                longitude=longitude,
            )

            # Save detected image
            image_array = cv2.imread(temp_path)
            if image_array is None:
                return Response({"error": "Invalid image"}, status=400)

            plate_filename = f"plate_{uuid.uuid4().hex}.jpg"

            success, buffer = cv2.imencode(".jpg", image_array)
            image_bytes = buffer.tobytes()

            detection.detectedImage.save(plate_filename, ContentFile(image_bytes), save=True)
            routes = predict_routes(latitude, longitude)

            # If vehicle is stolen → send email
            if complaint:
                self.send_alert_email(complaint, plate, location)
                return Response({
                    "status": "stolen_vehicle_detected",
                    "plate": plate,
                    "complaint_id": complaint.id,
                    "latitude": latitude,
                    "longitude": longitude,
                    "routes": routes
                })

            return Response({
                "status": "vehicle_not_reported",
                "plate": plate,
                "routes": routes
            })

        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    # ================== GET (LIST + DETAIL) ==================
    def get(self, request, id=None):
        """
        If id is provided → return single detection with routes
        If not → return list
        """

        # ================== DETAIL VIEW ==================
        if id is not None:
            try:
                detection = Detection.objects.select_related("complaint").get(id=id)
            except Detection.DoesNotExist:
                return Response({"error": "Not found"}, status=404)

            complaint = detection.complaint

            data = {
                "id": detection.id,
                "plateNumber": complaint.plateNumber if complaint else None,
                "vehicleModel": complaint.vehicleModel if complaint else None,
                "vehicleColor": complaint.vehicleColor if complaint else None,
                "status": complaint.status if complaint else "Detected",
                "detectedAt": detection.detectedAt,
                "ownerName": complaint.ownerName if complaint else None,
                "ownerEmail": complaint.ownerEmail if complaint else None,
                "location": detection.locationText,
                "latitude": detection.latitude,
                "longitude": detection.longitude,
                "image": detection.detectedImage.url if detection.detectedImage else None,
                "routes": predict_routes(detection.latitude, detection.longitude),
            }

            return Response(data)

        # ================== LIST VIEW ==================
        role = request.query_params.get("role", "").lower()
        email = request.query_params.get("email", "").lower()

        if role == "admin":
            detections = Detection.objects.select_related("complaint").all().order_by("-detectedAt")
        else:
            detections = Detection.objects.select_related("complaint").filter(
                complaint__ownerEmail=email
            ).order_by("-detectedAt")

        data = []

        for d in detections:
            complaint = d.complaint

            data.append({
                "id": d.id,
                "plateNumber": complaint.plateNumber if complaint else None,
                "vehicleModel": complaint.vehicleModel if complaint else None,
                "vehicleColor": complaint.vehicleColor if complaint else None,
                "status": complaint.status if complaint else "Detected",
                "detectedAt": d.detectedAt,
                "ownerName": complaint.ownerName if complaint else None,
                "ownerEmail": complaint.ownerEmail if complaint else None,
                "location": d.locationText,
                "latitude": d.latitude,
                "longitude": d.longitude,
                "image": d.detectedImage.url if d.detectedImage else None,
            })

        return Response(data)
   
class AdminUnknownVehiclesAPIView(APIView):
    permission_classes = [AllowAny]  # same as your Detect API

    def get(self, request):
        role = request.query_params.get("role", "").lower()
        print("Role:", role)  # Debugging line

        # 🔐 Manual admin check
        if role != "admin":
            return Response(
                {"error": "Access denied"},
                status=status.HTTP_403_FORBIDDEN
            )

        vehicles = UnknownVehicle.objects.all().order_by("-detectedAt")

        data = []
        for v in vehicles:
            data.append({
                "id": v.id,
                "vehicleColor": v.vehicleColor,
                "detectedAt": v.detectedAt,
                "location": v.locationText,
                "latitude": v.latitude,
                "longitude": v.longitude,
                "image": v.image.url if v.image else None,
            })

        return Response(data, status=200)