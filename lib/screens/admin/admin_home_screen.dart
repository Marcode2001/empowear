//admin_home_screen

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/job/job_bloc.dart';
import '../../bloc/job/job_event.dart';
import '../../bloc/job/job_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../services/api_service.dart';

import 'admin_jobs_page.dart';
import 'admin_projects_page.dart';
import 'admin_courses_page.dart';
import 'admin_applications_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _totalCourses = 0;
  int _totalJobs = 0;
  int _totalProjects = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;

    String userId = '';

    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    context.read<JobBloc>().add(
      LoadJobsEvent(userId: userId),
    );

    context.read<ProjectBloc>().add(const LoadFeaturedProjectsEvent());

    try {
      final coursesRes = await ApiService.get(
        endpoint: 'course/admin-all-courses/',
        requireAuth: true,
      );

      if (coursesRes['success'] == true && coursesRes['data'] is List) {
        _totalCourses = (coursesRes['data'] as List).length;
      }
    } catch (e) {
      print('Error loading courses count: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    context.read<AuthBloc>().add(const LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String adminName = 'Admin';
    if (authState is AuthAuthenticated) {
      adminName = authState.user.name;
    }

    final jobState = context.watch<JobBloc>().state;
    if (jobState is JobsLoaded) {
      _totalJobs = jobState.totalCount;
    }

    final projectState = context.watch<ProjectBloc>().state;
    if (projectState is FeaturedProjectsLoaded) {
      _totalProjects = projectState.projects.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Dashboard')),
    );
  }
}