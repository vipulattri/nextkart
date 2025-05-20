import 'package:flutter/material.dart';
import 'package:nexkart6/main.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  void verifyOTP() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter complete 6-digit OTP')),
      );
      return;
    }

    // TODO: Call backend/Firebase to verify OTP
    print('Verifying OTP $otp for +91${widget.phoneNumber}');
  }

  void resendOTP() {
    // TODO: Resend OTP logic
    print('Resending OTP to +91${widget.phoneNumber}');
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A00E0),
        title: const Text(
          'Verify OTP',
          style: TextStyle(
            fontFamily: 'Poppins-SemiBold',
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Enter the 6-digit OTP sent to +91${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins-SemiBold',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: const InputDecoration(counterText: ""),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavigation()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins-SemiBold',

                  color: Color.from(alpha: 1, red: 0, green: 0, blue: 0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: resendOTP,
              child: const Text(
                'Resend OTP',
                style: TextStyle(fontSize: 16, color: Color(0xFF4A00E0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
