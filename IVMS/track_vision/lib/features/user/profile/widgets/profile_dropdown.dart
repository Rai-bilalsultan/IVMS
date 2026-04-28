import 'package:flutter/material.dart';

class ProfileDropdown extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String avatarInitial;
  final VoidCallback onLogout;
  final VoidCallback onProfile;

  const ProfileDropdown({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarInitial,
    required this.onLogout,
    required this.onProfile,
  });

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          widget.onProfile();
        } else if (value == 'logout') {
          widget.onLogout();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Section
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue[600],
                      child: Text(
                        widget.avatarInitial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
            ],
          ),
        ),
        // Profile Option
        PopupMenuItem<String>(
          value: 'profile',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.grey[700]),
                SizedBox(width: 12),
                Text(
                  'Profile',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        // Logout Option
        PopupMenuItem<String>(
          value: 'logout',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: Colors.red),
                SizedBox(width: 12),
                Text(
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
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue[600],
          child: Text(
            widget.avatarInitial,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
