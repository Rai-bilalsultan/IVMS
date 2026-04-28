from django.db import models

class Vehicle(models.Model):

    # Owner Info
    owner_name = models.CharField(max_length=255)
    father_name = models.CharField(max_length=255)
    cnic_or_passport = models.CharField(max_length=30)

    # Registration
    registration_date = models.DateField()

    # Identity
    chassis_number = models.CharField(max_length=100, unique=True)
    engine_number = models.CharField(max_length=100, unique=True)
    number_plate = models.CharField(max_length=20, unique=True)

    # Vehicle Info
    make = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    vehicle_class = models.CharField(max_length=100)
    body_type = models.CharField(max_length=100)
    color = models.CharField(max_length=50)

    # Specs
    manufacture_year = models.IntegerField()
    engine_cc = models.IntegerField()
    horse_power = models.IntegerField(null=True, blank=True)

    # Tax
    token_tax = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    def __str__(self):
        return f"{self.number_plate} - {self.owner_name}"