import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/home_button.dart';

class SelfEnrollmentScreen extends StatefulWidget {
  @override
  _SelfEnrollmentScreenState createState() => _SelfEnrollmentScreenState();
}

class _SelfEnrollmentScreenState extends State<SelfEnrollmentScreen> {
  final int _maxCreditHours = 21;
  int _selectedCreditHours = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableCourses = [];
  List<Map<String, dynamic>> _selectedCourses = [];
  String _selectedSemester = 'Fall 2023';
  final List<String> _semesters = ['Fall 2023', 'Spring 2024', 'Summer 2024'];

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating API call with a delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data - in a real app, this would come from an API
    _availableCourses = [
      {
        'id': 1,
        'name': 'Software Engineering',
        'code': 'CS-301',
        'credits': 3,
        'instructor': 'Dr. Ahmed Khan',
        'description': 'Introduction to software engineering principles and practices.',
        'prerequisites': ['CS-201', 'CS-202'],
        'type': 'Core',
        'semester': 'Fall 2023',
      },
      {
        'id': 2,
        'name': 'Database Systems',
        'code': 'CS-302',
        'credits': 4,
        'instructor': 'Dr. Sarah Johnson',
        'description': 'Fundamentals of database design, implementation, and management.',
        'prerequisites': ['CS-201'],
        'type': 'Core',
        'semester': 'Fall 2023',
      },
      {
        'id': 3,
        'name': 'Artificial Intelligence',
        'code': 'CS-401',
        'credits': 3,
        'instructor': 'Dr. Michael Brown',
        'description': 'Introduction to artificial intelligence concepts and algorithms.',
        'prerequisites': ['CS-301', 'MATH-201'],
        'type': 'Elective',
        'semester': 'Fall 2023',
      },
      {
        'id': 4,
        'name': 'Computer Networks',
        'code': 'CS-303',
        'credits': 3,
        'instructor': 'Dr. Fatima Ali',
        'description': 'Fundamentals of computer networking and protocols.',
        'prerequisites': ['CS-201'],
        'type': 'Core',
        'semester': 'Fall 2023',
      },
      {
        'id': 5,
        'name': 'Mobile Application Development',
        'code': 'CS-405',
        'credits': 3,
        'instructor': 'Dr. John Smith',
        'description': 'Development of applications for mobile devices.',
        'prerequisites': ['CS-301'],
        'type': 'Elective',
        'semester': 'Fall 2023',
      },
      {
        'id': 6,
        'name': 'Web Development',
        'code': 'CS-304',
        'credits': 3,
        'instructor': 'Dr. Lisa Wong',
        'description': 'Principles and practices of web application development.',
        'prerequisites': ['CS-201'],
        'type': 'Core',
        'semester': 'Fall 2023',
      },
      {
        'id': 7,
        'name': 'Operating Systems',
        'code': 'CS-305',
        'credits': 4,
        'instructor': 'Dr. Robert Johnson',
        'description': 'Concepts and design of operating systems.',
        'prerequisites': ['CS-201', 'CS-202'],
        'type': 'Core',
        'semester': 'Fall 2023',
      },
      {
        'id': 8,
        'name': 'Machine Learning',
        'code': 'CS-402',
        'credits': 3,
        'instructor': 'Dr. Emily Chen',
        'description': 'Introduction to machine learning algorithms and applications.',
        'prerequisites': ['CS-401', 'MATH-301'],
        'type': 'Elective',
        'semester': 'Fall 2023',
      },
      {
        'id': 9,
        'name': 'Computer Graphics',
        'code': 'CS-403',
        'credits': 3,
        'instructor': 'Dr. David Wilson',
        'description': 'Fundamentals of computer graphics and visualization.',
        'prerequisites': ['CS-201', 'MATH-201'],
        'type': 'Elective',
        'semester': 'Fall 2023',
      },
      {
        'id': 10,
        'name': 'Cybersecurity',
        'code': 'CS-404',
        'credits': 3,
        'instructor': 'Dr. James Anderson',
        'description': 'Introduction to cybersecurity principles and practices.',
        'prerequisites': ['CS-303'],
        'type': 'Elective',
        'semester': 'Fall 2023',
      },
    ];

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSavedEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEnrollments = prefs.getString('selectedCourses');
    
