import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/widgets/admin_appbar.dart';
import 'package:track_vision/features/admin/camera/screens/admin_camera_screen.dart';
import 'package:track_vision/features/admin/complaints/screens/admin_complaints_screen.dart';
import 'package:track_vision/features/admin/dashboard/screens/admin_dashboard_screen.dart';
import 'package:track_vision/features/admin/vehicles/screens/admin_unknown_vehicles_screen.dart';
import 'package:track_vision/features/admin/complaints/screens/admin_complaints_list_screen.dart';
import 'package:track_vision/features/auth/providers/admin_provider.dart';
import 'package:track_vision/core/config/constants.dart';

class AdminBottomNavbar extends ConsumerStatefulWidget {
  const AdminBottomNavbar({super.key});

  @override
  ConsumerState<AdminBottomNavbar> createState() => _AdminBottomNavbarState();
}

class _AdminBottomNavbarState extends ConsumerState<AdminBottomNavbar> {
  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.warning_amber_outlined,
    Icons.feedback_outlined,
    Icons.info_outlined,
    Icons.camera_alt_outlined,
  ];

  final List<String> _labels = [
    'Home',
    'Unknowns',
    'Complaints',
    'Manage Complaints',
    'Camera',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final adminPages = [
      AdminDashboard(),
      const AdminUnknownVehiclesScreen(),
      AdminComplains(),
      AdminComplaintsListScreen(),
      AdminCamera(),
    ];
    return Scaffold(
      appBar: AdminAppbar(),
      body: adminPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.textLightMode,
        unselectedItemColor: AppColors.textLightMode.withOpacity(0.5),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.textLightMode,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.textLightMode,
        ),
        backgroundColor: AppColors.primaryBlue,
        items: List.generate(_icons.length, (index) {
          final bool isSelected = selectedIndex == index;
          return BottomNavigationBarItem(
            label: _labels[index],
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(
                _icons[index],
                color: isSelected ? Colors.white : Colors.white70,
                size: 30,
              ),
            ),
          );
        }),
      ),
    );
  }
}
