from django.db import models
from complaints.models import Complaint
class Detection(models.Model):
    complaint = models.ForeignKey(
    Complaint,
    on_delete=models.CASCADE,
    null=True,
    blank=True,
    related_name="detections"
)

    # Mobile scanner info
    deviceId = models.CharField(max_length=100, null=True, blank=True)

    # Location
    locationText = models.CharField(max_length=255, null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    # Image captured by mobile camera
    detectedImage = models.ImageField(upload_to="detected_vehicle_pictures/", null=True, blank=True)

    detectedAt = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Detection of {self.complaint.plateNumber}"
    
class UnknownVehicle(models.Model):
    vehicleColor = models.CharField(max_length=50, null=True, blank=True)
    detectedAt = models.DateTimeField(auto_now_add=True)

    locationText = models.CharField(max_length=255, null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    image = models.ImageField(upload_to="unknown_vehicles/", null=True, blank=True)

    def __str__(self):
        return f"Unknown Vehicle - {self.detectedAt}"
