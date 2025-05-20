import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexkart6/screens/auth/email_login_screen.dart';
import 'package:nexkart6/screens/auth/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  void onSendOTP() {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }

    // TODO: Trigger OTP send logic here
    print('Sending OTP to +91$phone');
  }

  void onGoogleSignIn() {
    // TODO: Handle Google Sign-In
    print('Google Sign-In clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Welcome to NexKart 🛒',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins-SemiBold',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login or create an account to continue',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins-SemiBold',
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => OtpScreen(
                                    phoneNumber: phoneController.text,
                                  ),
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Send OTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins-SemiBold',
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: isLoading ? null : onGoogleSignIn,
                icon: Image.asset('assets/images/google_1.png', height: 24),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.grey),
                ),
                label: const Text('Continue with Google'),
              ),
              const Spacer(),

              TextButton(
                onPressed: () {
                  // Optional: navigate to email login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
                  );
                },
                child: const Text(
                  'Continue with Email instead',
                  style: TextStyle(
                    color: Color(0xFF4A00E0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
