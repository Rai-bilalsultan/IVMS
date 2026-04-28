from rest_framework.decorators import api_view, parser_classes, permission_classes
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from django.template.loader import render_to_string
from django.core.mail import EmailMultiAlternatives
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.db.models import Q
from django.utils.timezone import now
from vehicles.models import Vehicle
from vehicles.serializers import VehicleSerializer

import requests
import logging

from .models import Complaint
from .serializers import ComplaintSerializer

logger = logging.getLogger(__name__)

# =========================================================
# 1. REGISTER COMPLAINT (AUTO STATUS = PENDING)
# =========================================================
@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
def register_complaint(request):
    serializer = ComplaintSerializer(data=request.data)

    if serializer.is_valid():
        complaint = serializer.save()  # status defaults to "pending"

        try:
            html_content = render_to_string("email/complaint_registered.html", {
                "ownerName": complaint.ownerName,
                "complaintId": complaint.id,
                "plateNumber": complaint.plateNumber,
                "vehicleModel": complaint.vehicleModel,
                "vehicleColor": complaint.vehicleColor,
                "variant": complaint.vehicleVariant,
            })

            email = EmailMultiAlternatives(
                subject="Your Vehicle Theft Complaint is Registered",
                body="",
                from_email="Trackvision240@gmail.com",
                to=[complaint.ownerEmail],
            )
            email.attach_alternative(html_content, "text/html")
            email.send()

            email_status = "Email sent successfully"

        except Exception as e:
            logger.error(f"Email error: {e}")
            email_status = "Email failed"

        return Response({
            "message": "Complaint registered successfully",
            "email_status": email_status,
            "data": serializer.data
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# =========================================================
# 2. SEARCH COMPLAINT (USER / ADMIN FILTERED)
# =========================================================
@api_view(['GET'])
def search_complaint(request):
    query = request.query_params.get('q', '').strip()
    role = request.query_params.get('role')
    email = request.query_params.get('email')

    page = int(request.query_params.get('page', 1))
    limit = min(int(request.query_params.get('limit', 10)), 50)

    if not query:
        return Response({"error": "Search query 'q' is required"}, status=400)

    clean_query = query.replace('-', '')

    is_cnic = clean_query.isdigit() and len(clean_query) in [13, 14]
    is_plate = any(c.isalpha() for c in query) and any(c.isdigit() for c in query)
    is_chassis = len(query) > 10 and query.isalnum()

    if is_cnic:
        complaints = Complaint.objects.filter(ownerCnic=query)
    elif is_plate:
        complaints = Complaint.objects.filter(plateNumber__iexact=query)
    elif is_chassis:
        complaints = Complaint.objects.filter(chassisNumber__iexact=query)
    else:
        complaints = Complaint.objects.filter(
            Q(ownerName__icontains=query) |
            Q(ownerEmail__icontains=query) |
            Q(ownerPhone__icontains=query) |
            Q(vehicleMake__icontains=query) |
            Q(vehicleModel__icontains=query)
        )

    # restrict non-admin users
    if role != "admin":
        complaints = complaints.filter(ownerEmail=email)

    complaints = complaints.order_by('-createdAt')

    paginator = Paginator(complaints, limit)

    try:
        page_obj = paginator.page(page)
    except (PageNotAnInteger, EmptyPage):
        page_obj = paginator.page(1)

    serializer = ComplaintSerializer(page_obj.object_list, many=True)

    return Response({
        "total": paginator.count,
        "page": page,
        "limit": limit,
        "totalPages": paginator.num_pages,
        "complaints": serializer.data
    })


# =========================================================
# 3. LIST COMPLAINTS
# =========================================================
@api_view(['GET'])
def complaint_list(request):
    email = request.GET.get('email')
    include_excise = request.GET.get('include_excise') == 'true'
    status_filter = request.GET.get('status')

    page = int(request.GET.get('page', 1))
    limit = min(int(request.GET.get('limit', 10)), 50)

    qs = Complaint.objects.all()

    if email:
        qs = qs.filter(ownerEmail=email)

    if status_filter:
        qs = qs.filter(status=status_filter)

    qs = qs.order_by('-createdAt')

    paginator = Paginator(qs, limit)

    try:
        page_obj = paginator.page(page)
    except:
        page_obj = paginator.page(1)

    serializer = ComplaintSerializer(page_obj.object_list, many=True)
    complaints = serializer.data

    # =========================
    # EXCISE ENRICHMENT (FAST + BULK)
    # =========================
    if include_excise:
        plate_list = [c["plateNumber"] for c in complaints]
        chassis_list = [c["chassisNumber"] for c in complaints]

        vehicles = Vehicle.objects.filter(
            Q(number_plate__in=plate_list) |
            Q(chassis_number__in=chassis_list)
        )

        vehicle_map = {}
        for v in vehicles:
            vehicle_map[(v.number_plate, v.chassis_number)] = v

        for c in complaints:
            key = (c["plateNumber"], c["chassisNumber"])
            v = vehicle_map.get(key)
            c["excise"] = VehicleSerializer(v).data if v else None

    return Response({
        "total": paginator.count,
        "page": page,
        "limit": limit,
        "totalPages": paginator.num_pages,
        "complaints": complaints
    })

# =========================================================
# 4. GET SINGLE COMPLAINT
# =========================================================
@api_view(['GET'])
def get_complaint(request, complaint_id):
    try:
        complaint = Complaint.objects.get(id=complaint_id)
    except Complaint.DoesNotExist:
        return Response({"error": "Complaint not found"}, status=404)

    vehicle = Vehicle.objects.filter(
        Q(number_plate__iexact=complaint.plateNumber) |
        Q(chassis_number__iexact=complaint.chassisNumber)
    ).first()

    data = ComplaintSerializer(complaint).data
    data["excise"] = VehicleSerializer(vehicle).data if vehicle else None

    return Response(data)

# =========================================================
# 5. ADMIN: VEHICLE VERIFICATION (EXCISE LOOKUP)
# =========================================================
@api_view(["GET"])
@permission_classes([IsAdminUser])
def admin_verify_vehicle(request):
    plate = request.query_params.get("plate")
    chassis = request.query_params.get("chassis")

    if not plate and not chassis:
        return Response({"error": "plate or chassis required"}, status=400)

    try:
        complaint = Complaint.objects.get(
            Q(plateNumber__iexact=plate) |
            Q(chassisNumber__iexact=chassis)
        )
    except Complaint.DoesNotExist:
        return Response({"error": "Complaint not found"}, status=404)

    # ===============================
    # EXCISE API (PLACEHOLDER)
    # ===============================
    try:
        # Replace with real API
        excise_data = {
            "owner": "Fetched from Excise DB",
            "status": "Active",
            "registrationCity": "Rawalpindi",
            "vehicleVerified": True
        }

    except Exception as e:
        excise_data = {"error": "Failed to fetch excise data"}

    return Response({
        "complaint": ComplaintSerializer(complaint).data,
        "excise_data": excise_data
    })


# =========================================================
# 6. ADMIN: UPDATE STATUS (APPROVE / REJECT)
# =========================================================
@api_view(["PATCH"])
def update_complaint_status(request, id):
    try:
        complaint = Complaint.objects.get(id=id)
    except Complaint.DoesNotExist:
        return Response({"error": "Not found"}, status=404)

    role = request.data.get("role")
    email = request.data.get("email")
    status_value = request.data.get("status")
    
    if role != "admin":
        return Response({"error": "Only admin can update status"}, status=403)

    if status_value not in ["pending", "investigating", "rejected"]:
        return Response({"error": "Invalid status"}, status=400)

    complaint.status = status_value

    if status_value in ["investigating", "rejected"]:
        complaint.verified_at = now()
        complaint.verified_by_email = email

    complaint.save()

    return Response({
        "success": True,
        "status": complaint.status
    })

@api_view(['GET'])
def get_complaint_with_excise(request, complaint_id):

    try:
        complaint = Complaint.objects.get(id=complaint_id)
    except Complaint.DoesNotExist:
        return Response({"error": "Complaint not found"}, status=404)

    # =========================
    # MATCH EXCISE VEHICLE
    # =========================
    vehicle = Vehicle.objects.filter(
        Q(number_plate__iexact=complaint.plateNumber) |
        Q(chassis_number__iexact=complaint.chassisNumber)
    ).first()

    return Response({
        "complaint": ComplaintSerializer(complaint).data,
        "excise": VehicleSerializer(vehicle).data if vehicle else None
    })

# =========================================================
# 7. OPTIONAL: GET ALL (ADMIN ONLY SHOULD USE THIS)
# =========================================================
@api_view(["GET"])
@permission_classes([IsAdminUser])
def get_all_complaints(request):
    complaints = Complaint.objects.all().order_by("-id")
    return Response(ComplaintSerializer(complaints, many=True).data)