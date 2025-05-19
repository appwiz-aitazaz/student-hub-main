import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/services/user_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      print('Fetching user data with ID: $userId');
      
      if (userId == null || userId.isEmpty) {
        print('No user ID found in SharedPreferences');
        setState(() {
          _isLoading = false;
          _error = 'User ID not found. Please login again.';
        });
        return;
      }
      
      final response = await UserService.getUserProfile(userId);
      
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _userData = response['data'];
          _isLoading = false;
        });
        print('User data fetched successfully: $_userData');
      } else {
        setState(() {
          _isLoading = false;
          _error = response['message'] ?? 'Failed to fetch user data';
        });
        print('Error fetching user data: ${response['message']}');
        
        // Fallback to locally stored data if API fails
        _loadLocalUserData();
      }
    } catch (e) {
      print('Exception while fetching user data: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      
      // Fallback to locally stored data if API fails
      _loadLocalUserData();
    }
  }

  // Add a method to load user data from SharedPreferences as fallback
  Future<void> _loadLocalUserData() async {
    try {
      print('Falling back to local user data');
      final prefs = await SharedPreferences.getInstance();
      
      // Create a map with the locally stored user data
      final Map<String, dynamic> localData = {
        'name': prefs.getString('name') ?? 'User',
        'email': prefs.getString('email') ?? '',
        'rollNo': prefs.getString('rollNo') ?? '',
        'program': prefs.getString('program') ?? '',
        'semester': prefs.getString('semester') ?? '',
        // Add other fields as needed
      };
      
      setState(() {
        _userData = localData;
      });
      
      print('Loaded local user data: $_userData');
    } catch (e) {
      print('Error loading local user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_userData['name'] ?? 'Student'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${_userData['email'] ?? 'Not available'}'),
                  Text('Roll No: ${_userData['rollNo'] ?? 'Not available'}'),
                  Text('Program: ${_userData['program'] ?? 'Not available'}'),
                  Text('Semester: ${_userData['semester'] ?? 'Not available'}'),
                ],
              ),
            ),
          ),
          
          // Add more dashboard content here
        ],
      ),
    );
  }
}