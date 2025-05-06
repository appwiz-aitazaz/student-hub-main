import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/presentation/dashboard/homescreen.dart';
import 'package:student_hub/widgets/header_design.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../forgot_password_screen/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Dio dio = Dio();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    if (value.contains(' ')) {
      return "Password cannot contain spaces";
    }
    return null;
  }

  void _login(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

try {
  final response = await dio.post(
    'https://studenthub-backend.fly.dev/api/v1/student/login',
    data: {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    },
  );

  if (response.statusCode == 200) {
    _showSnackBar("Login Successful", Colors.green);

    final token = response.data['token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }

    await checkProfileCompletion(context);
  } else {
    final errorMsg = response.data['message'] ?? 'Invalid credentials';
    _showSnackBar("Login Failed: $errorMsg", Colors.red);
  }
} on DioException catch (e) {
  final errorMsg = e.response?.data['message'] ?? 'Network Error';
  _showSnackBar("Login Failed: $errorMsg", Colors.red);
} catch (e) {
        _showSnackBar("Unexpected Error. Please try again.", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

Future<void> checkProfileCompletion(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isProfileComplete = prefs.getBool('isProfileComplete') ?? false;

  if (isProfileComplete) {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  } else {
    Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderDesign(),
                    _buildContent(context),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.h).copyWith(right: 38.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50.h),
          Text(
            "Welcome Back!",
            style: CustomTextStyles.headlineSmallInikaBlack900,
          ),
          SizedBox(height: 40.h),
          _buildEmailInput(),
          SizedBox(height: 36.h),
          _buildPasswordInput(),
          SizedBox(height: 18.h),
          _buildForgotPasswordText(),
          SizedBox(height: 50.h),
          _buildLoginButton(context),
          SizedBox(height: 22.h),
          _buildSignUpLink(context),
          SizedBox(height: 38.h),
        ],
      ),
    );
  }

  Widget _buildEmailInput() {
    return CustomTextFormField(
      controller: emailController,
      hintText: "Enter your email",
      textInputType: TextInputType.emailAddress,
      validator: _validateEmail,
      contentPadding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 14.h),
    );
  }

  Widget _buildPasswordInput() {
    return CustomTextFormField(
      controller: passwordController,
      hintText: "Enter your password",
      textInputType: TextInputType.visiblePassword,
      obscureText: _obscurePassword,
      validator: _validatePassword,
      contentPadding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 14.h),
      fillColor: Colors.white,
      textStyle: TextStyle(color: Colors.grey[600]),
      borderDecoration: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.h),
        borderSide: BorderSide.none,
      ),
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

  Widget _buildForgotPasswordText() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
          );
        },
        child: Text(
          "Forgot Password?",
          style: CustomTextStyles.bodyMediumTeal400,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return CustomElevatedButton(
      text: _isLoading ? "Logging in..." : "Login",
      margin: EdgeInsets.symmetric(horizontal: 26.h).copyWith(right: 32.h),
      onPressed: _isLoading ? null : () => _login(context),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.registerScreen),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account?",
                style: CustomTextStyles.bodyMediumImprimaBlack90014,
              ),
              TextSpan(
                text: " Sign up",
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
