from django.db import models

class Complaint(models.Model):
    STATUS_CHOICES = (
        ("pending", "Pending"),
        ("rejected", "Rejected"),
        ("investigating", "Investigating"),
        ("resolved", "Resolved"),
        ("closed", "Closed"),
    )

    # Owner Info
    ownerName = models.CharField(max_length=100)
    ownerEmail = models.EmailField()
    ownerPhone = models.CharField(max_length=20, null=True, blank=True)
    ownerCnic = models.CharField(max_length=15)

    # Vehicle Info
    vehicleMake = models.CharField(max_length=50)
    vehicleModel = models.CharField(max_length=50)
    vehicleVariant = models.CharField(max_length=50, blank=True, null=True)
    vehicleColor = models.CharField(max_length=30)
    plateNumber = models.CharField(max_length=20)
    chassisNumber = models.CharField(max_length=50, blank=True, null=True)
    vehiclePicture = models.ImageField(upload_to="vehicle_pictures/", null=True, blank=True)

    # Complaint Info
    complaintDescription = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="pending")

    createdAt = models.DateTimeField(auto_now_add=True)
    verified_by_email = models.EmailField(null=True, blank=True)
    verified_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.ownerName} — {self.plateNumber}"
