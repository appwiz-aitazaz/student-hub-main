import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userData;
  bool _isLoading = false;
  
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userData = await UserService.getCurrentUser();
      _userData = userData;
    } catch (e) {
      print('Error fetching user data in provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}