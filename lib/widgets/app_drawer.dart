import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/core/app_export.dart';
import 'package:student_hub/presentation/dashboard/challan.dart';
import 'package:student_hub/presentation/dashboard/course_withdraw_screen.dart';
import 'package:student_hub/presentation/dashboard/notification_screen.dart';
import 'package:student_hub/presentation/dashboard/transcript_screen.dart';
import 'package:student_hub/providers/user_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get user data from provider or pass it as a parameter
    final userData = Provider.of<UserProvider>(context).userData;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default profile picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                // User name from database
                Text(
                  userData?.fullName ?? 'Student',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Roll number from database
                Text(
                  userData?.rollNo ?? 'Roll Number',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Rest of drawer items remain the same
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
              leading: Icon(Icons.receipt_long, color: Colors.teal.shade700),
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
              // Clear user data from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // This clears all stored preferences
              
              // Navigate to login screen and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}