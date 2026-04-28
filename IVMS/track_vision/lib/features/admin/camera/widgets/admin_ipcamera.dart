import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:track_vision/core/config/constants.dart';

class IPCamera extends ConsumerStatefulWidget {
  const IPCamera({super.key});

  @override
  ConsumerState<IPCamera> createState() => _IPCameraState();
}

class _IPCameraState extends ConsumerState<IPCamera> {
  final _formKey = GlobalKey<FormState>();
  final _camera_ID = TextEditingController();
  final _rtsp_url = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textLightMode,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                "Connect with IP Camera",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkMode,
                ),
              ),
              const SizedBox(height: 30),
              //Camera ID Text Field
              Text(
                "Camera ID",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              TextFormField(
                controller: _camera_ID,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "ISB-CAM-01",
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // RTSP URL
              Text(
                "RTSP URL",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              TextFormField(
                controller: _rtsp_url,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText:
                      "rtsp://admin:police123@192.168.10.55.554/Streaming/Channels/1",
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Connect Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Connect",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
