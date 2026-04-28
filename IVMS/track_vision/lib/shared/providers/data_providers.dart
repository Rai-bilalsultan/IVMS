import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/shared/models/detection_model.dart';
import 'package:track_vision/shared/models/alert_model.dart';
import 'package:track_vision/shared/models/route_model.dart';
import 'package:track_vision/shared/models/unknown_vehicle_model.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';

// ============= COMPLAINT PROVIDERS =============

// Get all complaints
final complaintsProvider = FutureProvider<List<Complaint>>((ref) async {
  return AuthServices.getComplaints();
});

// Get single complaint
final complaintDetailProvider = FutureProvider.family<Complaint?, int>((
  ref,
  complaintId,
) async {
  return AuthServices.getComplaint(complaintId);
});

// ============= DETECTION PROVIDERS =============

// Get detections for a complaint
final detectionsByComplaintProvider =
    FutureProvider.family<List<Detection>, int>((ref, complaintId) async {
      return AuthServices.getDetections(complaintId);
    });

// Get all detections
final detectionsProvider = FutureProvider<List<Detection>>((ref) async {
  return AuthServices.fetchDetections();
});

// Get single detection details
final detectionDetailProvider = FutureProvider.family<Detection?, int>((
  ref,
  detectionId,
) async {
  return AuthServices.getDetectionDetails(detectionId);
});

// Get unknown vehicles
final unknownVehiclesProvider = FutureProvider<List<UnknownVehicle>>((
  ref,
) async {
  return AuthServices.fetchUnknownVehicles();
});

// ============= ALERT PROVIDERS =============

// Get all alerts
final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  return AuthServices.getAlerts();
});

// Unread alerts count
final unreadAlertsCountProvider = FutureProvider<int>((ref) async {
  return AuthServices.getUnreadAlertsCount();
});

// ============= ROUTE PREDICTION PROVIDERS =============

// Get predicted routes for detection
final predictedRoutesProvider =
    FutureProvider.family<List<PredictionRoute>, int>((ref, detectionId) async {
      return AuthServices.getPredictedRoutes(detectionId);
    });

// Refetch helpers
class ComplaintNotifier extends AsyncNotifier<List<Complaint>> {
  @override
  Future<List<Complaint>> build() async {
    return AuthServices.getComplaints();
  }

  Future<void> refetch() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => AuthServices.getComplaints());
  }
}

final complaintNotifierProvider =
    AsyncNotifierProvider<ComplaintNotifier, List<Complaint>>(
      () => ComplaintNotifier(),
    );

// ============= CREATE COMPLAINT NOTIFIER =============

class CreateComplaintNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  CreateComplaintNotifier() : super(const AsyncValue.data({}));

  Future<void> createComplaint(Complaint complaint) async {
    state = const AsyncLoading();
    try {
      final result = await AuthServices.createComplaint(complaint);
      state = AsyncValue.data(result);
    } catch (err, st) {
      state = AsyncValue.error(err, st);
    }
  }
}

final createComplaintProvider =
    StateNotifierProvider<
      CreateComplaintNotifier,
      AsyncValue<Map<String, dynamic>>
    >((ref) {
      return CreateComplaintNotifier();
    });
