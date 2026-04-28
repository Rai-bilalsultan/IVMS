import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/auth/providers/user_provider.dart';
import 'package:track_vision/shared/widgets/user_appbar.dart';
import 'package:track_vision/features/user/camera/screens/user_camera_screen.dart';
import 'package:track_vision/features/user/complaints/screens/user_complaints_screen.dart';
import 'package:track_vision/features/user/dashboard/screens/user_dashboard_screen.dart';
import 'package:track_vision/features/user/complaints/screens/detailed_complaints_screen.dart';

import 'package:track_vision/core/config/constants.dart';

class UserBottomNavbar extends ConsumerStatefulWidget {
  const UserBottomNavbar({super.key});

  @override
  ConsumerState<UserBottomNavbar> createState() => _UserBottomNavbarState();
}

class _UserBottomNavbarState extends ConsumerState<UserBottomNavbar> {
  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.feedback_outlined,
    Icons.info_outlined,
    Icons.camera_alt_outlined,
  ];

  final List<String> _labels = ['Home', 'Complaints', 'My Complains', 'Camera'];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(uBottomNavIndexProvider);

    final userPages = [
      UserDashboard(),
      UserComplains(),
      DetailedComplaintsScreen(),
      UserCamera(),
    ];

    return Scaffold(
      appBar: UserAppbar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [],
        body: userPages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(uBottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.textLightMode,
        unselectedItemColor: AppColors.textLightMode.withOpacity(0.5),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textLightMode,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textLightMode,
        ),
        backgroundColor: AppColors.primaryBlue,
        items: List.generate(_icons.length, (index) {
          final bool isSelected = selectedIndex == index;
          return BottomNavigationBarItem(
            label: _labels[index],
            icon: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Icon(
                _icons[index],
                color: isSelected ? Colors.white : Colors.white70,
                size: 24,
              ),
            ),
          );
        }),
      ),
    );
  }
}
