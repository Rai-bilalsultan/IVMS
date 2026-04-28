from django.db import models
from detection.models import Detection
class Alert(models.Model):
    ALERT_TYPE = (
        ("vehicle_detected", "Vehicle Detected"),
    )

    detection = models.ForeignKey(Detection, on_delete=models.CASCADE, related_name="alerts")

    alertType = models.CharField(max_length=50, choices=ALERT_TYPE, default="vehicle_detected")
    alertMessage = models.TextField()

    # Store snapshot sent to owner (can reuse detection image or generate resized version)
    alertImage = models.ImageField(upload_to="alerts/", null=True, blank=True)

    sentAt = models.DateTimeField(auto_now_add=True)

    isRead = models.BooleanField(default=False)  # For showing in user app

    def __str__(self):
        return f"Alert for {self.detection.complaint.plateNumber}"