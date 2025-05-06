import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

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
          onPressed: () {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            
            final position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
                button.localToGlobal(Offset(button.size.width, button.size.height), ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            
            showMenu(
              context: context,
              position: position,
              items: [
                PopupMenuItem(
                  value: 'notifications',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('New assignment uploaded for CS-401', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text('Fee deadline extended to 15th', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/notifications');
                        },
                        child: const Text('Show All'),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'alerts',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Upcoming exam schedule published', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text('Library book return deadline', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/prof_pic.jpg'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}