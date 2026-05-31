// 📄 lib/bloc/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (result['success']) {
        final user = result['user'] as User;
        await _saveUserData(user, result['token'] as String);
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: result['message'] ?? 'فشل تسجيل الدخول'));
      }

    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        userType: event.userType,
        phone: event.phone,
        location: event.location,
        birthDate: event.birthDate,
      );

      if (result['success']) {
        final user = result['user'] as User;
        await _saveUserData(user, result['token'] as String);
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: result['message'] ?? 'فشل التسجيل'));
      }

    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    // ✅ Removed AuthLoading emit to avoid screen flash
    try {
      await _authRepository.logout();
      await _clearUserData();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }

    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<AuthState> emit,
      ) async {

    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;

      final updatedUser = User(
        id: currentUser.id,
        name: event.name ?? currentUser.name,
        email: currentUser.email,
        userType: currentUser.userType,
        phone: event.phone ?? currentUser.phone,
        bio: event.bio ?? currentUser.bio,
        profileImage: event.profileImage ?? currentUser.profileImage,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));

      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  Future<void> _saveUserData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');
  }
}