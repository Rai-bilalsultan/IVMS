import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/admin/complaints/screens/admin_complaints_list_screen.dart';

class AdminComplaintManagementScreen extends ConsumerStatefulWidget {
  const AdminComplaintManagementScreen({super.key});

  @override
  ConsumerState<AdminComplaintManagementScreen> createState() =>
      _AdminComplaintManagementScreenState();
}

class _AdminComplaintManagementScreenState
    extends ConsumerState<AdminComplaintManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminComplaintsListScreen();
  }
}
