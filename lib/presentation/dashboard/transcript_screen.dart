import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:student_hub/services/api_service.dart';
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/home_button.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({Key? key}) : super(key: key);

  @override
  _TranscriptScreenState createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _transcriptData;

  @override
  void initState() {
    super.initState();
    _fetchTranscript();
  }

  Future<void> _fetchTranscript() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }

      // Updated API endpoint to match the working Postman endpoint
      final response = await ApiService.get('/transcript/${userId}');

      if (response != null) {
        if (response['message'] == "Transcript not found for this user") {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No transcript found for your roll number';
          });
          return;
        }

        setState(() {
          _transcriptData = response;
          _isLoading = false;
        });
        print('Transcript data fetched successfully: $_transcriptData');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load transcript data';
        });
      }
    } catch (e) {
      print('Error fetching transcript: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().contains('404') 
            ? 'No transcript found for your account' 
            : 'Error: ${e.toString()}';
      });
    }
  }

  Widget _buildTranscriptContent() {
    if (_transcriptData == null) {
      return const Center(child: Text('No transcript data available'));
    }

    final results = _transcriptData!['results'] as List;
    double cgpa = 0;
    int totalCredits = 0;

    // Calculate CGPA
    for (var semester in results) {
      final credits = semester['semesterCreditHours'] as int;
      final sgpa = semester['sgpa'] as double;
      cgpa += sgpa * credits;
      totalCredits += credits;
    }
    cgpa = totalCredits > 0 ? cgpa / totalCredits : 0;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Roll Number: ${_transcriptData!['rollNo']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CGPA: ${cgpa.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  'Total Credit Hours: $totalCredits',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        ..._buildSemesterResults(results),
      ],
    );
  }

  List<Widget> _buildSemesterResults(List results) {
    return results.map<Widget>((semester) {
      final courses = semester['courses'] as List;
      
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.teal.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semester ${semester['semester']['semester']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'SGPA: ${semester['sgpa'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Course Code')),
                  DataColumn(label: Text('Course Name')),
                  DataColumn(label: Text('Credit Hours')),
                  DataColumn(label: Text('Grade')),
                ],
                rows: courses.map<DataRow>((course) {
                  final courseData = course['course'];
                  return DataRow(
                    cells: [
                      DataCell(Text(courseData['courseCode'])),
                      DataCell(Text(courseData['courseName'])),
                      DataCell(Text(courseData['creditHours'].toString())),
                      DataCell(
                        Text(
                          course['grade'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: course['grade'] == 'F' 
                                ? Colors.red 
                                : Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Academic Transcript'),
      drawer: const AppDrawer(),
      floatingActionButton: const HomeButton(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  onRefresh: _fetchTranscript,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const ScreenHeader(screenName: "Academic Transcript"),
                        _buildTranscriptContent(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }
}