import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:track_vision/features/auth/providers/user_provider.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/core/config/constants.dart';

class UserComplainsSubmit extends ConsumerStatefulWidget {
  const UserComplainsSubmit({super.key});

  @override
  ConsumerState<UserComplainsSubmit> createState() =>
      _UserComplaintsSubmitState();
}

class _UserComplaintsSubmitState extends ConsumerState<UserComplainsSubmit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carMake = TextEditingController();
  final TextEditingController _carVariant = TextEditingController();
  final TextEditingController _carModel = TextEditingController();
  final TextEditingController _carPlateNumber = TextEditingController();
  final TextEditingController _carChassisNumber = TextEditingController();
  final TextEditingController _carColor = TextEditingController();
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _carMake.dispose();
    _carVariant.dispose();
    _carModel.dispose();
    _carPlateNumber.dispose();
    _carChassisNumber.dispose();
    _carColor.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      // Get user data from providers and API service
      final userName = ref.read(uUserNameProvider);
      final userEmail =
          AuthServices.getUserEmail() ?? ref.read(uUserEmailProvider);
      final userPhone = ref.read(uUserPhoneProvider) ?? '';
      final userCnic = ref.read(uUserCnicProvider) ?? '';

      // Validate that we have at least email
      if (userEmail == null || userEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User email not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final complaint = Complaint(
        id: 0,
        ownerName: userName.isNotEmpty ? userName : 'Unknown',
        ownerEmail: userEmail,
        ownerPhone: userPhone,
        ownerCnic: userCnic,
        vehicleMake: _carMake.text.trim(),
        vehicleModel: _carModel.text.trim(),
        vehicleVariant: _carVariant.text.trim(),
        vehicleColor: _carColor.text.trim(),
        plateNumber: _carPlateNumber.text.trim(),
        chassisNumber: _carChassisNumber.text.trim(),
        complaintDescription: _description.text.trim(),
        status: 'investigating',
        createdAt: DateTime.now(),
      );

      await ref
          .read(createComplaintProvider.notifier)
          .createComplaint(complaint);

      final result = ref.read(createComplaintProvider);
      result.whenData((data) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refetch complaints list
          ref.invalidate(complaintsProvider);
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Image picker State
    final filePath = ref.watch(fileUploadProvider);
    final createState = ref.watch(createComplaintProvider);

    final fileName = filePath != null
        ? filePath.split('/').last
        : 'No file Chosen';

    return Scaffold(
      backgroundColor: AppColors.textLightMode.withOpacity(0.85),
      appBar: AppBar(
        title: const Text(
          'Submit Complaint',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Title
              const Text(
                "Submit a Complaint",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkMode,
                ),
              ),
              const SizedBox(height: 20),
              // Form fields for submit complaints
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Details title
                    const Text(
                      "Vehicle Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Car Make Textfield
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Car Make",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDarkMode,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                ),
                                controller: _carMake,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Car Make';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        //Car Model Textfield
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Car Model",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDarkMode,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                ),
                                controller: _carModel,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your car model';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    // Car Variant Textfield
                    const Text(
                      "Car Variant",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      controller: _carVariant,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 15.0),
                    // Car Color
                    const Text(
                      "Car Color",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _carColor,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter car color';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Car Plate Number Textfield
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Car Plate Number",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDarkMode,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                ),
                                controller: _carPlateNumber,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your car plate number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        //Car Chassis Number Textfield
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Car Chassis Number",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDarkMode,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                ),
                                controller: _carChassisNumber,
                                keyboardType: TextInputType.text,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Complaint Description
                    const Text(
                      "Complaint Description",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _description,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: 'Describe the incident...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Upload Car Picture
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Vehicle Image',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDarkMode,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            border: Border.all(color: AppColors.textDarkMode),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  // Simple file picker implementation
                                  // You can add image_picker or file_picker package here
                                  ref.read(fileUploadProvider.notifier).state =
                                      '/path/to/file';
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.backgroundLight
                                      .withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.textDarkMode.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Choose file',
                                  style: TextStyle(
                                    color: AppColors.textDarkMode,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  fileName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              if (filePath != null)
                                IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    ref
                                            .read(fileUploadProvider.notifier)
                                            .state =
                                        null;
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: createState.isLoading
                            ? null
                            : _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                        ),
                        child: createState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Submit Complaint",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
