import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/user/alerts/widgets/showalerts.dart';
import 'package:track_vision/features/user/profile/widgets/profile_edit.dart';
import 'package:track_vision/features/auth/providers/user_provider.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';

import 'package:track_vision/core/config/constants.dart';

class UserAppbar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const UserAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  ConsumerState<UserAppbar> createState() => _UserAppbarState();
}

class _UserAppbarState extends ConsumerState<UserAppbar> {
  String _getInitials(String name, String email) {
    final primary = name.trim();
    var base = primary.isNotEmpty ? primary : email.split('@').first.trim();

    if (base.isEmpty) return 'U';

    final tokens = base
        .split(RegExp(r'[\s._-]+'))
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (tokens.length >= 2) {
      return '${tokens[0][0]}${tokens[1][0]}'.toUpperCase();
    }

    return tokens[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(uUserNameProvider);
    final userEmail = ref.watch(uUserEmailProvider);
    final unreadCountAsync = ref.watch(unreadAlertsCountProvider);
    final displayName = userName.trim().isNotEmpty
        ? userName.trim()
        : userEmail;
    final initials = _getInitials(userName, userEmail);

    return Container(
      height: widget.preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Logo + Title + Subtitle
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    "assets/images/applogo.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Title
                    const Text(
                      "Track Vision",
                      style: TextStyle(
                        color: AppColors.textLightMode,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Intelligent Vehicle Monitoring",
                      style: TextStyle(
                        color: AppColors.textLightMode,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Notification + Profile Section
            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        showAlertsPopup(context);
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    unreadCountAsync.when(
                      data: (count) => count > 0
                          ? Positioned(
                              right: 0,
                              top: 2,
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(width: 1),
                // Profile Avatar Button with Custom Popup
                GestureDetector(
                  onTap: () => _showProfileMenu(context, displayName, initials),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.textLightMode.withOpacity(0.2),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(
    BuildContext context,
    String displayName,
    String initials,
  ) {
    final userEmail = ref.read(uUserEmailProvider);
    final authState = ref.read(authNotifierProvider);
    final userRole = authState.user?.role ?? 'User';

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 70, right: 10),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 8,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Section
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryBlue,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      userRole.toLowerCase().contains('admin')
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  userRole,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        userRole.toLowerCase().contains('admin')
                                        ? Colors.orange.shade700
                                        : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Profile Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEdit(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Logout Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout, size: 20, color: Colors.red),
                          const SizedBox(width: 12),
                          const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // Clear auth state from storage
    ref.read(authNotifierProvider.notifier).logout();

    // Show logout message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to login
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }
}

// Old PopupMenuButton code - keeping for reference but commented out
