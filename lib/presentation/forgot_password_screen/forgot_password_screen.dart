import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:student_hub/widgets/custom_text_form_field.dart';
import 'package:student_hub/services/user_service.dart';
import '../../core/app_export.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _userId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  void _findUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Find user by email
        final result = await UserService.findStudent(emailController.text.trim());
        
        if (result['success'] && result['data'] != null) {
          setState(() {
            _emailSent = true;
            _userId = result['data']['_id']; // Store user ID for password reset
          });
          _showSnackBar("User found. Please set your new password.", Colors.green);
        } else {
          _showSnackBar("User not found with this email.", Colors.red);
        }
      } catch (e) {
        _showSnackBar("Error: ${e.toString()}", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_userId == null) {
          _showSnackBar("User ID not found. Please try again.", Colors.red);
          return;
        }

        // Reset password using the API
        final result = await UserService.resetPassword(_userId!, passwordController.text);
        
        if (result['success']) {
          _showSnackBar("Password reset successfully!", Colors.green);
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        } else {
          _showSnackBar("Error: ${result['message']}", Colors.red);
        }
      } catch (e) {
        _showSnackBar("Error: ${e.toString()}", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _emailSent
                              ? "Set your new password"
                              : "Enter your registered email address to reset your password.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 20),
                        if (!_emailSent) ...[
                          CustomTextFormField(
                            controller: emailController,
                            hintText: "Enter your email",
                            textInputType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                        ] else ...[
                          CustomTextFormField(
                            controller: passwordController,
                            hintText: "Enter new password",
                            textInputType: TextInputType.visiblePassword,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: confirmPasswordController,
                            hintText: "Confirm new password",
                            textInputType: TextInputType.visiblePassword,
                            obscureText: _obscureConfirmPassword,
                            validator: _validateConfirmPassword,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _isLoading ? null : (_emailSent ? _resetPassword : _findUser),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: Text(_emailSent ? "Reset Password" : "Find Account"),
                              ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.loginScreen);
                          },
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}