from django.db import models
from detection.models import Detection
class PredictionRoute(models.Model):
    detection = models.ForeignKey(Detection, on_delete=models.CASCADE, related_name="predictedRoutes")

    routeName = models.CharField(max_length=255)
    probability = models.FloatField(default=0.0)
    pathCoordinates = models.JSONField(null=True, blank=True)
    createdAt = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Prediction for {self.detection.complaint.plateNumber}"
