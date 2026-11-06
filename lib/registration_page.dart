
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() =>
      _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const String baseUrl = 'http://192.168.0.104:3000';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'full_name': _nameController.text.trim(),
              'username': _usernameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if ((response.statusCode == 200 ||
              response.statusCode == 201) &&
          data is Map &&
          data['message'] != null &&
          data['message'].toString().toLowerCase().contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        final message = data is Map
            ? data['message'] ?? 'Registration failed!'
            : 'Registration failed!';

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

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    const primaryColor = Color(0xFF146C60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: primaryColor,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF146C60);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.factory_rounded,
                  size: 65,
                  color: primaryColor,
                ),

                const SizedBox(height: 12),

                const Text(
                  'GARMENT PULSE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Create your account to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                _buildField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildField(
                  label: 'Username',
                  hint: 'Choose a username',
                  controller: _usernameController,
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildField(
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                _buildField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please create a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildField(
                  label: 'Confirm Password',
                  hint: 'Enter your password again',
                  controller: _confirmPasswordController,
                  icon: Icons.lock_reset,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
