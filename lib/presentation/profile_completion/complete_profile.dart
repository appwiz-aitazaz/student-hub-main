import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Keep this one
import 'package:intl/intl.dart';
import 'package:student_hub/routes/app_routes.dart';
import 'package:student_hub/services/user_service.dart';  // Keep this one
import 'package:student_hub/core/app_export.dart';
import 'package:student_hub/theme/custom_text_style.dart';
import 'package:student_hub/services/semester_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  CompleteProfileScreenState createState() => CompleteProfileScreenState();
}

class CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _customDomicileController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _customReligionController = TextEditingController();
  final TextEditingController _customDepartmentController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  
  String? _gender, _program, _semester, _domicile, _religion, _department, _faculty, _programLevel;
  bool _isLoading = false;

  // Add semester-related variables
  List<Map<String, dynamic>> _semestersFromApi = [];
  bool _isLoadingSemesters = true;
  String? _semesterError;

  // Dropdown options
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _programs = ['Computer Science', 'Software Engineering', 'Information Technology', 'Data Science', 'Artificial Intelligence', 'Other'];
  final List<String> _programLevels = ['BS', 'MS', 'PhD', 'Other'];
  // Change from final to non-final
  List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8']; // We'll replace this with API data
  final List<String> _faculties = ['Faculty of Computing & IT', 'Faculty of Engineering', 'Faculty of Sciences', 'Faculty of Arts', 'Faculty of Business', 'Other'];
  final List<String> _domiciles = [
    'Punjab', 'Sindh', 'Khyber Pakhtunkhwa', 'Balochistan',
    'Gilgit-Baltistan', 'Azad Jammu & Kashmir', 'Other'
  ];
  final List<String> _religions = [
    'Islam', 'Christianity', 'Hinduism', 'Sikhism', 'Other'
  ];
  final List<String> _departments = [
    'Computer Science', 'Electrical Engineering', 'Mechanical Engineering',
    'Business Administration', 'Mathematics', 'Physics', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    
    // Add this line to fetch semesters when screen loads
    fetchSemesters();
    
    // For testing only - remove in production
    _checkAndSetUserId();
  }
  
  // Add method to fetch semesters
  Future<void> fetchSemesters() async {
    try {
      setState(() {
        _isLoadingSemesters = true;
        _semesterError = null;
      });
      
      print('Attempting to fetch semesters...');
      final semestersList = await SemesterService.getAllSemesters();
      print('API response received: $semestersList');
      
      setState(() {
        _semestersFromApi = semestersList;
        _isLoadingSemesters = false;
        
        // Update the semesters dropdown list with values from API
        if (_semestersFromApi.isNotEmpty) {
          _semesters = _semestersFromApi.map((semester) => 
            semester['semester'] as String? ?? 'Unknown').toList();
        }
      });
      
      print('Fetched ${_semestersFromApi.length} semesters');
      // Print each semester for debugging
      _semestersFromApi.forEach((semester) {
        print('Semester: ${semester['semester']}, ID: ${semester['_id']}');
      });
    } catch (e) {
      print('Error fetching semesters: $e');
      setState(() {
        _isLoadingSemesters = false;
        _semesterError = e.toString();
      });
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dobController.text = prefs.getString('dob') ?? '';
      _gender = _genders.contains(prefs.getString('gender')) ? prefs.getString('gender') : null;
      _cnicController.text = prefs.getString('cnic') ?? '';
      _rollNoController.text = prefs.getString('rollNo') ?? '';
      _cgpaController.text = prefs.getString('cgpa') ?? '';
      
      String? savedDomicile = prefs.getString('domicile');
      _domicile = _domiciles.contains(savedDomicile) ? savedDomicile : null;
      _customDomicileController.text = prefs.getString('customDomicile') ?? '';
      
      _nationalityController.text = prefs.getString('nationality') ?? '';
      
      String? savedReligion = prefs.getString('religion');
      _religion = _religions.contains(savedReligion) ? savedReligion : null;
      _customReligionController.text = prefs.getString('customReligion') ?? '';
      
      String? savedProgram = prefs.getString('program');
      _program = _programs.contains(savedProgram) ? savedProgram : null;
      
      String? savedProgramLevel = prefs.getString('programLevel');
      _programLevel = _programLevels.contains(savedProgramLevel) ? savedProgramLevel : null;
      
      String? savedFaculty = prefs.getString('faculty');
      _faculty = _faculties.contains(savedFaculty) ? savedFaculty : null;
      
      String? savedSemester = prefs.getString('semester');
      _semester = _semesters.contains(savedSemester) ? savedSemester : null;
      
      String? savedDepartment = prefs.getString('department');
      _department = _departments.contains(savedDepartment) ? savedDepartment : null;
      _customDepartmentController.text = prefs.getString('customDepartment') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Get the semester ID from the selected semester name
        String? selectedSemesterId;
        if (_semester != null) {
          final selectedSemesterObj = _semestersFromApi.firstWhere(
            (s) => s['semester'] == _semester,
            orElse: () => <String, dynamic>{},
          );
          selectedSemesterId = selectedSemesterObj['_id'];
        }
        
        // Create profile data map in the exact format required by the backend
        final Map<String, dynamic> profileData = {
          'dob': _dobController.text,
          'domicile': _domicile == 'Other' ? _customDomicileController.text : _domicile,
          'semester': selectedSemesterId, // This is already the ID format
          'program': _program,
          'religion': _religion == 'Other' ? _customReligionController.text : _religion,
          'nationality': _nationalityController.text,
          'gender': _gender,
          'cnic': _cnicController.text,
          'rollNo': _rollNoController.text,
          'faculty': _faculty,
          'programLevel': _programLevel,
          'cgpa': double.tryParse(_cgpaController.text) ?? 0.0
        };
        
        // Log the data being sent for debugging
        print('Sending profile data to backend: $profileData');
        
        // Get user ID from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        
        if (userId == null) {
          throw Exception('User ID not found. Please login again.');
        }
        
        // Send data to backend using the update endpoint
        final response = await UserService.updateProfile(userId, profileData);
        print('Profile update response: $response'); // Debug print
        
        // Check if the response contains a success message
        if (response['success'] == true || 
            (response['message'] != null && 
             response['message'].toString().contains('successfully'))) {
          
          // Save profile completion status locally
          await prefs.setBool('isProfileComplete', true);
          
          // Save all profile data locally
          await _saveProfileDataLocally(profileData);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          // Show detailed error message
          final errorMessage = response['message'] ?? 'Failed to update profile';
          final errorDetails = response['error'] != null ? '\nDetails: ${response['error']}' : '';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage$errorDetails'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          
          // Log the full error for debugging
          print('Profile update error: $response');
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        print('Exception during profile update: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfileDataLocally(Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save each field to SharedPreferences
    for (var entry in profileData.entries) {
      if (entry.value != null) {
        if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value);
        } else {
          await prefs.setString(entry.key, entry.value.toString());
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
        backgroundColor: theme.primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Default Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                            color: Colors.grey[200],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Default Profile Picture",
                          style: CustomTextStyles.bodyMediumTeal400,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  _buildCard([
                    _buildTextField(
                      controller: _rollNoController,
                      labelText: 'Roll Number',
                      prefixIcon: Icons.numbers,
                      validator: (value) => value!.isEmpty ? 'Roll number is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _dobController,
                      labelText: 'Date of Birth',
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _gender,
                      labelText: 'Gender',
                      prefixIcon: Icons.person,
                      items: _genders,
                      onChanged: (value) => setState(() => _gender = value),
                      validator: (value) => value == null ? 'Gender is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cnicController,
                      labelText: 'CNIC (without dashes)',
                      prefixIcon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'CNIC is required';
                        if (value.length != 13) return 'CNIC must be 13 digits';
                        return null;
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Location Information Section
                  _buildSectionHeader('Location Information'),
                  _buildCard([
                    _buildDropdown(
                      value: _domicile,
                      labelText: 'Domicile',
                      prefixIcon: Icons.location_city,
                      items: _domiciles,
                      onChanged: (value) => setState(() => _domicile = value),
                      validator: (value) => value == null ? 'Domicile is required' : null,
                    ),
                    if (_domicile == 'Other') ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _customDomicileController,
                        labelText: 'Specify Domicile',
                        prefixIcon: Icons.edit,
                        validator: (value) => value!.isEmpty ? 'Please specify your domicile' : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nationalityController,
                      labelText: 'Nationality',
                      prefixIcon: Icons.flag,
                      validator: (value) => value!.isEmpty ? 'Nationality is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _religion,
                      labelText: 'Religion',
                      prefixIcon: Icons.account_balance,
                      items: _religions,
                      onChanged: (value) => setState(() => _religion = value),
                      validator: (value) => value == null ? 'Religion is required' : null,
                    ),
                    if (_religion == 'Other') ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _customReligionController,
                        labelText: 'Specify Religion',
                        prefixIcon: Icons.edit,
                        validator: (value) => value!.isEmpty ? 'Please specify your religion' : null,
                      ),
                    ],
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Academic Information Section
                  _buildSectionHeader('Academic Information'),
                  _buildCard([
                    _buildDropdown(
                      value: _faculty,
                      labelText: 'Faculty',
                      prefixIcon: Icons.business,
                      items: _faculties,
                      onChanged: (value) => setState(() => _faculty = value),
                      validator: (value) => value == null ? 'Faculty is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _programLevel,
                      labelText: 'Program Level',
                      prefixIcon: Icons.school,
                      items: _programLevels,
                      onChanged: (value) => setState(() => _programLevel = value),
                      validator: (value) => value == null ? 'Program level is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _program,
                      labelText: 'Program',
                      prefixIcon: Icons.book,
                      items: _programs,
                      onChanged: (value) => setState(() => _program = value),
                      validator: (value) => value == null ? 'Program is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _semester,
                      labelText: 'Semester',
                      prefixIcon: Icons.date_range,
                      items: _semesters,
                      onChanged: (value) => setState(() => _semester = value),
                      validator: (value) => value == null ? 'Semester is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _department,
                      labelText: 'Department',
                      prefixIcon: Icons.account_balance,
                      items: _departments,
                      onChanged: (value) => setState(() => _department = value),
                      validator: (value) => value == null ? 'Department is required' : null,
                    ),
                    if (_department == 'Other') ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _customDepartmentController,
                        labelText: 'Specify Department',
                        prefixIcon: Icons.edit,
                        validator: (value) => value!.isEmpty ? 'Please specify your department' : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cgpaController,
                      labelText: 'CGPA',
                      prefixIcon: Icons.grade,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value!.isEmpty) return 'CGPA is required';
                        final cgpa = double.tryParse(value);
                        if (cgpa == null) return 'Enter a valid number';
                        if (cgpa < 0 || cgpa > 4.0) return 'CGPA must be between 0 and 4.0';
                        return null;
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 30),
                  
                  // Submit Button
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.teal)
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Submit Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 16),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
    );
  }

  // Replace the existing _buildDropdown method or modify it to handle semester data
  Widget _buildDropdown({
    required String? value,
    required String labelText,
    required IconData prefixIcon,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    // If this is the semester dropdown and we're still loading
    if (labelText == 'Semester' && _isLoadingSemesters) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 8),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    
    // If this is the semester dropdown and there was an error
    if (labelText == 'Semester' && _semesterError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text('Error loading semesters: $_semesterError', 
               style: TextStyle(color: Colors.red)),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    _cnicController.dispose();
    _customDomicileController.dispose();
    _nationalityController.dispose();
    _customReligionController.dispose();
    _customDepartmentController.dispose();
    _rollNoController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }
}

// For debugging purposes only
Future<void> _checkAndSetUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');
  print('Current user_id in SharedPreferences: $userId');
  
  if (userId == null) {
    // For testing only - set a dummy user ID
    // await prefs.setString('user_id', 'your-test-user-id');
    print('Warning: No user_id found in SharedPreferences');
  }
}