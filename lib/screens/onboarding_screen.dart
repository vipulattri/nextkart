import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexkart6/screens/auth/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define onboarding data
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/sammy-line-searching.gif',
      'mainText': 'Welcome to Nexkart',
      'subText':
          'shop smart , save more\n get the best deals from your local \n sunday exhibitions now available every day!',
    },
    {
      'image': 'assets/images/sammy-line-shopping.gif',
      'mainText': 'Exclusive Local Deals',
      'subText':
          'handpicked offers just for you! \n discover unique products from local sellers \n at discounted rates Swipe,exploren and grab\n your favourites before theyre gone',
    },
    {
      'image': 'assets/images/sammy-line-delivery.gif',
      'mainText': 'Lets Get Started !',
      'subText':
          'Your Marketplace, Your Rules! \n create an account, start browsing and enjoy \n seamless shopping with Nexkart , Bringing\n the market to your fingertips!',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Log asset paths for debugging
    if (kDebugMode) {
      for (var data in _onboardingData) {
        print('Loading asset: ${data['image']}');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (kDebugMode) {
        print('Navigating to /login');
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skip() {
    if (kDebugMode) {
      print('Skipping to /login');
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

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
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                if (kDebugMode) {
                  print('Page changed to: $index');
                }
              },
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      SizedBox(height: 120.h), // Space for skip button
                      Image.asset(
                        _onboardingData[index]['image']!,
                        height: 300.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          if (kDebugMode) {
                            print(
                              'Error loading image: ${_onboardingData[index]['image']} - $error',
                            );
                          }
                          return Container(
                            height: 300.h,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              size: 50.sp,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 40.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          _onboardingData[index]['mainText']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          _onboardingData[index]['subText']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Skip button
            Positioned(
              top: 40.h,
              right: 16.w,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF4A00E0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Bottom controls
            Positioned(
              bottom: 40.h,
              left: 24.w,
              right: 24.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: WormEffect(
                      dotHeight: 8.h,
                      dotWidth: 8.w,
                      activeDotColor: const Color(0xFF4A00E0),
                      dotColor: Colors.grey.shade300,
                      spacing: 8.w,
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A00E0),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        _currentPage == _onboardingData.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
