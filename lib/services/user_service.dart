import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  // Get current user profile
  static Future<UserModel> getCurrentUser() async {
    try {
      final response = await ApiService.get('student/profile');
      final user = UserModel.fromJson(response['data']);
      
      // Save profile completion status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProfileComplete', user.isProfileComplete);
      
      return user;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Get current user profile
  // Update the getUserProfile method to accept a userId parameter
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      print('Attempting to fetch user profile for ID: $userId');
      
      if (userId.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid user ID',
          'data': <String, dynamic>{} // Return empty map instead of null
        };
      }
      
      final response = await ApiService.get('student/$userId');
      
      if (response == null) {
        return {
          'success': false,
          'message': 'Failed to fetch user profile',
          'data': <String, dynamic>{}
        };
      }
      
      return {
        'success': true,
        'message': 'User profile fetched successfully',
        'data': response
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      return {
        'success': false,
        'message': 'Failed to fetch user profile',
        'error': e.toString(),
        'data': <String, dynamic>{}
      };
    }
  }

  // Find a specific student
  static Future<Map<String, dynamic>> findStudent(String query) async {
    try {
      final response = await ApiService.get('student/find?query=$query');
      
      return {
        'success': true,
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Reset user password
  static Future<Map<String, dynamic>> resetPassword(String userId, String newPassword) async {
    try {
      final response = await ApiService.post(
        'student/reset-password/$userId', 
        {'password': newPassword}
      );
      
      return {
        'success': response['success'] ?? false,
        'message': response['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      print('Password reset error: $e');
      
      if (e is DioException) {
        final response = e.response;
        final statusCode = response?.statusCode;
        final responseData = response?.data;
        
        return {
          'success': false,
          'message': responseData?['message'] ?? e.message ?? 'Server error: $statusCode',
          'error': responseData,
          'statusCode': statusCode,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to reset password: ${e.toString()}',
      };
    }
  }

  // Complete user profile
  static Future<Map<String, dynamic>> completeProfile(Map<String, dynamic> profileData, {File? profileImage}) async {
    try {
      // First, upload profile data
      final response = await ApiService.post('student/add-user-details', profileData);
      
      // If profile image exists, upload it (this would require a separate API endpoint)
      if (profileImage != null) {
        // This would be implemented based on your backend's file upload API
        // For now, we'll just save the path locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', profileImage.path);
      }
      
      return {
        'success': response['success'] ?? false,
        'message': response['message'] ?? 'Profile updated',
      };
    } catch (e) {
      print('Profile completion error details: $e');
      
      // Pass through the actual error message
      if (e is DioException) {
        final response = e.response;
        final statusCode = response?.statusCode;
        final responseData = response?.data;
        
        return {
          'success': false,
          'message': responseData?['message'] ?? e.message ?? 'Server error: $statusCode',
          'error': responseData,
          'statusCode': statusCode,
          'rawError': e.toString()
        };
      }
      
      return {
        'success': false,
        'message': e.toString(),
        'rawError': e.toString()
      };
    }
  }

  // Save user data to SharedPreferences for offline access
  static Future<void> saveUserToLocal(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Handle nullable fields by providing empty string as fallback
      await prefs.setString('user_id', user.id ?? '');
      await prefs.setString('fullName', user.fullName ?? '');
      await prefs.setString('email', user.email ?? '');
      await prefs.setString('phone', user.phone ?? '');
      await prefs.setString('username', user.username ?? '');
      
      // Use null-aware operators for optional fields
      if (user.dob != null) await prefs.setString('dob', user.dob!);
      if (user.gender != null) await prefs.setString('gender', user.gender!);
      if (user.cnic != null) await prefs.setString('cnic', user.cnic!);
      if (user.domicile != null) await prefs.setString('domicile', user.domicile!);
      if (user.nationality != null) await prefs.setString('nationality', user.nationality!);
      if (user.religion != null) await prefs.setString('religion', user.religion!);
      if (user.program != null) await prefs.setString('program', user.program!);
      if (user.semester != null) await prefs.setString('semester', user.semester!);
      if (user.department != null) await prefs.setString('department', user.department!);
      
      // Use rollNo instead of registrationNumber
      if (user.rollNo != null) await prefs.setString('rollNo', user.rollNo!);
      
      if (user.faculty != null) await prefs.setString('faculty', user.faculty!);
      if (user.programLevel != null) await prefs.setString('programLevel', user.programLevel!);
      
      // Use semester instead of currentSemester
      // (semester is already saved above)
      
      if (user.cgpa != null) await prefs.setString('cgpa', user.cgpa!);
      
      await prefs.setBool('isProfileComplete', user.isProfileComplete);
      
      print('User data saved locally: ${user.fullName}');
    } catch (e) {
      print('Error saving user data locally: $e');
    }
  }
  
  // Save user data from map to SharedPreferences
  static Future<void> saveUserMapToLocal(Map<String, dynamic>? userData) async {
    if (userData == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Save profile completion status
    await prefs.setBool('isProfileComplete', userData['isProfileComplete'] ?? false);
    
    // Save other user data as needed
    if (userData['name'] != null) await prefs.setString('name', userData['name']);
    if (userData['email'] != null) await prefs.setString('email', userData['email']);
    if (userData['dob'] != null) await prefs.setString('dob', userData['dob']);
    if (userData['gender'] != null) await prefs.setString('gender', userData['gender']);
    if (userData['cnic'] != null) await prefs.setString('cnic', userData['cnic']);
    if (userData['domicile'] != null) await prefs.setString('domicile', userData['domicile']);
    if (userData['nationality'] != null) await prefs.setString('nationality', userData['nationality']);
    if (userData['religion'] != null) await prefs.setString('religion', userData['religion']);
    if (userData['program'] != null) await prefs.setString('program', userData['program']);
    if (userData['semester'] != null) await prefs.setString('semester', userData['semester']);
    if (userData['department'] != null) await prefs.setString('department', userData['department']);
  }
  
  // Add this method to your UserService class
  // Update profile with user ID from token
  static Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await ApiService.put('student/update/$userId', profileData);
      return response;
    } catch (e) {
      print('Error updating profile: $e');
      return {
        'success': false,
        'message': 'Failed to update profile',
        'error': e.toString()
      };
    }
  }}