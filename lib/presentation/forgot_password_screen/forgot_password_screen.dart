import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:student_hub/widgets/custom_text_form_field.dart';
import '../../core/app_export.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  void _sendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dio = Dio();
        final response = await dio.post(
          'https://studenthub-backend.fly.dev/api/v1/forgot-password',
          data: {'email': emailController.text.trim()},
        );

        if (response.statusCode == 200) {
          _showSnackBar(
              "A reset link has been sent to your email", Colors.green);
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        } else {
          _showSnackBar(
              "Error: ${response.data['message'] ?? "Something went wrong"}",
              Colors.red);
        }
      } catch (e) {
        _showSnackBar("Network Error. Please try again.", Colors.red);
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
        backgroundColor: theme.primaryColor, // Use the app's primary color
        foregroundColor: Colors.white, // Ensure the text is visible
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
                          "Enter your registered email address to receive a password reset link.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          controller: emailController,
                          hintText: "Enter your email",
                          textInputType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _isLoading ? null : _sendResetLink,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white, // Ensure text is visible
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: const Text("Send Reset Link"),
                              ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.loginScreen);
                          },
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(color: Colors.black), // Black text for the button
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