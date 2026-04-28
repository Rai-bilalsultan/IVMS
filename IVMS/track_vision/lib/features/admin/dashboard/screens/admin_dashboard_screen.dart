import 'package:flutter/material.dart';
import 'package:track_vision/features/admin/dashboard/widgets/vehicle_detection_table.dart';
import 'package:track_vision/features/admin/dashboard/widgets/vehicle_map_preview.dart';
import 'package:track_vision/features/admin/dashboard/widgets/overview_cards.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Overview text
              Text(
                "Admin Dashboard Overview",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Overview Card
              OverviewCards(),
              const SizedBox(height: 20),

              //Latest Detections Table
              Text(
                "Latest Vehicle Detections",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              VehicleDetectionTable(limit: 10),
              const SizedBox(height: 20),

              // Map Preview with vehicle locations
              Text(
                "Detection Locations Map",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              VehicleMapPreview(height: 400, limit: 20),
            ],
          ),
        ),
      ),
    );
  }
}