    if (savedEnrollments != null) {
      final List<dynamic> decoded = jsonDecode(savedEnrollments);
      setState(() {
        _selectedCourses = List<Map<String, dynamic>>.from(decoded);
        _calculateSelectedCredits();
      });
    }
  }

  Future<void> _saveEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCourses', jsonEncode(_selectedCourses));
  }

  void _calculateSelectedCredits() {
    _selectedCreditHours = _selectedCourses.fold(0, (sum, course) => sum + (course['credits'] as int));
  }

  void _toggleCourseSelection(Map<String, dynamic> course) {
    final isSelected = _selectedCourses.any((c) => c['id'] == course['id']);
    
if (isSelected) {
      // Don't deselect when clicking on already selected course
      return;
    } else {
      final newTotalCredits = _selectedCreditHours + course['credits'];

      if (newTotalCredits > _maxCreditHours) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot add course. Maximum credit limit of $_maxCreditHours would be exceeded.',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        setState(() {
          _selectedCourses.add(course);
          _calculateSelectedCredits();
        });
      }
    }
    
    _saveEnrollments();
  }

  // Add a new method to handle course removal
  // Modify the _removeCourse method to improve the dialog UI
  void _removeCourse(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.amber.shade700,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cancel Enrollment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to cancel your enrollment request for:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        course['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['code'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course['credits']} Credit Hours',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Keep Enrollment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                   const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCourses.removeWhere((c) => c['id'] == course['id']);
                            _submittedCourses.removeWhere((c) => c['id'] == course['id']);
                            _calculateSelectedCredits();
                          });
                          _saveEnrollments();
                          _saveSubmittedCourses();
                          Navigator.of(context).pop();
                             // Show success message after cancellation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text('Enrollment for ${course['code']} cancelled successfully'),
                                ],
                              ),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel Enrollment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


    // Add this getter to filter courses by selected semester
  List<Map<String, dynamic>> get _filteredCourses {
    return _availableCourses.where((course) => 
      course['semester'] == _selectedSemester
    ).toList();
  }

  // Add a new field to track submitted courses
  List<Map<String, dynamic>> _submittedCourses = [];

  void _submitEnrollment() {
    if (_selectedCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one course to enroll.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    // In a real app, this would send the enrollment request to a server
    setState(() {
      // Mark all selected courses as submitted
      _submittedCourses = List.from(_selectedCourses);
    });
    
    // Save the submitted courses
    _saveSubmittedCourses();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Enrollment request submitted successfully'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

// Add method to save submitted courses
  Future<void> _saveSubmittedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('submittedCourses', jsonEncode(_submittedCourses));
  }

// Load submitted courses in initState
  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadSavedEnrollments();
    _loadSubmittedCourses();
  }

  // Add method to load submitted courses
  Future<void> _loadSubmittedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSubmissions = prefs.getString('submittedCourses');
    
    if (savedSubmissions != null) {
      final List<dynamic> decoded = jsonDecode(savedSubmissions);
      setState(() {
        _submittedCourses = List<Map<String, dynamic>>.from(decoded);
      });
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Self Enrollment'),
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
            const ScreenHeader(screenName: "Self Enrollment"),
            _buildSemesterSelector(),
            _buildCreditInfoCard(),
            Expanded(
              child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  )
                : _buildCoursesList(),
            ),
            if (_selectedCourses.isNotEmpty)
              _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

Widget _buildSemesterSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Text(
            'Select Semester:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSemester,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
                  items: _semesters.map((semester) => DropdownMenuItem(
                    value: semester,
                    child: Text(semester),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value!;
                    });
                  },
                  style: TextStyle(
                    color: Colors.teal.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditInfoCard() {
    final remainingCredits = _maxCreditHours - _selectedCreditHours;
    final creditPercentage = _selectedCreditHours / _maxCreditHours;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Credit Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_selectedCreditHours / $_maxCreditHours',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Remaining: $remainingCredits credit hours',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: creditPercentage,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                creditPercentage > 0.9 ? Colors.red.shade300 : Colors.white,
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

 // Modify the card in _buildCoursesList to include a remove button for selected courses
  Widget _buildCoursesList() {
    return _filteredCourses.isEmpty
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
                  'No courses available for $_selectedSemester',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredCourses.length,
            itemBuilder: (context, index) {
              final course = _filteredCourses[index];
              final isSelected = _selectedCourses.any((c) => c['id'] == course['id']);
              final isSubmitted = _submittedCourses.any((c) => c['id'] == course['id']);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shadowColor: Colors.teal.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () => _toggleCourseSelection(course),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected
                              ? Border.all(color: Colors.teal.shade700, width: 2)
                              : null,
                        ),
                        child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.teal.shade50
                                : Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? Icons.check : Icons.book,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.teal.shade800
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course['code'],
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${course['credits']} Credits',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.teal.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Instructor:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      course['instructor'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 18,
                                    color: Colors.teal.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Type:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    course['type'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: course['type'] == 'Core'
                                          ? Colors.blue.shade700
                                          : Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                course['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (course['prerequisites'].isNotEmpty) ...[
                                Text(
                                  'Prerequisites:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: (course['prerequisites'] as List).map((prereq) => Chip(
                                    label: Text(
                                      prereq,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.teal.shade600,
                                    padding: const EdgeInsets.all(0),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                 // Add a remove button for selected courses
                     if (isSubmitted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => _removeCourse(course),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _submitEnrollment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.teal.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.send),
            SizedBox(width: 12),
            Text(
              'SUBMIT ENROLLMENT REQUEST',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}