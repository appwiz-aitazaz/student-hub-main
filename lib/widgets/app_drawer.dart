import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/core/app_export.dart';
import 'package:student_hub/presentation/dashboard/challan.dart';
import 'package:student_hub/presentation/dashboard/course_withdraw_screen.dart';
import 'package:student_hub/presentation/dashboard/notification_screen.dart';
import 'package:student_hub/presentation/dashboard/transcript_screen.dart';
import 'package:student_hub/providers/user_provider.dart';
import 'package:student_hub/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;
  
  // Update constructor to accept userData
  const AppDrawer({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get user name and roll number from userData or use defaults
    final String userName = userData?['fullName'] ?? 'Student Name';
    final String userRoll = userData?['rollNo'] ?? 'Roll Number';
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white, // Set text color to white
              ),
            ),
            accountEmail: Text(
              userRoll,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white, // Set text color to white
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.teal,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
          // Rest of your drawer items remain the same
          ExpansionTile(
            leading: const Icon(Icons.school),
            title: const Text("Enrollment"),
            children: [
              ListTile(
                title: const Text("Enrolled Courses"),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.enrolledCourses);
                },
              ),

              ListTile(
                title: const Text("Self Enrollment"),
                onTap: () {
                  Navigator.pushNamed(context, '/self_enrollment');
                },
              ),

              ListTile(
                title: const Text("Enrollment Schedules"),
                onTap: () {
                  Navigator.pushNamed(context, '/enrollment_schedules');
                },
              ),
            ],
          ),
                        ListTile(
              leading: Icon(Icons.receipt_long, color: Colors.black), // Changed from teal.shade700 to black
              title: Text('Challan Management'),
              onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChallanManagementScreen()),
               );
             },
           ),
               ExpansionTile(
            leading: const Icon(Icons.request_page),
            title: const Text("Requests"),
            children: [
              ListTile(
                title: const Text("Course Withdraw"),
                onTap: () {
                  Navigator.pop(context);
                        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseWithdrawScreen()),
        );
        },
              ),
              ListTile(
  title: const Text("Transcript"),
  onTap: () {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TranscriptScreen()),
    );
  },
),
              
            ],
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Document Submission"),
            onTap: () {
              Navigator.pushNamed(context, '/document_submission');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllNotificationsScreen()),
          );
  },
),
            
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text("Complaints"),
            onTap: () {
              Navigator.pushNamed(context, '/complaints');
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              
              try {
                // Call logout API
                final result = await AuthService.logout();
                
                // Close loading dialog
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
                
                // Navigate to login screen and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                // Close loading dialog
                Navigator.pop(context);
                
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
                
                // Still navigate to login screen as fallback
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}