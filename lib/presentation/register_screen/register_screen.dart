import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:student_hub/widgets/header_design.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
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

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://studenthub-backend.fly.dev/api/v1/student/register',
        data: {
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'username': usernameController.text.trim(),
          'password': passwordController.text,
          'confirmPassword': confirmPasswordController.text,
        },
      );

      setState(() => _isLoading = false);

  if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Registration Successful", Colors.green);
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      } else {
        final errorMsg = response.data['message'] ?? "An unknown error occurred.";
        _showSnackBar("Registration Failed: $errorMsg", Colors.red);
      }
    } on DioException catch (e) {
      // Check if the error response actually contains a success message
      if (e.response?.statusCode == 200 || e.response?.statusCode == 201 || 
          (e.response?.data is Map && e.response?.data['message']?.toString().toLowerCase().contains('success') == true)) {
        _showSnackBar("Registration Successful", Colors.green);
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      } else {
        final errorMsg = e.response?.data['message'] ?? "Network Error";
        _showSnackBar("Registration Failed: $errorMsg", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Unexpected Error. Please try again.", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderDesign(),
                    _buildContent(context),
                  ],
                ),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50.0),
          Text(
            "Create an Account",
            style: CustomTextStyles.headlineSmallInikaBlack900,
          ),
          const SizedBox(height: 40.0),
          _buildNameInput(),
          const SizedBox(height: 20.0),
          _buildEmailInput(),
          const SizedBox(height: 20.0),
          _buildPhoneInput(),
          const SizedBox(height: 20.0),
          _buildUsernameInput(),
          const SizedBox(height: 20.0),
          _buildPasswordInput(),
          const SizedBox(height: 20.0),
          _buildConfirmPasswordInput(),
          const SizedBox(height: 50.0),
          _buildRegisterButton(context),
          const SizedBox(height: 22.0),
          _buildLoginLink(context),
          const SizedBox(height: 38.0),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return CustomTextFormField(
      controller: nameController,
      hintText: "Enter your full name",
      textInputType: TextInputType.text,
      validator: (value) =>
          value == null || value.isEmpty ? "Full Name is required" : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
    );
  }

  Widget _buildEmailInput() {
    return CustomTextFormField(
      controller: emailController,
      hintText: "Enter your email",
      textInputType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return "Email is required";
        final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
        if (!emailRegex.hasMatch(value)) return "Enter a valid email";
        return null;
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
    );
  }

  Widget _buildPhoneInput() {
    return CustomTextFormField(
      controller: phoneController,
      hintText: "Enter your phone number (e.g., +1234567890)",
      textInputType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) return "Phone number is required";
        final phoneRegex = RegExp(r"^\+\d{10,15}$");
        if (!phoneRegex.hasMatch(value)) return "Enter a valid phone number";
        return null;
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
    );
  }

  Widget _buildUsernameInput() {
    return CustomTextFormField(
      controller: usernameController,
      hintText: "Enter your username",
      textInputType: TextInputType.text,
      validator: (value) =>
          value == null || value.isEmpty ? "Username is required" : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
    );
  }

  Widget _buildPasswordInput() {
    return CustomTextFormField(
      controller: passwordController,
      hintText: "Enter your password",
      textInputType: TextInputType.visiblePassword,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "Password is required";
        if (value.length < 8) return "Password must be at least 8 characters";
        if (!RegExp(r'[A-Za-z]').hasMatch(value)) return "Include letters";
        if (!RegExp(r'\d').hasMatch(value)) return "Include digits";
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return "Include symbols";
        return null;
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
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
    );
  }

  Widget _buildConfirmPasswordInput() {
    return CustomTextFormField(
      controller: confirmPasswordController,
      hintText: "Confirm your password",
      textInputType: TextInputType.visiblePassword,
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "Confirm password is required";
        if (value != passwordController.text) return "Passwords do not match";
        return null;
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
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
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return CustomElevatedButton(
      text: "Register",
      margin: const EdgeInsets.symmetric(horizontal: 26.0),
      onPressed: () => _register(context),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.loginScreen),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Already have an account?",
                style: CustomTextStyles.bodyMediumImprimaBlack90014,
              ),
              TextSpan(
                text: " Log in",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}