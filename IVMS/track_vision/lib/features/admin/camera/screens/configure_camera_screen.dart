import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart' show AuthServices;

class ConfigureCameraScreen extends ConsumerStatefulWidget {
  const ConfigureCameraScreen({super.key});

  @override
  ConsumerState<ConfigureCameraScreen> createState() =>
      _ConfigureCameraScreenState();
}

class _ConfigureCameraScreenState extends ConsumerState<ConfigureCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cameraNameController = TextEditingController();
  final _rtspUrlController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  bool _isActive = true;
  List<dynamic> _cameras = [];
  bool _isLoadingCameras = true;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  @override
  void dispose() {
    _cameraNameController.dispose();
    _rtspUrlController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCameras() async {
    setState(() {
      _isLoadingCameras = true;
    });

    try {
      // Assuming API service has a method to fetch cameras
      final result = await AuthServices.getCameras();
      if (result['success']) {
        setState(() {
          _cameras = result['data'] ?? [];
          _isLoadingCameras = false;
        });
      } else {
        setState(() {
          _isLoadingCameras = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to load cameras'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingCameras = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading cameras: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCamera() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthServices.addCamera({
        'name': _cameraNameController.text,
        'rtsp_url': _rtspUrlController.text,
        'location': _locationController.text,
        'is_active': _isActive,
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _cameraNameController.clear();
          _rtspUrlController.clear();
          _locationController.clear();
          setState(() {
            _isActive = true;
          });
          _loadCameras();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to add camera'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCamera(int cameraId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Camera'),
        content: const Text('Are you sure you want to delete this camera?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await AuthServices.deleteCamera(cameraId);
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCameras();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete camera'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleCameraStatus(int cameraId, bool currentStatus) async {
    try {
      final result = await AuthServices.updateCamera(cameraId, {
        'is_active': !currentStatus,
      });

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Camera ${!currentStatus ? 'activated' : 'deactivated'}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadCameras();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Failed to update camera status',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Camera Configuration'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Camera Form
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Camera',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Camera Name
                        TextFormField(
                          controller: _cameraNameController,
                          decoration: InputDecoration(
                            labelText: 'Camera Name',
                            hintText: 'e.g., Front Gate Camera',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.videocam),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter camera name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // RTSP URL
                        TextFormField(
                          controller: _rtspUrlController,
                          decoration: InputDecoration(
                            labelText: 'RTSP URL',
                            hintText: 'rtsp://username:password@ip:port/path',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.link),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter RTSP URL';
                            }
                            if (!value.startsWith('rtsp://')) {
                              return 'URL must start with rtsp://';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            hintText: 'e.g., Main Entrance, Parking Lot',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Active Status
                        SwitchListTile(
                          title: const Text('Active'),
                          subtitle: const Text(
                            'Enable/disable camera for monitoring',
                          ),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 20),

                        // Add Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Add Camera',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Existing Cameras List
              const Text(
                'Configured Cameras',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),

              _isLoadingCameras
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _cameras.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.videocam_off,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No cameras configured yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cameras.length,
                      itemBuilder: (context, index) {
                        final camera = _cameras[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (camera['is_active'] ?? false)
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.videocam,
                                color: (camera['is_active'] ?? false)
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              camera['name'] ?? 'Unnamed Camera',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  camera['location'] ?? 'No location',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  camera['rtsp_url'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Toggle Active Status
                                Switch(
                                  value: camera['is_active'] ?? false,
                                  onChanged: (value) {
                                    _toggleCameraStatus(
                                      camera['id'],
                                      camera['is_active'] ?? false,
                                    );
                                  },
                                  activeColor: Colors.green,
                                ),
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    _deleteCamera(camera['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
