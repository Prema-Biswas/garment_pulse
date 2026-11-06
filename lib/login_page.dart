
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Backend API address
  static const String baseUrl = 'http://192.168.0.104:3000';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login API function
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identifier': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 &&
          data is Map &&
          data['token'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful! Welcome to Garment Pulse.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Open Dashboard after successful login
        widget.onLoginSuccess();
      } else {
        final message = data is Map
            ? data['message'] ?? 'Login failed!'
            : 'Login failed!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF146C60);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 25),

                  // App Logo
                  const Icon(
                    Icons.factory_rounded,
                    size: 75,
                    color: primaryColor,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'GARMENT PULSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Smart Garments Production Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 45),

                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Sign in to continue to your account.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Email or Username Field
                  const Text(
                    'Email or Username',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email or username',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email or username';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Remember Me
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember Me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password recovery will be available soon.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      "Don't have an account?",
      style: TextStyle(color: Colors.grey),
    ),
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistrationPage(),
          ),
        );
      },
      child: const Text(
        'Create Account',
        style: TextStyle(
          color: Color(0xFF146C60),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

                  const SizedBox(height: 28),

                  const Center(
                    child: Text(
                      'Garment Pulse | Smart Production System',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
