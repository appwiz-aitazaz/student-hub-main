import 'package:flutter/material.dart';
import '../../widgets/announcement_item.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/info_item.dart';
import '../../widgets/screen_header.dart';
import '../login_screen/login_screen.dart';
import 'document_submission_screen.dart';
import 'enrolled_courses.dart';
import 'enrollment_schedules.dart';
import 'notification_screen.dart';
import 'self_enrollment_screen.dart';
import 'complaint_screen.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/home':
            page = HomeScreen();
            break;
          case '/profile':
            page = ProfileScreen();
            break;
          case '/notifications':
            page = AllNotificationsScreen();
            break;
          // case '/settings':
          //   page = SettingsScreen();
            //break;
          case '/login':
            page = LoginScreen();
            break;
          case '/enrolled_courses':
            page = EnrolledCoursesScreen();
            break;
          case '/self_enrollment':
            page = SelfEnrollmentScreen();
            break;
          case '/enrollment_schedules':
            page = EnrollmentSchedulesScreen();
            break;
          case '/document_submission':
            page = DocumentSubmissionScreen();
            break;
          case '/complaints':
            page = ComplaintScreen();
            break;
          // case '/challan_management':
          //   page = ChallanManagementScreen();
          //   break;
          // case '/course_withdraw':
          //   page = CourseWithdrawScreen();
          //  break;
          //case '/transcript':
            //page = TranscriptScreen();
           // break;
          
          default:
            page = HomeScreen();
        }  
          
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.25).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Update the _HomeScreenState class
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await UserService.getCurrentUser();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  // Update the build method to use _userData
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'StudentHub'),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ScreenHeader(screenName: "Profile"),
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: _buildProfileCard(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Move this method inside the _HomeScreenState class
  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Default profile picture centered with increased size
            Container(
              width: 120, // Increased size
              height: 120, // Increased size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.teal.shade700,
                  width: 3, // Thicker border
                ),
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.person,
                size: 70, // Larger icon
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            // Student name below the picture with larger font
            Text(
              _userData?.fullName ?? "Unknown Student",
              style: TextStyle(
                fontSize: 26, // Larger font
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1.5),
            const SizedBox(height: 16),
            // Personal Information section - centered with larger font
            Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 22, // Larger font
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Rest of the profile information with increased spacing and font size
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem("Roll Number", _userData?.rollNo ?? "Not available"),
                  const SizedBox(height: 12),
                  _buildInfoItem("Department", _userData?.department ?? "Not available"),
                  const SizedBox(height: 12),
                  _buildInfoItem("Faculty", _userData?.faculty ?? "Not available"),
                  const SizedBox(height: 12),
                  _buildInfoItem("Program Level", _userData?.programLevel ?? "Not available"),
                  const SizedBox(height: 12),
                  _buildInfoItem("Program", _userData?.program ?? "Not available"),
                  const SizedBox(height: 12),
                  _buildInfoItem("Semester", _userData?.semester ?? "Not available"),
                  const SizedBox(height: 12),
                  _buildInfoItem("CGPA", _userData?.cgpa ?? "Not available"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Custom info item with improved styling
  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          ":",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Profile'),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Adding the home icon with screen name
const ScreenHeader(screenName: "Profile"),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/images/prof_pic.jpg'),
                onBackgroundImageError: (exception, stackTrace) {
                  print('Error loading profile image: $exception');
                },
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text(
                'Mohammed Aitazaz Jamil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              Text(
                '21011519-110',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Faculty: Faculty of Computing',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Program: BS Computer Science',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Semester: 8th',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Status: Undergraduate',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'CGPA: 3.75',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enrollment Date: 2021-09-01',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Expected Graduation: 2025-06-30',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Email: student@example.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Phone: +123-456-7890',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Address: 123 University Road',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}