class User {
  final String id;
  final String name;
  final String email;
  final bool isProfileComplete;
  // Add other user properties as needed

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isProfileComplete,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isProfileComplete': isProfileComplete,
    };
  }
}


// Update your UserModel class to include these fields:
class UserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? username;
  final String? dob;
  final String? gender;
  final String? cnic;
  final String? rollNo;
  final String? domicile;
  final String? nationality;
  final String? religion;
  final String? program;
  final String? semester;
  final String? department;
  final String? faculty;
  final String? programLevel;
  final String? cgpa;
  final bool isProfileComplete;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.username,
    this.dob,
    this.gender,
    this.cnic,
    this.rollNo,
    this.domicile,
    this.nationality,
    this.religion,
    this.program,
    this.semester,
    this.department,
    this.faculty,
    this.programLevel,
    this.cgpa,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      fullName: json['fullName'] ?? json['name'],
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      dob: json['dob'],
      gender: json['gender'],
      cnic: json['cnic'],
      rollNo: json['rollNo'] ?? json['registrationNumber'],
      domicile: json['domicile'],
      nationality: json['nationality'],
      religion: json['religion'],
      program: json['program'],
      semester: json['semester'] ?? json['currentSemester'],
      department: json['department'],
      faculty: json['faculty'],
      programLevel: json['programLevel'],
      cgpa: json['cgpa']?.toString(),
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'username': username,
      'dob': dob,
      'gender': gender,
      'cnic': cnic,
      'rollNo': rollNo,
      'domicile': domicile,
      'nationality': nationality,
      'religion': religion,
      'program': program,
      'semester': semester,
      'department': department,
      'faculty': faculty,
      'programLevel': programLevel,
      'cgpa': cgpa,
      'isProfileComplete': isProfileComplete,
    };
  }
}