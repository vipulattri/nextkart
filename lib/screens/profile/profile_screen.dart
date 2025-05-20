import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexkart6/main.dart';
import 'package:provider/provider.dart';
import 'package:nexkart6/widgets/_settingstile.dart';
import 'package:nexkart6/providers/user_provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        builder:
            (context) => SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Image Source',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ListTile(
                      leading: Icon(
                        Icons.photo,
                        color: const Color(0xFF4A00E0),
                        size: 24.sp,
                      ),
                      title: Text('Gallery', style: TextStyle(fontSize: 16.sp)),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.camera_alt,
                        color: const Color(0xFF4A00E0),
                        size: 24.sp,
                      ),
                      title: Text('Camera', style: TextStyle(fontSize: 16.sp)),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ],
                ),
              ),
            ),
      );

      if (source == null) return;

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
        final userProvider = context.read<UserProvider>();
        await userProvider.updateProfileImage(_pickedImage!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Profile image updated',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF4A00E0),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text('No image selected', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Failed to pick image: $e',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to log out?',
              style: TextStyle(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<UserProvider>().logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Logged out', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF4A00E0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final user = context.watch<UserProvider>();

    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF4A00E0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A00E0),
          secondary: Color(0xFFFF8C00),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainNavigation()),
              );
            },
            icon: Icon(Icons.arrow_back, color: Colors.black),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Profile & Settings',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF4A00E0), const Color(0xFF4A00E0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF4A00E0)),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60.r,
                              backgroundColor: const Color(0xFF4A00E0),
                              backgroundImage:
                                  _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                      : user.profileImageUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                        user.profileImageUrl,
                                      )
                                      : null,
                              child:
                                  user.profileImageUrl.isNotEmpty &&
                                          _pickedImage == null
                                      ? CachedNetworkImage(
                                        imageUrl: user.profileImageUrl,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => const Center(
                                              child: SpinKitFadingCircle(
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) {
                                          print(
                                            'Error loading network image: ${user.profileImageUrl} - $error',
                                          );
                                          return Image.network(
                                            'https://via.placeholder.com/150?text=User',
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              print(
                                                'Error loading fallback network image: $error',
                                              );
                                              return const Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 40,
                                              );
                                            },
                                          );
                                        },
                                      )
                                      : _pickedImage == null
                                      ? Image.network(
                                        'https://via.placeholder.com/150?text=User',
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          print(
                                            'Error loading fallback network image: $error',
                                          );
                                          return const Icon(
                                            Icons.broken_image,
                                            color: Colors.white,
                                            size: 40,
                                          );
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A00E0),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Account',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 400),
              child: SettingsTile(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: SettingsTile(
                icon: Icons.location_on,
                title: 'Saved Addresses',
                onTap: () => Navigator.pushNamed(context, '/addresses'),
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              child: SettingsTile(
                icon: Icons.history,
                title: 'Order History',
                onTap: () => Navigator.pushNamed(context, '/order-history'),
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              child: SettingsTile(
                icon: Icons.policy,
                title: 'Policy & Terms',
                onTap: () => Navigator.pushNamed(context, '/policypage'),
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              child: SettingsTile(
                icon: Icons.question_answer,
                title: 'FAQs',
                onTap: () => Navigator.pushNamed(context, 'Faqs'),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 400),
              child: SettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                trailing: Switch(
                  value: user.notificationsEnabled,
                  onChanged: (val) {
                    context.read<UserProvider>().toggleNotifications(val);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.5),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: SettingsTile(
                icon: Icons.lock,
                title: 'Privacy',
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Your data is safe with us. We prioritize your privacy and security.',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF4A00E0),
                                ),
                              ),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                  );
                },
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              child: SettingsTile(
                icon: Icons.palette,
                title: 'Theme',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.palette, color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Theme switching coming soon!',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF4A00E0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                    ),
                  );
                },
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 700),
              child: SettingsTile(
                icon: Icons.language,
                title: 'Language',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Language selection coming soon!',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF4A00E0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32.h),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 800),
              child: GestureDetector(
                onTapDown: (_) => Feedback.forTap(context),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout, color: Colors.white, size: 24.sp),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A00E0),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
