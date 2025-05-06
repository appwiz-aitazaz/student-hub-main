import 'package:flutter/material.dart';
import 'package:student_hub/widgets/app_drawer.dart';
import 'package:student_hub/widgets/screen_header.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/home_button.dart';
import 'package:intl/intl.dart';

class EnrollmentSchedulesScreen extends StatefulWidget {
  @override
  _EnrollmentSchedulesScreenState createState() => _EnrollmentSchedulesScreenState();
}

class _EnrollmentSchedulesScreenState extends State<EnrollmentSchedulesScreen> {
  final List<Map<String, dynamic>> _enrollmentSchedules = [
    {
      'srNumber': 1,
      'courseName': 'Software Engineering',
      'courseCode': 'CS-301',
      'term': 'Fall 2023',
      'startDate': DateTime(2023, 8, 15),
      'endDate': DateTime(2023, 8, 25),
      'status': 'Open',
    },
    {
      'srNumber': 2,
      'courseName': 'Database Systems',
      'courseCode': 'CS-302',
      'term': 'Fall 2023',
      'startDate': DateTime(2023, 8, 18),
      'endDate': DateTime(2023, 8, 28),
      'status': 'Open',
    },
    {
      'srNumber': 3,
      'courseName': 'Artificial Intelligence',
      'courseCode': 'CS-401',
      'term': 'Fall 2023',
      'startDate': DateTime(2023, 8, 20),
      'endDate': DateTime(2023, 8, 30),
      'status': 'Upcoming',
    },
    {
      'srNumber': 4,
      'courseName': 'Computer Networks',
      'courseCode': 'CS-303',
      'term': 'Fall 2023',
      'startDate': DateTime(2023, 8, 22),
      'endDate': DateTime(2023, 9, 1),
      'status': 'Upcoming',
    },
    {
      'srNumber': 5,
      'courseName': 'Mobile Application Development',
      'courseCode': 'CS-405',
      'term': 'Fall 2023',
      'startDate': DateTime(2023, 8, 25),
      'endDate': DateTime(2023, 9, 5),
      'status': 'Upcoming',
    },
    {
      'srNumber': 6,
      'courseName': 'Web Development',
      'courseCode': 'CS-304',
      'term': 'Fall 2023',
      'startDate': DateTime(2023, 8, 10),
      'endDate': DateTime(2023, 8, 20),
      'status': 'Closed',
    },
  ];

  String _selectedTerm = 'Fall 2023';
  final List<String> _terms = ['Fall 2023', 'Spring 2024', 'Summer 2024'];

  List<Map<String, dynamic>> get _filteredSchedules {
    return _enrollmentSchedules.where((schedule) => 
      schedule['term'] == _selectedTerm
    ).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'Upcoming':
        return Colors.blue;
      case 'Closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Enrollment Schedules'),
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
            const ScreenHeader(screenName: "Enrollment Schedules"),
            _buildTermSelector(),
            _buildInfoCard(),
            Expanded(
              child: _buildSchedulesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSelector() {
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
            'Select Term:',
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
                  value: _selectedTerm,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
                  items: _terms.map((term) => DropdownMenuItem(
                    value: term,
                    child: Text(term),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTerm = value!;
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

  Widget _buildInfoCard() {
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
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 8),
              const Text(
                'Enrollment Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Please note the enrollment dates for each course. You must enroll within the specified time period to secure your spot.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator('Open', Colors.green),
              _buildStatusIndicator('Upcoming', Colors.blue),
              _buildStatusIndicator('Closed', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

   Widget _buildSchedulesList() {
    return _filteredSchedules.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No schedules found for $_selectedTerm',
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
            padding: const EdgeInsets.all(16),
            itemCount: _filteredSchedules.length,
            itemBuilder: (context, index) {
              final schedule = _filteredSchedules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shadowColor: Colors.teal.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(schedule['status']).withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getStatusColor(schedule['status']),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${schedule['srNumber']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule['courseName'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  schedule['courseCode'],
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
                              color: _getStatusColor(schedule['status']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              schedule['status'],
                              style: const TextStyle(
                                color: Colors.white,
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
                        children: [
                          _buildInfoRow(
                            'Term',
                            schedule['term'],
                            Icons.school,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Start Date',
                            DateFormat('MMM dd, yyyy').format(schedule['startDate']),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'End Date',
                            DateFormat('MMM dd, yyyy').format(schedule['endDate']),
                            Icons.event_available,
                          ),
                          const SizedBox(height: 16),
                          _buildEnrollButton(schedule['status']),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.teal.shade700,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollButton(String status) {
    bool isEnabled = status == 'Open';
    
    return ElevatedButton(
      onPressed: isEnabled 
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enrollment request submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            } 
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? Colors.teal : Colors.grey.shade300,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.grey.shade500,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEnabled ? Icons.how_to_reg : Icons.hourglass_empty,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            status == 'Open' 
                ? 'Enroll Now' 
                : status == 'Upcoming' 
                    ? 'Coming Soon' 
                    : 'Enrollment Closed',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  }