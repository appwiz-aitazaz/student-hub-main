import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal,
      title: Row(
        children: [
          Image.asset(
            'assets/images/uogpng.png',
            height: 36,
            width: 36,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () async {
            // Get the position for the menu to appear below the bell icon
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            
            final position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
                button.localToGlobal(Offset(button.size.width, button.size.height), ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            
            // Fetch notifications from service
            // In a real app, you would fetch these from your backend
            final notifications = await _fetchNotifications();
            
            if (notifications.isEmpty) {
              // Show a message if there are no notifications
              showMenu(
                context: context,
                position: position,
                items: [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('No new notifications'),
                  ),
                ],
              );
            } else {
              // Show the notifications in a menu
              showMenu(
                context: context,
                position: position,
                items: [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  ...notifications.map((notification) => PopupMenuItem(
                    enabled: false,
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          notification.message,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Divider(),
                      ],
                    ),
                  )).toList(),
                  PopupMenuItem(
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/notifications');
                        },
                        child: Text('View All', style: TextStyle(color: Colors.teal)),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
        // Single default profile icon with menu options
        InkWell(
          onTap: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(100, 80, 0, 0),
              items: [
                PopupMenuItem(
                  value: 'profile',
                  child: const Text('My Profile'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: const Text('Logout'),
                ),
              ],
            ).then((value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                // Clear user data from SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // This clears all stored preferences
                
                // Navigate to login screen and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 24,
                color: Colors.teal,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Helper method to fetch notifications
  Future<List<AdminNotification>> _fetchNotifications() async {
    // In a real app, you would fetch these from your backend
    // For now, we'll return some dummy data
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
    
    return [
      AdminNotification(
        id: '1',
        title: 'Fee Submission',
        message: 'Last date for fee submission is October 15th',
        date: DateTime.now().subtract(Duration(hours: 2)),
        isRead: false,
      ),
      AdminNotification(
        id: '2',
        title: 'Mid-term Exams',
        message: 'Mid-term exams will start from November 1st',
        date: DateTime.now().subtract(Duration(days: 1)),
        isRead: false,
      ),
      AdminNotification(
        id: '3',
        title: 'Library Notice',
        message: 'Return all borrowed books by October 20th',
        date: DateTime.now().subtract(Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}

// Create a model class for notifications
class AdminNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });
}