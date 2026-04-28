import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/auth/providers/user_provider.dart';
import 'package:track_vision/features/user/camera/widgets/camera_scan_page.dart';
import 'package:track_vision/features/admin/camera/widgets/upload_detection.dart';
import 'package:track_vision/core/config/constants.dart';

class UserCamera extends ConsumerStatefulWidget {
  const UserCamera({super.key});

  @override
  ConsumerState<UserCamera> createState() => _UserCameraState();
}

class _UserCameraState extends ConsumerState<UserCamera> {
  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(mobileCamerastateProvider);
    return Scaffold(
      backgroundColor: AppColors.textLightMode.withOpacity(0.5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Scan Vehicle Live",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkMode,
                  ),
                ),
                Text(
                  "Select an option to proceed:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Scan Options - Mobile Camera
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraScanPage()),
                );

                if (result != null && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Scanned: $result')));
                }
              },
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Scan with Mobile Camera",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    Text(
                      "Open your mobile camera now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Upload Detection
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadDetection()),
                );
              },
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Upload Detection",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    Text(
                      "Upload vehicle image for detection",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Camera scan status
            if (scanState) ...[
              const Text(
                'Camera is active',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
