import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:student_hub/widgets/home_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class EnrolledCoursesScreen extends StatefulWidget {
  @override
  _EnrolledCoursesScreenState createState() => _EnrolledCoursesScreenState();
}

class _EnrolledCoursesScreenState extends State<EnrolledCoursesScreen> {
  List<Map<String, dynamic>> _enrolledCourses = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterType = 'All';
  String _currentSemester = '';
  int _totalCredits = 0;
  int _compulsoryCourses = 0;
  int _electiveCourses = 0;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null || userId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }
      
      // Fetch courses from API
      final response = await ApiService.get('course/getcourses/$userId');
      
      if (response != null && response is List) {
        // Convert API response to list of maps
        final courses = List<Map<String, dynamic>>.from(response);
        
        // Calculate statistics
        int totalCredits = 0;
        int compulsory = 0;
        int elective = 0;
        
        // Process courses
        for (var course in courses) {
          // Add credit hours
          totalCredits += (course['creditHours'] ?? 0) as int;
          
          // Determine course type based on course code
          if ((course['courseCode'] ?? '').toString().startsWith('ELEC')) {
            elective++;
          } else {
            compulsory++;
          }
        }
        
        // Get current semester from user data if available
        final userData = prefs.getString('userData');
        String semesterName = 'Current Semester';
        if (userData != null) {
          final userDataMap = json.decode(userData);
          semesterName = userDataMap['semester']?['semester'] ?? 'Current Semester';
        }
        
        setState(() {
          _enrolledCourses = courses;
          _isLoading = false;
          _totalCredits = totalCredits;
          _compulsoryCourses = compulsory;
          _electiveCourses = elective;
          _currentSemester = semesterName;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No courses found for your semester';
          _enrolledCourses = [];
        });
      }
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load courses: ${e.toString()}';
        _enrolledCourses = [];
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _enrolledCourses.where((course) {
      // Update field names to match backend response
      final nameMatches = 
          (course['courseName'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (course['courseCode'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Determine course type based on course code since backend doesn't provide type
      final isElective = (course['courseCode'] ?? '').toString().startsWith('ELEC');
      final courseType = isElective ? 'Elective' : 'Compulsory';
      
      final typeMatches = _filterType == 'All' || courseType == _filterType;
      
      return nameMatches && typeMatches;
    }).toList();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Enrolled Courses'),
      drawer: AppDrawer(),
      floatingActionButton: const HomeButton(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            const ScreenHeader(screenName: "Enrolled Courses"),
            _buildSearchAndFilter(),
            _buildSemesterInfo(),
            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No courses found",
                            style: TextStyle(
                              fontSize: 18, 
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try adjusting your search or filter",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        return _buildCourseCard(course);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find Your Courses",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by course name or code',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.teal.shade600),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade100, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.teal.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filter by type:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterType,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Courses')),
                        DropdownMenuItem(value: 'Compulsory', child: Text('Compulsory')),
                        DropdownMenuItem(value: 'Elective', child: Text('Elective')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterType = value!;
                        });
                      },
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Make the semester title responsive
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.9), size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Semester: $_currentSemester',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Make the info items row responsive
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildInfoItem('Total Courses', _enrolledCourses.length.toString()),
              _buildInfoItem('Total Credits', _totalCredits.toString()),
              _buildInfoItem('Compulsory', _compulsoryCourses.toString()),
              _buildInfoItem('Elective', _electiveCourses.toString()),
            ],
          ),
        ],
      ),
    );
  }

  // Update the info item to be responsive
  Widget _buildInfoItem(String label, String value) {
    return Container(
      width: MediaQuery.of(context).size.width < 400 ? 
          (MediaQuery.of(context).size.width - 64) / 2 : // For very small screens, 2 items per row
          null, // Let it take natural width on larger screens
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    // Determine course type based on course code
    final isElective = (course['courseCode'] ?? '').toString().startsWith('ELEC');
    final courseType = isElective ? 'Elective' : 'Compulsory';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.teal.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Make the top row responsive
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.book,
                    color: Colors.teal.shade700,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['courseName'] ?? 'Unknown Course',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['courseCode'] ?? 'No Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isElective ? Colors.amber.shade700 : Colors.teal.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    courseType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Make the bottom row responsive
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range, color: Colors.grey.shade600, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Added: ${_formatDate(course['createdAt'])}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${course['creditHours'] ?? 0} Credits',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

// Add this method to your _EnrolledCoursesScreenState class
  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }