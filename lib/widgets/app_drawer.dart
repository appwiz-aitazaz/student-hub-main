import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/core/app_export.dart';
import 'package:student_hub/presentation/dashboard/challan.dart';
import 'package:student_hub/presentation/dashboard/course_withdraw_screen.dart';
import 'package:student_hub/presentation/dashboard/transcript_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/prof_pic.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mohammed Aitazaz Jamil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '21011519-110',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
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
              ListTile(
                title: const Text("Transcript"),
                onTap: () {
                  Navigator.pushNamed(context, '/transcript');
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
              Navigator.pushNamed(context, '/notifications');
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