import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

// SignUpPage - StatelessWidget, UI only
class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

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
                'Create',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Account',
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

              const SizedBox(height: 20),

              // Password
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: UnderlineInputBorder(),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // Confirm password
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  border: UnderlineInputBorder(),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 36),

              // Sign Up button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    backgroundColor: Colors.black87,
                  ),
                  onPressed: () {
                    // Navigate to HomePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              // Divider text
              Center(child: Text('or Sign up with', style: TextStyle(color: Colors.grey[600]))),

              const SizedBox(height: 16),

              // Social icons row (dummy)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.apple),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.facebook),
                    color: Colors.blueAccent,
                    iconSize: 32,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Bottom text: Already have an account? Log In
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(color: Colors.black87),
                      children: const [
                        TextSpan(
                          text: 'Log In',
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
