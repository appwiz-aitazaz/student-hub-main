import 'package:flutter/material.dart';
import 'package:student_hub/widgets/screen_header.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/home_button.dart';
import '../../widgets/app_drawer.dart';
import 'package:intl/intl.dart';

class AllNotificationsScreen extends StatefulWidget {
  const AllNotificationsScreen({Key? key}) : super(key: key);

  @override
  _AllNotificationsScreenState createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadNotifications() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample notification data
    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'Fee Payment Reminder',
          'message': 'Your fee payment for Fall 2023 is due on November 30, 2023. Please ensure timely payment to avoid late fees.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': false,
          'category': 'Finance',
          'priority': 'High',
        },
        {
          'id': '2',
          'title': 'Course Registration Open',
          'message': 'Registration for Spring 2024 courses is now open. Please log in to the student portal to register for your courses.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': true,
          'category': 'Academic',
          'priority': 'Medium',
        },
        {
          'id': '3',
          'title': 'Library Book Due',
          'message': 'The book "Data Structures and Algorithms" is due for return on November 25, 2023. Please return it to avoid any penalties.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isRead': false,
          'category': 'Library',
          'priority': 'Medium',
        },
        {
          'id': '4',
          'title': 'Exam Schedule Published',
          'message': 'The final examination schedule for Fall 2023 has been published. Please check your student portal for details.',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'isRead': true,
          'category': 'Academic',
          'priority': 'High',
        },
        {
          'id': '5',
          'title': 'Campus Closure Notice',
          'message': 'The university will be closed on November 9, 2023 due to scheduled maintenance of electrical systems.',
          'timestamp': DateTime.now().subtract(const Duration(days: 4)),
          'isRead': true,
          'category': 'Administrative',
          'priority': 'Low',
        },
        {
          'id': '6',
          'title': 'Scholarship Application Deadline',
          'message': 'The deadline for applying to the Merit Scholarship Program is December 15, 2023. Submit your application through the student portal.',
          'timestamp': DateTime.now().subtract(const Duration(days: 5)),
          'isRead': false,
          'category': 'Finance',
          'priority': 'High',
        },
        {
          'id': '7',
          'title': 'Career Fair Announcement',
          'message': 'Annual Career Fair will be held on December 5, 2023 at the Main Campus. Prepare your resumes and dress professionally.',
          'timestamp': DateTime.now().subtract(const Duration(days: 6)),
          'isRead': true,
          'category': 'Career',
          'priority': 'Medium',
        },
      ];
      _isLoading = false;
    });
  }
  
  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }
  
  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // In a real app, this would restore the deleted notification
            _loadNotifications();
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  List<Map<String, dynamic>> _getFilteredNotifications(String filter) {
    if (filter == 'All') {
      return _notifications;
    } else if (filter == 'Unread') {
      return _notifications.where((n) => n['isRead'] == false).toList();
    } else {
      // Important - high priority
      return _notifications.where((n) => n['priority'] == 'High').toList();
    }
  }
  
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade700;
      case 'Medium':
        return Colors.orange.shade700;
      case 'Low':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Finance':
        return Icons.account_balance_wallet;
      case 'Academic':
        return Icons.school;
      case 'Library':
        return Icons.book;
      case 'Administrative':
        return Icons.business;
      case 'Career':
        return Icons.work;
      default:
        return Icons.notifications;
    }
  }
  
  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['timestamp'] as DateTime;
    final formattedDate = DateFormat.yMMMd().format(timestamp);
    final formattedTime = DateFormat.jm().format(timestamp);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? Colors.transparent : Colors.teal.shade300,
          width: isRead ? 0 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          
          // Show notification details in a dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                notification['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(notification['priority']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(notification['category']),
                            size: 16,
                            color: _getPriorityColor(notification['priority']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification['category'],
                            style: TextStyle(
                              color: _getPriorityColor(notification['priority']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$formattedDate at $formattedTime',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(notification['category']),
                      color: Colors.teal.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 16,
                                  color: isRead ? Colors.grey.shade800 : Colors.teal.shade800,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(notification['priority']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${notification['priority']} Priority',
                          style: TextStyle(
                            color: _getPriorityColor(notification['priority']),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _deleteNotification(notification['id']),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat.yMMMd().format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifications'),
      drawer: const AppDrawer(),
      floatingActionButton: const HomeButton(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            )
          : Column(
              children: [
                const ScreenHeader(screenName: "Notifications"),
                
                // Tab bar for filtering
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.teal.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.teal.shade700,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Unread'),
                      Tab(text: 'Important'),
                    ],
                  ),
                ),
                
                // Notification counter
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'You have ${_notifications.where((n) => !n['isRead']).length} unread notifications',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            for (var notification in _notifications) {
                              notification['isRead'] = true;
                            }
                          });
                        },
                        icon: Icon(Icons.done_all, size: 16, color: Colors.teal.shade700),
                        label: Text(
                          'Mark all as read',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Notification list with tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All notifications
                      _notifications.isEmpty
                          ? _buildEmptyState('No notifications to display')
                          : RefreshIndicator(
                              onRefresh: _loadNotifications,
                              color: Colors.teal,
                              child: ListView(
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                children: _notifications
                                    .map((notification) => _buildNotificationCard(notification))
                                    .toList(),
                              ),
                            ),
                      
                      // Unread notifications
                      _getFilteredNotifications('Unread').isEmpty
                          ? _buildEmptyState('No unread notifications')
                          : RefreshIndicator(
                              onRefresh: _loadNotifications,
                              color: Colors.teal,
                              child: ListView(
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                children: _getFilteredNotifications('Unread')
                                    .map((notification) => _buildNotificationCard(notification))
                                    .toList(),
                              ),
                            ),
                      
                      // Important notifications
                      _getFilteredNotifications('Important').isEmpty
                          ? _buildEmptyState('No important notifications')
                          : RefreshIndicator(
                              onRefresh: _loadNotifications,
                              color: Colors.teal,
                              child: ListView(
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                children: _getFilteredNotifications('Important')
                                    .map((notification) => _buildNotificationCard(notification))
                                    .toList(),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}