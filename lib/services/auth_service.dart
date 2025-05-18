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
      
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await prefs.setString('user_id', response['_id']);

        // Check if profile is complete
        bool isProfileComplete = response['user'] != null && 
                               response['user']['isProfileComplete'] == true;
        await prefs.setBool('isProfileComplete', isProfileComplete);
        
        return {
          'success': true,
          'message': response['message'] ?? 'Login successful',
          'data': response
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  // Get user ID from SharedPreferences
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  // Get user data by ID
  static Future<Map<String, dynamic>> getUserById(String id) async {
     String? id = await getUserId();
    try {
      final response = await ApiService.get('student/find/$id');
      
      if (response['success'] && response['data'] != null) {
        // Save user data to local storage
        final prefs = await SharedPreferences.getInstance();
        final userData = response['data'];
        
        // Save basic user information
        if (userData['_id'] != null) await prefs.setString('user_id', userData['_id']);
        if (userData['name'] != null) await prefs.setString('name', userData['name']);
        if (userData['email'] != null) await prefs.setString('email', userData['email']);
        if (userData['phone'] != null) await prefs.setString('phone', userData['phone']);
        
        // Save profile information if available
        if (userData['dob'] != null) await prefs.setString('dob', userData['dob']);
        if (userData['gender'] != null) await prefs.setString('gender', userData['gender']);
        if (userData['cnic'] != null) await prefs.setString('cnic', userData['cnic']);
        if (userData['domicile'] != null) await prefs.setString('domicile', userData['domicile']);
        if (userData['nationality'] != null) await prefs.setString('nationality', userData['nationality']);
        if (userData['religion'] != null) await prefs.setString('religion', userData['religion']);
        if (userData['program'] != null) await prefs.setString('program', userData['program']);
        if (userData['semester'] != null) await prefs.setString('semester', userData['semester']);
        if (userData['department'] != null) await prefs.setString('department', userData['department']);
        if (userData['registrationNumber'] != null) await prefs.setString('registrationNumber', userData['registrationNumber']);
        if (userData['faculty'] != null) await prefs.setString('faculty', userData['faculty']);
        if (userData['programLevel'] != null) await prefs.setString('programLevel', userData['programLevel']);
        if (userData['currentSemester'] != null) await prefs.setString('currentSemester', userData['currentSemester']);
        if (userData['cgpa'] != null) await prefs.setString('cgpa', userData['cgpa'].toString());
        
        // Save profile completion status
        await prefs.setBool('isProfileComplete', userData['isProfileComplete'] ?? false);
      }
      
      return {
        'success': response['success'] ?? false,
        'message': response['message'] ?? 'User data retrieved',
        'data': response['data']
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      await ApiService.post('student/logout', {});
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('isProfileComplete');
      
      return {
        'success': true,
        'message': 'Logout successful',
      };
    } catch (e) {
      // Even if API call fails, clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('isProfileComplete');
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(String userId, String newPassword) async {
    try {
      final response = await ApiService.post('student/reset-password/$userId', {
        'password': newPassword,
      });
      
      return {
        'success': true,
        'message': response['message'] ?? 'Password reset successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}