import 'api_service.dart';

class SemesterService {
  static Future<List<Map<String, dynamic>>> getAllSemesters() async {
    try {
      final response = await ApiService.get('semester');
      
      if (response is List) {
        // Convert the response to a List of Maps
        final semesters = List<Map<String, dynamic>>.from(response);
        
        // Sort semesters in natural order (First, Second, Third, etc.)
        semesters.sort((a, b) {
          // Define the natural order of semesters
          const order = {
            'First': 1, 'Second': 2, 'Third': 3, 'Fourth': 4,
            'Fifth': 5, 'Sixth': 6, 'Seventh': 7, 'Eight': 8
          };
          
          final aValue = order[a['semester']] ?? 999;
          final bValue = order[b['semester']] ?? 999;
          
          return aValue.compareTo(bValue);
        });
        
        return semesters;
      }
      
      return [];
    } catch (e) {
      print('Error fetching semesters: $e');
      return [];
    }
  }
}