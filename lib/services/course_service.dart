import 'api_service.dart';

class CourseService {
  // Get all courses
  static Future<Map<String, dynamic>> getAllCourses() async {
    try {
      final response = await ApiService.get('course/');
      
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

  // Find specific courses
  static Future<Map<String, dynamic>> findCourses(String query) async {
    try {
      final response = await ApiService.get('course/find?query=$query');
      
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

  // Update a course
  static Future<Map<String, dynamic>> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await ApiService.put('course/update/$courseId', courseData);
      
      return {
        'success': true,
        'message': response['message'] ?? 'Course updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Delete a course
  static Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    try {
      final response = await ApiService.delete('course/delete/$courseId');
      
      return {
        'success': true,
        'message': response['message'] ?? 'Course deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}