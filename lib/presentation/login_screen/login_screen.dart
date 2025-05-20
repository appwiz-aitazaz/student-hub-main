import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/presentation/dashboard/homescreen.dart';
import 'package:student_hub/services/api_service.dart';
import 'package:student_hub/services/auth_service.dart';
import 'package:student_hub/services/user_service.dart';
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

  // Implement the login method using AuthService
  void _login(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        print('Login response: $result'); // Debug log
        
        // Check if login was successful based on HTTP status code or message
        if (result != null && 
            (result['message'] == 'Student logged in successfully' || 
             result['status'] == 200 ||
             result['success'] == true)) {
          
          _showSnackBar("Login Successful", Colors.green);
          
          // Store login status in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          
          // Check profile completion
          await checkProfileCompletion(context);
        } else {
          // Extract error message from response
          final errorMessage = result != null 
              ? (result['message'] ?? 'Unknown error') 
              : 'Login failed';
          
          _showSnackBar("Login Failed: $errorMessage", Colors.red);
        }
      } catch (e) {
        print('Login error: $e');
        _showSnackBar("Unexpected Error: ${e.toString()}", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> checkProfileCompletion(BuildContext context) async {
    try {
      // Fetch user data from backend
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      print('Attempting to fetch profile with user ID: $userId');
      
      if (userId != null && userId.isNotEmpty) {
        final userDataResponse = await UserService.getUserProfile(userId);
        print('User profile API response: $userDataResponse'); // Debug log
        
        // Check if the API response is valid
        if (userDataResponse['success'] == true && userDataResponse['data'] != null) {
          // Save user data locally
          await UserService.saveUserMapToLocal(userDataResponse['data']);
          
          // Navigate based on profile completion status
          final isProfileComplete = userDataResponse['data']['isProfileComplete'] ?? false;
          
          print('Profile complete status: $isProfileComplete'); // Debug log
          
          if (isProfileComplete) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
          }
        } else {
          print('Invalid user data response: $userDataResponse');
          _checkLocalProfileCompletion(context);
        }
      } else {
        print('No user ID found in SharedPreferences after login');
        _checkLocalProfileCompletion(context);
      }
    } catch (e) {
      print('Error checking profile completion: $e');
      _checkLocalProfileCompletion(context);
    }
  }
  
  Future<void> _checkLocalProfileCompletion(BuildContext context) async {
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

