from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path
from users.views import RegisterView, LoginView, ForgotPasswordView, VerifyOTPView, ResetPasswordView, get_profile, update_profile
from django.conf.urls.static import static
from pathlib import Path
from detection.views import AdminUnknownVehiclesAPIView, DetectVehicleAPIView
from alerts.views import AlertDetailView, UserAlertsView
from vehicles.views import VehicleCreateView, VehicleSearchView

VEHICLE_PICTURES_ROOT = Path(__file__).resolve().parent.parent / "vehicle_pictures"
DETECTED_VEHICLE_PICTURES_ROOT = Path(__file__).resolve().parent.parent / "vehicle_pictures"

# Import complaint views
from complaints.views import register_complaint, search_complaint, complaint_list, get_complaint, update_complaint_status, get_all_complaints, get_complaint_with_excise
urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth routes
    path('signup/', RegisterView.as_view(), name='signup'),
    path('login/', LoginView.as_view(), name='login'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path("user/profile/", get_profile, name="get-profile"),
    path("user/profile/update/", update_profile, name="update-profile"),


    # Complaint APIs
    path('complaints/', complaint_list, name="complaint-list"),
    path('complaints/register/', register_complaint, name="register-complaint"),
    path('complaints/search/', search_complaint, name="search-complaint"),
    path('complaints/all/', get_all_complaints, name="get_all_complaints"),
    path('complaints/<int:complaint_id>/', get_complaint, name='get-complaint'),
    path("complaints/update-status/<int:id>/", update_complaint_status, name='update_complaint_status'),


    # Alert APIs
    path("alerts/", UserAlertsView.as_view(), name="get-user-alerts"),
    path("alerts/<int:alert_id>/mark-read/", AlertDetailView.as_view(), name="mark-alert-read"),
    path("alerts/<int:alert_id>/", AlertDetailView.as_view(), name="get_alert_details"),

    path("detect/", DetectVehicleAPIView.as_view(), name="detect_vehicle"),
    path("detections/", DetectVehicleAPIView.as_view(), name="detections"),
    path("detections/<int:id>/", DetectVehicleAPIView.as_view()),
    path("unknown-vehicles/", AdminUnknownVehiclesAPIView.as_view(), name="unknown-vehicles"),
    
    path("add-vehicle/", VehicleCreateView.as_view()),
    path("search-vehicle/", VehicleSearchView.as_view()),
    path("complaints/excise/<int:complaint_id>/", get_complaint_with_excise ),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    