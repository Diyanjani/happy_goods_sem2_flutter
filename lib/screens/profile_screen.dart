import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../constants/text_styles.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User mockUser = const User(
    name: 'Diyanjani Jayamanne',
    email: 'diyanjanij@gmail.com',
    avatarUrl: 'assets/images/dili.JPG',
  );

  String? _capturedImagePath;
  int _imageKey = 0;

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    return false;
  }

  Future<void> _openCamera() async {
    try {
      print('Opening camera/gallery picker...');
      
      // Show options for camera or gallery
      final String? choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: const Text('Choose how you want to add your profile picture:'),
            actions: [
              TextButton(
                onPressed: () {
                  print('Camera selected');
                  Navigator.pop(context, 'camera');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Camera'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  print('Gallery selected');
                  Navigator.pop(context, 'gallery');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text('Gallery'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  print('Dialog cancelled');
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (choice == null) {
        print('No choice selected');
        return;
      }

      print('Selected choice: $choice');

      XFile? image;
      final ImagePicker picker = ImagePicker();

      if (choice == 'camera') {
        print('Attempting to open camera...');
        
        // Check camera permission
        final hasPermission = await _checkCameraPermission();
        if (!hasPermission) {
          print('Camera permission denied');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required to take photos'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
        
        try {
          image = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 85,
            preferredCameraDevice: CameraDevice.rear,
          );
          print('Camera image result: ${image?.path ?? 'null'}');
        } catch (e) {
          print('Camera error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Camera error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      } else if (choice == 'gallery') {
        print('Attempting to open gallery...');
        try {
          image = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 85,
          );
          print('Gallery image result: ${image?.path ?? 'null'}');
        } catch (e) {
          print('Gallery error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gallery error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      print('Image picker result: ${image?.path ?? 'null'}');

      if (image != null) {
        print('Image picked: ${image.path}');
        print('Image name: ${image.name}');
        print('Image mime type: ${image.mimeType}');
        
        // For web, we don't need to check file existence since it's a blob URL
        if (kIsWeb) {
          print('Web platform detected, using blob URL directly');
          setState(() {
            _capturedImagePath = image!.path;
            _imageKey++;
          });
          
          print('State updated. New image key: $_imageKey');
          print('New captured image path: $_capturedImagePath');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile picture updated! ${image.name.isNotEmpty ? image.name : 'New Image'}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // For mobile platforms, verify file exists
          final file = File(image.path);
          final fileExists = await file.exists();
          print('File exists: $fileExists');
          
          if (fileExists) {
            // Get file size for debugging
            final fileSize = await file.length();
            print('File size: $fileSize bytes');
            
            print('File exists, updating state...');
            
            // Clear any cached images and force rebuild
            setState(() {
              _capturedImagePath = image!.path;
              _imageKey++;
            });
            
            print('State updated. New image key: $_imageKey');
            print('New captured image path: $_capturedImagePath');
            
            // Additional state update to ensure UI refresh
            await Future.delayed(const Duration(milliseconds: 50));
            if (mounted) {
              setState(() {});
              print('Additional state update completed');
            }
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile picture updated! ${image.name.isNotEmpty ? image.name : image.path.split('/').last}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            print('Image file does not exist at path: ${image.path}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to load selected image: File not found'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } else {
        print('No image was selected');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image selected'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Image picker error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyles.heading(context)),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade50,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: ClipOval(
                    child: _capturedImagePath != null
                        ? (kIsWeb 
                            ? Image.network(
                                _capturedImagePath!,
                                key: ValueKey('profile_image_$_imageKey'),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    print('Web image loaded successfully: $_capturedImagePath');
                                    return child;
                                  }
                                  print('Loading web image: $_capturedImagePath');
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Web image error: $error');
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.red.shade100,
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red.shade400,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                File(_capturedImagePath!),
                                key: ValueKey('profile_image_$_imageKey'),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    print('Image loaded successfully: $_capturedImagePath');
                                    return child;
                                  }
                                  print('Loading image: $_capturedImagePath');
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  print('Image path: $_capturedImagePath');
                                  print('Stack trace: $stackTrace');
                                  
                                  // Reset to default image on error
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _capturedImagePath = null;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to load image, reverted to default'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  });
                                  
                                  return Image.asset(
                                    mockUser.avatarUrl,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  );
                                },
                              ))
                        : Image.asset(
                            mockUser.avatarUrl,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _openCamera,
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              mockUser.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mockUser.email,
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
            ),
            
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Update Profile Picture'),
              subtitle: _capturedImagePath != null 
                  ? const Text('Tap to change photo') 
                  : const Text('Tap to add photo'),
              onTap: _openCamera,
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
            const SizedBox(height: 50), // Extra spacing at bottom
          ],
        ),
      ),
    );
  }
}