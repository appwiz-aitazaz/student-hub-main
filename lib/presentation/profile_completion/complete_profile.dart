import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  CompleteProfileScreenState createState() => CompleteProfileScreenState();
}

class CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  String? _gender, _program, _semester, _domicile, _religion, _department;
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _customDomicileController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _customReligionController = TextEditingController();
  final TextEditingController _customDepartmentController = TextEditingController();
  bool _isLoading = false;
  File? _profileImage; // Store the selected image file

  // Dropdown options
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _programs = ['BSc', 'MSc', 'PhD', 'Other'];
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
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
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dobController.text = prefs.getString('dob') ?? '';
      _gender = _genders.contains(prefs.getString('gender')) ? prefs.getString('gender') : null;
      _cnicController.text = prefs.getString('cnic') ?? '';
      String? savedDomicile = prefs.getString('domicile');
      _domicile = _domiciles.contains(savedDomicile) ? savedDomicile : null;
      _customDomicileController.text = prefs.getString('customDomicile') ?? '';
      _nationalityController.text = prefs.getString('nationality') ?? '';
      String? savedReligion = prefs.getString('religion');
      _religion = _religions.contains(savedReligion) ? savedReligion : null;
      _customReligionController.text = prefs.getString('customReligion') ?? '';
      String? savedProgram = prefs.getString('program');
      _program = _programs.contains(savedProgram) ? savedProgram : null;
      String? savedSemester = prefs.getString('semester');
      _semester = _semesters.contains(savedSemester) ? savedSemester : null;
      String? savedDepartment = prefs.getString('department');
      _department = _departments.contains(savedDepartment) ? savedDepartment : null;
      _customDepartmentController.text = prefs.getString('customDepartment') ?? '';
      // Load profile image path
      String? imagePath = prefs.getString('profileImage');
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dob', _dobController.text);
      await prefs.setString('gender', _gender ?? '');
      await prefs.setString('cnic', _cnicController.text);
      await prefs.setString('domicile', _domicile ?? '');
      await prefs.setString('customDomicile', _customDomicileController.text);
      await prefs.setString('nationality', _nationalityController.text);
      await prefs.setString('religion', _religion ?? '');
      await prefs.setString('customReligion', _customReligionController.text);
      await prefs.setString('program', _program ?? '');
      await prefs.setString('semester', _semester ?? '');
      await prefs.setString('department', _department ?? '');
      await prefs.setString('customDepartment', _customDepartmentController.text);
      // Save profile image path
      if (_profileImage != null) {
        await prefs.setString('profileImage', _profileImage!.path);
      } else {
        await prefs.remove('profileImage');
      }
       if (_profileImage != null)
       TextButton(
       onPressed: () => setState(() => _profileImage = null),
       child: const Text('Remove Image'),
       );
      if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a profile picture')),
      );
     
  setState(() => _isLoading = false);
  return;
}
      await prefs.setBool('isProfileComplete', true);

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  // Function to pick an image
Future<void> _pickImage() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      if (path.endsWith('.pdf')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF selected, but not displayed as profile picture')),
        );
        // Store PDF path if needed, but don't set _profileImage
      } else if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg')) {
        setState(() {
          _profileImage = File(path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a PNG, JPEG, or PDF file')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error picking file: $e')),
    );
  }
}

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                                    _profileImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'Personal Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onTap: () => _selectDate(context),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _genders
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _gender = value),
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cnicController,
                        decoration: InputDecoration(
                          labelText: 'CNIC',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Required';
                          if (value.length != 13) return 'Invalid CNIC';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _domicile,
                        decoration: InputDecoration(
                          labelText: 'Domicile',
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _domiciles
                            .map((domicile) => DropdownMenuItem(
                                  value: domicile,
                                  child: Text(domicile),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _domicile = value),
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                      if (_domicile == 'Other') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customDomicileController,
                          decoration: InputDecoration(
                            labelText: 'Specify Domicile',
                            prefixIcon: const Icon(Icons.edit),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nationalityController,
                        decoration: InputDecoration(
                          labelText: 'Nationality',
                          prefixIcon: const Icon(Icons.flag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _religion,
                        decoration: InputDecoration(
                          labelText: 'Religion',
                          prefixIcon: const Icon(Icons.account_balance),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _religions
                            .map((religion) => DropdownMenuItem(
                                  value: religion,
                                  child: Text(religion),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _religion = value),
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                      if (_religion == 'Other') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customReligionController,
                          decoration: InputDecoration(
                            labelText: 'Specify Religion',
                            prefixIcon: const Icon(Icons.edit),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Academic Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _program,
                        decoration: InputDecoration(
                          labelText: 'Program',
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _programs
                            .map((program) => DropdownMenuItem(
                                  value: program,
                                  child: Text(program),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _program = value),
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _semester,
                        decoration: InputDecoration(
                          labelText: 'Semester',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _semesters
                            .map((semester) => DropdownMenuItem(
                                  value: semester,
                                  child: Text(semester),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _semester = value),
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _department,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          prefixIcon: const Icon(Icons.account_balance),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _departments
                            .map((department) => DropdownMenuItem(
                                  value: department,
                                  child: Text(department),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _department = value),
                        validator: (value) =>
                            value == null ? 'Required' : null,
                      ),
                      if (_department == 'Other') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customDepartmentController,
                          decoration: InputDecoration(
                            labelText: 'Specify Department',
                            prefixIcon: const Icon(Icons.edit),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: theme.primaryColor,
                          elevation: 5,
                        ),
                        child: const Text(
                          'Submit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build placeholder for profile picture
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      ),
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
    super.dispose();
  }
}