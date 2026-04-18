import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.userType == UserType.admin;
  bool get isTrainer => _currentUser?.userType == UserType.trainer;
  bool get isTrainee => _currentUser?.userType == UserType.trainee;

  Future<bool> login(String email, String password, UserType selectedType) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = UserModel(
        id: '1',
        name: selectedType == UserType.admin
            ? 'Admin User'
            : selectedType == UserType.trainer
            ? 'Trainer Name'
            : 'Trainee Name',
        email: email,
        userType: selectedType,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // أضيفي هذه الدالة داخل class AuthProvider

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
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
