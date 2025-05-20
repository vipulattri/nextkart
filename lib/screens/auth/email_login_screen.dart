import 'package:flutter/material.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool obscurePassword = true;

  void onSubmit() {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (!email.contains('@') || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4A00E0),
          content: Text(
            'Enter valid email and password',
            style: TextStyle(
              fontFamily: 'Poppins-SemiBold',
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
      return;
    }

    if (isLogin) {
      // TODO: Handle email login
      print('Logging in: $email');
    } else {
      // TODO: Handle email registration
      print('Registering: $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A00E0),
        title: Text(
          isLogin ? 'Login with Email' : 'Register with Email',
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
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                isLogin ? 'Login' : 'Register',
                style: TextStyle(
                  fontFamily: 'Poppins-SemiBold',
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() => isLogin = !isLogin);
              },
              child: Text(
                isLogin
                    ? "Don't have an account? Register"
                    : "Already have an account? Login",
                style: const TextStyle(
                  color: Color(0xFF4A00E0),
                  fontFamily: 'Poppins-SemiBold',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
