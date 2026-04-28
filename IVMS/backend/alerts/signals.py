from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Alert
from detection.models import Detection
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
import re


# 🔧 Helper to clean group names
def clean_group_name(name):
    return re.sub(r"[^a-zA-Z0-9_\-\.]", "_", name)


@receiver(post_save, sender=Detection)
def create_alert_when_detected(sender, instance, created, **kwargs):
    if not created:
        return

    complaint = instance.complaint

    # ✅ Safe message
    message = f"Your stolen vehicle with plate {complaint.plateNumber} was detected at {instance.locationText or 'Unknown location'}."

    # ✅ Create alert
    alert = Alert.objects.create(
        detection=instance,
        alertMessage=message,
        alertImage=instance.detectedImage
    )

    # ==============================
    # 🔥 REAL-TIME ALERT (FIXED)
    # ==============================

    channel_layer = get_channel_layer()

    alert_data = {
        "id": alert.id,
        "alertType": alert.alertType,
        "alertMessage": alert.alertMessage,
        "alertImage": alert.alertImage.url if alert.alertImage else None,
        "sentAt": str(alert.sentAt),
    }

    # ✅ SAFE USER GROUP (use ID or clean email)
    user_group = clean_group_name(f"alerts_user_{complaint.id}")

    async_to_sync(channel_layer.group_send)(
        user_group,
        {
            "type": "send_alert",
            "data": alert_data
        }
    )

    # ✅ ADMIN GROUP (already safe)
    async_to_sync(channel_layer.group_send)(
        "alerts_admin",
        {
            "type": "send_alert",
            "data": alert_data
        }
    )

    # ==============================
    # 📧 EMAIL ALERT (SAFE)
    # ==============================

    try:
        html_content = render_to_string("email/vehicle_detected_alert.html", {
            "ownerName": complaint.ownerName,
            "plate": complaint.plateNumber,
            "location": instance.locationText or "Unknown",
            "time": instance.detectedAt,
        })

        email = EmailMultiAlternatives(
            subject="Vehicle Detection Alert",
            body="Vehicle detected!",
            from_email="trackvision240@gmail.com",
            to=[complaint.ownerEmail],
        )
        email.attach_alternative(html_content, "text/html")
        email.send()

    except Exception as e:
        print("Email sending failed:", str(e))