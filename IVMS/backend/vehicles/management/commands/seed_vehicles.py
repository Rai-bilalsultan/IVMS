from django.core.management.base import BaseCommand
from vehicles.models import Vehicle
import random
from datetime import date
import uuid


class Command(BaseCommand):
    help = "Seed 100 unique vehicles into the database"

    def handle(self, *args, **kwargs):
        makes = ["Toyota", "Honda", "Suzuki", "Kia", "Hyundai"]
        models = ["Corolla", "Civic", "Alto", "Sportage", "Elantra"]
        colors = ["White", "Black", "Silver", "Blue", "Red"]

        vehicle_list = []

        for i in range(100):

            unique_id = uuid.uuid4().hex[:10].upper()

            v = Vehicle(
                owner_name=f"Owner {unique_id}",
                father_name=f"Father {unique_id}",
                cnic_or_passport=f"12345-12345{i:03d}-{i%10}",

                registration_date=date(
                    2020,
                    random.randint(1, 12),
                    random.randint(1, 28)
                ),

                # ✅ guaranteed unique
                chassis_number=f"CHS-{unique_id}",
                engine_number=f"ENG-{unique_id}",
                number_plate=f"ABC-{i:03d}-{unique_id[:3]}",

                make=random.choice(makes),
                model=random.choice(models),
                vehicle_class="Car",
                body_type="Sedan",
                color=random.choice(colors),

                manufacture_year=random.randint(2015, 2024),
                engine_cc=random.randint(800, 3000),
                horse_power=random.randint(70, 200),
                token_tax=random.randint(1000, 5000),
            )

            vehicle_list.append(v)

        Vehicle.objects.bulk_create(vehicle_list)

        self.stdout.write(self.style.SUCCESS("Successfully inserted 100 UNIQUE vehicles"))