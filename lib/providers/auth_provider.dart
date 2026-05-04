import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.userType == UserType.admin;
  bool get isTrainer => _currentUser?.userType == UserType.trainer;
  bool get isTrainee => _currentUser?.userType == UserType.trainee;

  // دالة لتحميل المستخدم المحفوظ عند بدء التطبيق
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('currentUser');

    if (savedUser != null) {
      final userData = savedUser.split('|');
      _currentUser = UserModel(
        id: userData[0],
        name: userData[1],
        email: userData[2],
        userType: userData[3] == 'admin'
            ? UserType.admin
            : userData[3] == 'trainer'
            ? UserType.trainer
            : UserType.trainee,
      );
      notifyListeners();
    }
  }

  // دالة تسجيل الدخول
  Future<bool> login(String email, String password, UserType selectedType) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: selectedType == UserType.admin
            ? 'Admin User'
            : selectedType == UserType.trainer
            ? 'Trainer Name'
            : 'Trainee Name',
        email: email,
        userType: selectedType,
      );

      final prefs = await SharedPreferences.getInstance();
      final userString = '${_currentUser!.id}|${_currentUser!.name}|${_currentUser!.email}|${_currentUser!.userType.toString().split('.').last}';
      await prefs.setString('currentUser', userString);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ✅ دالة تسجيل مستخدم جديد (أضيفي هذه)
  Future<bool> register(String name, String email, String password, UserType userType) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        userType: userType,
      );

      final prefs = await SharedPreferences.getInstance();
      final userString = '${_currentUser!.id}|${_currentUser!.name}|${_currentUser!.email}|${_currentUser!.userType.toString().split('.').last}';
      await prefs.setString('currentUser', userString);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    notifyListeners();
  }
}