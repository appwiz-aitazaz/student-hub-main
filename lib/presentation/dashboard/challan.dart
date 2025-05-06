import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/home_button.dart';

class ChallanManagementScreen extends StatefulWidget {
  @override
  _ChallanManagementScreenState createState() => _ChallanManagementScreenState();
}

class _ChallanManagementScreenState extends State<ChallanManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentChallan;
  List<Map<String, dynamic>> _challanHistory = [];
  bool _installmentRequested = false;
  bool _installmentApproved = false;
  
  @override
  void initState() {
    super.initState();
    _loadChallanData();
  }

  Future<void> _loadChallanData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would come from an API
    final prefs = await SharedPreferences.getInstance();
    final challanJson = prefs.getString('current_challan');
    final historyJson = prefs.getString('challan_history');
    
    setState(() {
      if (challanJson != null) {
        _currentChallan = json.decode(challanJson);
        _installmentRequested = _currentChallan!['installmentRequested'] ?? false;
        _installmentApproved = _currentChallan!['installmentApproved'] ?? false;
      } else {
        // Sample data if no saved challan exists
        _currentChallan = {
          'id': 'CH-2023-F-1001',
          'semester': 'Fall 2023',
          'issueDate': '2023-09-01',
          'dueDate': '2023-09-15',
          'totalAmount': 75000.0,
          'paidAmount': 0.0,
          'status': 'Unpaid',
          'installmentRequested': false,
          'installmentApproved': false,
          'items': [
            {'name': 'Tuition Fee', 'amount': 60000.0},
            {'name': 'Registration Fee', 'amount': 5000.0},
            {'name': 'Library Fee', 'amount': 3000.0},
            {'name': 'Lab Fee', 'amount': 5000.0},
            {'name': 'Sports Fee', 'amount': 2000.0},
          ]
        };
      }
      
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        _challanHistory = decoded.cast<Map<String, dynamic>>();
      } else {
        // Sample history data
        _challanHistory = [
          {
            'id': 'CH-2023-S-1001',
            'semester': 'Spring 2023',
            'issueDate': '2023-02-01',
            'dueDate': '2023-02-15',
            'totalAmount': 72000.0,
            'paidAmount': 72000.0,
            'status': 'Paid',
            'paymentDate': '2023-02-10',
          },
          {
            'id': 'CH-2022-F-1001',
            'semester': 'Fall 2022',
            'issueDate': '2022-09-01',
            'dueDate': '2022-09-15',
            'totalAmount': 70000.0,
            'paidAmount': 70000.0,
            'status': 'Paid',
            'paymentDate': '2022-09-12',
          },
        ];
      }
      
      _isLoading = false;
    });
  }

  Future<void> _saveChallanData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_challan', json.encode(_currentChallan));
    await prefs.setString('challan_history', json.encode(_challanHistory));
  }

  Future<void> _requestInstallment() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Request Installment',
          style: TextStyle(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are about to request to pay your challan in two installments. The first installment will be 50% of the total amount.',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'First Installment: Rs. ${(_currentChallan!['totalAmount'] / 2).toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            Text(
              'Due Date: ${_currentChallan!['dueDate']}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Second Installment: Rs. ${(_currentChallan!['totalAmount'] / 2).toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            Text(
              'Due Date: ${_calculateSecondInstallmentDate()}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentChallan!['installmentRequested'] = true;
                _installmentRequested = true;
              });
              _saveChallanData();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      const Text('Installment request submitted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.teal.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  String _calculateSecondInstallmentDate() {
    final dueDate = DateFormat('yyyy-MM-dd').parse(_currentChallan!['dueDate']);
    final secondDueDate = dueDate.add(const Duration(days: 90)); // 3 months later
    return DateFormat('yyyy-MM-dd').format(secondDueDate);
  }

  Widget _buildChallanCard() {
    if (_currentChallan == null) {
      return Center(
        child: Text(
          'No active challan found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final challan = _currentChallan!;
    final isPaid = challan['status'] == 'Paid';
    final isPartiallyPaid = challan['status'] == 'Partially Paid';
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challan ID: ${challan['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semester: ${challan['semester']}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.shade600
                        : isPartiallyPaid
                            ? Colors.orange.shade600
                            : Colors.red.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    challan['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Issue Date:',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      challan['issueDate'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Due Date:',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      challan['dueDate'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isOverdue(challan['dueDate']) && !isPaid
                            ? Colors.red.shade700
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'Fee Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  challan['items'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          challan['items'][index]['name'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Rs. ${challan['items'][index]['amount'].toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Rs. ${challan['totalAmount'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (isPartiallyPaid) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paid Amount:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'Rs. ${challan['paidAmount'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'Rs. ${(challan['totalAmount'] - challan['paidAmount']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (!isPaid) ...[
                  if (_installmentApproved) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Installment Plan Approved',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'First Installment: Rs. ${(challan['totalAmount'] / 2).toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'Due Date: ${challan['dueDate']}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Second Installment: Rs. ${(challan['totalAmount'] / 2).toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'Due Date: ${_calculateSecondInstallmentDate()}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_installmentRequested) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pending, color: Colors.amber.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Installment Request Pending',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your request to pay in installments is being reviewed. You will be notified once it is approved.',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _requestInstallment,
                      icon: const Icon(Icons.payments),
                      label: const Text('Request Installment Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // In a real app, this would navigate to a payment gateway
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Redirecting to payment gateway...'),
                          backgroundColor: Colors.teal.shade700,
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: Text(
                      _installmentApproved
                          ? 'Pay First Installment'
                          : 'Pay Full Amount',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paid on ${challan['paymentDate']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Text(
                              'Thank you for your payment',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallanHistory() {
    if (_challanHistory.isEmpty) {
      return Center(
        child: Text(
          'No challan history found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _challanHistory.length,
      itemBuilder: (context, index) {
        final challan = _challanHistory[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  challan['semester'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    challan['status'],
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Challan ID:',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(challan['id']),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount:',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text('Rs. ${challan['totalAmount'].toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid on:',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(challan['paymentDate']),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // View details functionality
              },
            ),
          ),
        );
      },
    );
  }

  bool _isOverdue(String dueDate) {
    final due = DateFormat('yyyy-MM-dd').parse(dueDate);
    final today = DateTime.now();
    return today.isAfter(due);
  }

  // For demo purposes - simulate approval of installment request
  void _simulateInstallmentApproval() {
    if (_installmentRequested && !_installmentApproved) {
      setState(() {
        _currentChallan!['installmentApproved'] = true;
        _installmentApproved = true;
      });
      _saveChallanData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Your installment request has been approved!'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Challan Management'),
      drawer: AppDrawer(),
      floatingActionButton: const HomeButton(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadChallanData,
              color: Colors.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(screenName: "Challan Management"),
                    _buildChallanCard(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Challan History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          // For demo purposes only - button to simulate approval
                          if (_installmentRequested && !_installmentApproved)
                            TextButton.icon(
                              onPressed: _simulateInstallmentApproval,
                              icon: Icon(Icons.admin_panel_settings, color: Colors.teal.shade700, size: 16),
                              label: Text(
                                'Demo: Approve Request',
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildChallanHistory(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}