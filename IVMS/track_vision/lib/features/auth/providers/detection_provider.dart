import 'dart:math';
import 'package:flutter_riverpod/legacy.dart';

// Model
class Detection {
  final String plate;
  final String timeAgo;

  Detection({required this.plate, required this.timeAgo});
}

// Notifier
class DetectionNotifier extends StateNotifier<List<Detection>> {
  DetectionNotifier()
    : super([
        Detection(plate: "ABC-123", timeAgo: "2 min ago"),
        Detection(plate: "XYZ-456", timeAgo: "10 min ago"),
      ]);
  final Random random = Random();

  // Adding new detection
  void addDetection(Detection detection) {
    state = [detection, ...state];
  }

  // Swipe to delete
  void deleteDetection(int index) {
    final newList = [...state];
    newList.removeAt(index);
    state = newList;
  }

  // clear list
  void clear() {
    state = [];
  }

  // Simulate real-time detection
  void simulate() {
    final plate = "Car-${random.nextInt(999)}";
    addDetection(Detection(plate: plate, timeAgo: "Just now"));
  }
}

// Provider
final detectionProvider =
    StateNotifierProvider<DetectionNotifier, List<Detection>>(
      (ref) => DetectionNotifier(),
    );
