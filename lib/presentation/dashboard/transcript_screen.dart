import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = false;
  bool _isRequestSubmitting = false;
  List<Map<String, dynamic>> _previousRequests = [];
  
  @override
  void initState() {
    super.initState();
    _loadPreviousRequests();
  }
  
  Future<void> _loadPreviousRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would come from an API
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString('transcript_requests');
    
    setState(() {
      if (requestsJson != null) {
        final List<dynamic> decoded = json.decode(requestsJson);
        _previousRequests = decoded.cast<Map<String, dynamic>>();
      } else {
        // Sample data if no saved requests exist
        _previousRequests = [
          {
            'id': 'TR-2023-001',
            'date': '2023-10-15',
            'type': 'Official',
            'purpose': 'Graduate School Application',
            'status': 'Completed',
          },
          {
            'id': 'TR-2023-002',
            'date': '2023-11-05',
            'type': 'Official',
            'purpose': 'Employment Verification',
            'status': 'Processing',
          },
        ];
      }
      _isLoading = false;
    });
  }
  
  Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transcript_requests', json.encode(_previousRequests));
  }
  
  Future<void> _requestOfficialTranscript() async {
    setState(() {
      _isRequestSubmitting = true;
    });
    
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate a new request ID
    final requestId = 'TR-${DateTime.now().year}-${_previousRequests.length + 1}';
    
    // Create new request
    final newRequest = {
      'id': requestId.padLeft(3, '0'),
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'type': 'Official',
      'purpose': 'Student Request',
      'status': 'Pending',
    };
    
    setState(() {
      _previousRequests.add(newRequest);
      _isRequestSubmitting = false;
    });
    
    // Save the updated requests list
    await _saveRequests();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Official transcript request submitted successfully'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  Future<void> _downloadUnofficialTranscript() async {
    // In a real app, this would download a PDF file
    // For demo purposes, we'll just show a snackbar
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text('Downloading transcript...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Simulate download delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Unofficial transcript downloaded successfully'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  Future<void> _deleteRequest(String requestId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Request',
          style: TextStyle(
            color: Colors.red.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this transcript request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Remove the request
    setState(() {
      _previousRequests.removeWhere((request) => request['id'] == requestId);
    });
    
    // Save the updated requests list
    await _saveRequests();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Request deleted successfully'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  Widget _buildTranscriptOptions() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transcript Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Unofficial Transcript Option
            ListTile(
              leading: Icon(
                Icons.download_rounded,
                color: Colors.teal.shade700,
                size: 28,
              ),
              title: const Text(
                'Download Unofficial Transcript',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Get an immediate copy of your transcript for personal use',
                style: TextStyle(fontSize: 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              tileColor: Colors.grey.shade50,
              onTap: _downloadUnofficialTranscript,
            ),
            
            const SizedBox(height: 16),
            
            // Official Transcript Option
            ListTile(
              leading: Icon(
                Icons.verified_rounded,
                color: Colors.teal.shade700,
                size: 28,
              ),
              title: const Text(
                'Request Official Transcript',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Request a sealed, official transcript for formal purposes',
                style: TextStyle(fontSize: 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              tileColor: Colors.grey.shade50,
              onTap: _isRequestSubmitting ? null : _requestOfficialTranscript,
              trailing: _isRequestSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    )
                  : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
            ),
            
            const SizedBox(height: 16),
            
            // Information note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Official transcripts are processed within 3-5 business days and may require additional verification.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequestsTable() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Official Transcript Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_previousRequests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No previous transcript requests',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Reference No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Request Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _previousRequests.map((request) {
                    Color statusColor;
                    IconData statusIcon;
                    
                    switch (request['status']) {
                      case 'Pending':
                        statusColor = Colors.orange;
                        statusIcon = Icons.pending_actions;
                        break;
                      case 'Processing':
                        statusColor = Colors.blue;
                        statusIcon = Icons.hourglass_top;
                        break;
                      case 'Completed':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'Rejected':
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.help_outline;
                    }
                    
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            request['id'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            DateFormat('MMM d, yyyy').format(DateTime.parse(request['date'])),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 16,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  request['status'],
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (request['status'] == 'Completed')
                                IconButton(
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.teal.shade700,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transcript download feature will be available soon'),
                                      ),
                                    );
                                  },
                                  tooltip: 'Download',
                                ),
                              if (request['status'] == 'Pending')
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  onPressed: () => _deleteRequest(request['id']),
                                  tooltip: 'Delete Request',
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
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
      appBar: const CustomAppBar(title: 'Transcript'),
      drawer: const AppDrawer(),
      floatingActionButton: const HomeButton(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPreviousRequests,
              color: Colors.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(screenName: "Transcript"),
                    
                    // Requests table at the top
                    _buildRequestsTable(),
                    
                    // Transcript options
                    _buildTranscriptOptions(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}