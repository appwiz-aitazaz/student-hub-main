import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/home_button.dart';

class CourseWithdrawScreen extends StatefulWidget {
  const CourseWithdrawScreen({Key? key}) : super(key: key);

  @override
  _CourseWithdrawScreenState createState() => _CourseWithdrawScreenState();
}

class _CourseWithdrawScreenState extends State<CourseWithdrawScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _enrolledCourses = [];
  List<String> _selectedCoursesForWithdrawal = [];
  bool _isWithdrawalInProgress = false;
  String _currentSemester = "Fall 2023";
  DateTime _withdrawalDeadline = DateTime.now().add(const Duration(days: 30));
  bool _isWithdrawalPeriodActive = true;

  @override
  void initState() {
    super.initState();
    _loadEnrolledCourses();
    _checkWithdrawalPeriod();
  }

  Future<void> _loadEnrolledCourses() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would come from an API
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString('enrolled_courses');

    setState(() {
      if (coursesJson != null) {
        final List<dynamic> decoded = json.decode(coursesJson);
        _enrolledCourses = decoded.cast<Map<String, dynamic>>();
      } else {
        // Sample data if no saved courses exist
        _enrolledCourses = [
          {
            'courseCode': 'CS-101',
            'title': 'Introduction to Programming',
            'creditHours': 3,
            'instructor': 'Dr. John Smith',
            'schedule': 'Mon, Wed 10:00 AM - 11:30 AM',
            'room': 'CS-Lab 1',
            'status': 'Active',
          },
          {
            'courseCode': 'CS-201',
            'title': 'Data Structures',
            'creditHours': 4,
            'instructor': 'Dr. Sarah Johnson',
            'schedule': 'Tue, Thu 1:00 PM - 3:00 PM',
            'room': 'CS-Lab 2',
            'status': 'Active',
          },
          {
            'courseCode': 'MATH-101',
            'title': 'Calculus I',
            'creditHours': 3,
            'instructor': 'Dr. Michael Brown',
            'schedule': 'Mon, Wed, Fri 9:00 AM - 10:00 AM',
            'room': 'Math Building 101',
            'status': 'Active',
          },
          {
            'courseCode': 'ENG-101',
            'title': 'English Composition',
            'creditHours': 3,
            'instructor': 'Prof. Emily Wilson',
            'schedule': 'Tue, Thu 11:00 AM - 12:30 PM',
            'room': 'Arts Building 203',
            'status': 'Active',
          },
          {
            'courseCode': 'PHY-101',
            'title': 'Physics I',
            'creditHours': 4,
            'instructor': 'Dr. Robert Chen',
            'schedule': 'Mon, Wed 2:00 PM - 3:30 PM, Fri 2:00 PM - 4:00 PM (Lab)',
            'room': 'Science Building 105, Lab 3',
            'status': 'Active',
          },
        ];
      }
      _isLoading = false;
    });
  }

  void _checkWithdrawalPeriod() {
    // In a real app, this would be fetched from the server
    // For demo purposes, we'll set a deadline 30 days from now
    final now = DateTime.now();
    setState(() {
      _isWithdrawalPeriodActive = now.isBefore(_withdrawalDeadline);
    });
  }

  Future<void> _saveEnrolledCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('enrolled_courses', json.encode(_enrolledCourses));
  }

  void _toggleCourseSelection(String courseCode) {
    setState(() {
      if (_selectedCoursesForWithdrawal.contains(courseCode)) {
        _selectedCoursesForWithdrawal.remove(courseCode);
      } else {
        _selectedCoursesForWithdrawal.add(courseCode);
      }
    });
  }

  Future<void> _withdrawFromSelectedCourses() async {
    if (_selectedCoursesForWithdrawal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one course to withdraw from'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Show confirmation dialog
 final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade800,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Withdrawal',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to withdraw from the following courses?',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _selectedCoursesForWithdrawal.map((courseCode) {
                    final course = _enrolledCourses.firstWhere(
                      (c) => c['courseCode'] == courseCode,
                      orElse: () => {},
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.remove_circle,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${course['courseCode']} - ${course['title']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${course['creditHours']} Credit Hours • ${course['instructor']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone. You may need to re-enroll in these courses in the future if you change your mind.',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Withdraw',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isWithdrawalInProgress = true;
    });

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // Update the status of withdrawn courses
      for (final courseCode in _selectedCoursesForWithdrawal) {
        final index = _enrolledCourses.indexWhere((c) => c['courseCode'] == courseCode);
        if (index != -1) {
          _enrolledCourses[index]['status'] = 'Withdrawn';
        }
      }
      _selectedCoursesForWithdrawal.clear();
      _isWithdrawalInProgress = false;
    });

    // Save the updated courses list
    await _saveEnrolledCourses();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Courses withdrawn successfully'),
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

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final isWithdrawn = course['status'] == 'Withdrawn';
    final isSelected = _selectedCoursesForWithdrawal.contains(course['courseCode']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isWithdrawn || !_isWithdrawalPeriodActive
            ? null
            : () => _toggleCourseSelection(course['courseCode']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${course['courseCode']} - ${course['title']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isWithdrawn ? Colors.grey.shade600 : Colors.teal.shade800,
                        decoration: isWithdrawn ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (!isWithdrawn && _isWithdrawalPeriodActive)
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleCourseSelection(course['courseCode']),
                      activeColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  if (isWithdrawn)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Withdrawn',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Schedule and building details removed
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    course['instructor'],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${course['creditHours']} Credit Hours',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final activeCourses = _enrolledCourses.where((c) => c['status'] == 'Active').toList();
    final withdrawnCourses = _enrolledCourses.where((c) => c['status'] == 'Withdrawn').toList();
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Course Withdrawal'),
      drawer: AppDrawer(),
      floatingActionButton: const HomeButton(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEnrolledCourses,
              color: Colors.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(screenName: "Course Withdrawal"),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isWithdrawalPeriodActive
                            ? Colors.blue.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isWithdrawalPeriodActive
                              ? Colors.blue.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isWithdrawalPeriodActive
                                    ? Icons.info
                                    : Icons.warning,
                                color: _isWithdrawalPeriodActive
                                    ? Colors.blue.shade700
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Withdrawal Period',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isWithdrawalPeriodActive
                                      ? Colors.blue.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isWithdrawalPeriodActive
                                ? 'You can withdraw from courses until ${DateFormat('MMMM d, yyyy').format(_withdrawalDeadline)}.'
                                : 'The course withdrawal period has ended.',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                          if (_isWithdrawalPeriodActive) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Note: Withdrawing from a course may affect your academic progress and tuition refund eligibility.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Current Semester: $_currentSemester',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                    if (activeCourses.isEmpty && withdrawnCourses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'You are not enrolled in any courses for this semester',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      if (activeCourses.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Active Courses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ),
                        ...activeCourses.map(_buildCourseCard).toList(),
                        if (_isWithdrawalPeriodActive && _selectedCoursesForWithdrawal.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton.icon(
                              onPressed: _isWithdrawalInProgress
                                  ? null
                                  : _withdrawFromSelectedCourses,
                              icon: _isWithdrawalInProgress
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.exit_to_app),
                              label: Text(
                                _isWithdrawalInProgress
                                    ? 'Processing...'
                                    : 'Withdraw from Selected Courses',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                      if (withdrawnCourses.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Withdrawn Courses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                        ...withdrawnCourses.map(_buildCourseCard).toList(),
                      ],
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}