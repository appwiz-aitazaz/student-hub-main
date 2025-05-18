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
      appBar: const CustomAppBar(title: 'StudentHub'), // Only changed the title to 'StudentHub'
      drawer: const AppDrawer(), // Kept as is
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ScreenHeader(screenName: "Profile"),
                    Container(
                      margin: const EdgeInsets.all(12),
                      child: _buildProfileCard(),  // Use the new method here
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "News and Announcements",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                          ),
                          const Divider(color: Colors.teal),
                          const AnnouncementItem(
                            title: "Mid-term Exams Schedule",
                            description: "Mid-term exams will start from 15th October. Check your portal for detailed schedule.",
                            date: "2023-09-30",
                          ),
                          const AnnouncementItem(
                            title: "Fee Submission Deadline",
                            description: "Last date for fee submission is 10th October. Late fee will be charged afterwards.",
                            date: "2023-09-28",
                          ),
                          const AnnouncementItem(
                            title: "Career Fair 2023",
                            description: "Annual career fair will be held on 20th October. Register now to participate.",
                            date: "2023-09-25",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align all content
          children: [
            // Default profile picture centered
            Container(
              width: 100, // Larger size
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.teal.shade700,
                  width: 2,
                ),
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.person,
                size: 60, // Larger icon
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            // Student name below the picture
            Text(
              _userData?.fullName ?? "Unknown Student",
              style: TextStyle(
                fontSize: 22, // Larger font
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            // Email removed
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Personal Information section - centered
            Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center, // Center the text
            ),
            const SizedBox(height: 12),
            // Rest of the profile information
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoItem(
                    label: "Roll Number", 
                    value: _userData?.rollNo ?? "Not available"
                  ),
                  InfoItem(
                    label: "Department", 
                    value: _userData?.department ?? "Not available"
                  ),
                  InfoItem(
                    label: "Faculty", 
                    value: _userData?.faculty ?? "Not available"
                  ),
                  InfoItem(
                    label: "Program Level", 
                    value: _userData?.programLevel ?? "Not available"
                  ),
                  InfoItem(
                    label: "Program", 
                    value: _userData?.program ?? "Not available"
                  ),
                  InfoItem(
                    label: "Semester", 
                    value: _userData?.semester ?? "Not available"
                  ),
                  InfoItem(
                    label: "CGPA", 
                    value: _userData?.cgpa ?? "Not available"
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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