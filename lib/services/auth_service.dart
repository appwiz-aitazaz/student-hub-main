import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // Register a new user
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.post('student/register', userData);
      
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
      }
      
      return {
        'success': true,
        'message': response['message'] ?? 'Registration successful',
        'data': response
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post('student/login', {
        'email': email,
        'password': password,
      });
      
      print('Login response: $response'); // Debug print to see the full response
      
      // The issue is here - we need to handle the case where token is not in the response
      // but _id is directly in the response
      final prefs = await SharedPreferences.getInstance();
      
      // Check if _id exists in the response (directly at the top level)
      if (response['_id'] != null) {
        await prefs.setString('user_id', response['_id'].toString());
        print('Saved user_id to SharedPreferences: ${response['_id']}');
      } else {
        print('Warning: No _id found in login response');
      }
      
      // Store token if available
      if (response['token'] != null) {
        await prefs.setString('auth_token', response['token']);
      }
      
      // Check if profile is complete - this might need adjustment based on your response
      bool isProfileComplete = false;
      if (response['user'] != null && response['user']['isProfileComplete'] != null) {
        isProfileComplete = response['user']['isProfileComplete'];
      }
      await prefs.setBool('isProfileComplete', isProfileComplete);
      
      return {
        'success': response['message'] == 'Student logged in successfully',
        'message': response['message'] ?? 'Login successful',
        'data': response
      };
    } catch (e) {
      print('Auth service login error: $e');
      
      // Check if the error has a response with a message
      if (e is Exception && e.toString().contains('message')) {
        final errorMsg = e.toString().split('message')[1].trim();
        return {
          'success': false,
          'message': errorMsg,
        };
      }
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Get user by ID
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await ApiService.get('student/$userId');
      return {
        'success': true,
        'data': response
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }
  
  // Temporary method to manually set user ID for testing
  static Future<void> setTestUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    print('Manually set test user_id: $userId');
  }
  
  // Add this method to the AuthService class
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await ApiService.post('student/logout', {});
      
      // Clear local storage regardless of API response
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      return {
        'success': true,
        'message': 'Logged out successfully'
      };
    } catch (e) {
      print('Logout error: $e');
      // Still clear local storage even if API call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      return {
        'success': false,
        'message': 'Error during logout, but local session cleared'
      };
    }
  }
}