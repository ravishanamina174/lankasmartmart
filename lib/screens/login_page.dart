import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home_page.dart';

// LoginPage - StatelessWidget, UI only
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
              const Text(
                'Log into',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const Text(
                'your account',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              // Name field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Email field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email address',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // Forgot Password (dummy)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password?', style: TextStyle(color: Colors.grey[600])),
                ),
              ),

              const SizedBox(height: 8),

              // Login button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    backgroundColor: const Color.fromARGB(221, 0, 0, 0),
                  ),
                  onPressed: () {
                    // Navigate to HomePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text('Log In', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              // Divider text
              Center(child: Text('or log in with', style: TextStyle(color: Colors.grey[600]))),

              const SizedBox(height: 16),

              // Social icons row (dummy)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata),
                    ),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/facebook.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.facebook),
                    ),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/microsoft.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.apple),
                    ),
                    iconSize: 32,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Bottom text: Don't have an account? Sign Up
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.black87),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
