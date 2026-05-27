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

    // تحميل البيانات من JobBloc و ProjectBloc
    context.read<JobBloc>().add(const LoadJobsEvent());
    context.read<ProjectBloc>().add(const LoadFeaturedProjectsEvent());

    // تحميل الكورسات مباشرة من API
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

  // ✅ دالة تسجيل الخروج
  Future<void> _logout() async {
    // عرض مربع حوار للتأكيد
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

    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // محاولة تسجيل الخروج من الخادم
      await ApiService.post(
        endpoint: 'auth/logout/',
        data: {},
        requireAuth: true,
      );
    } catch (e) {
      print('Logout API error (ignored): $e');
    }

    // حذف التوكنات من التخزين المحلي
    await ApiService.logout();

    // إرسال حدث تسجيل الخروج إلى AuthBloc
    if (context.mounted) {
      context.read<AuthBloc>().add(const LogoutEvent());

      // إغلاق مؤشر التحميل
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String adminName = 'Admin';
    if (authState is AuthAuthenticated) {
      adminName = authState.user.name;
    }

    // مراقبة حالة JobBloc
    final jobState = context.watch<JobBloc>().state;
    if (jobState is JobsLoaded) {
      _totalJobs = jobState.totalCount;
    }

    // مراقبة حالة ProjectBloc
    final projectState = context.watch<ProjectBloc>().state;
    if (projectState is FeaturedProjectsLoaded) {
      _totalProjects = projectState.projects.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        // ✅ إضافة زر Logout في الـ AppBar
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(adminName),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              const Text('Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome Back 👑', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Administrator', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 50),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(Icons.menu_book, 'Courses', _totalCourses.toString(), Colors.deepPurple),
        const SizedBox(width: 12),
        _buildStatCard(Icons.work, 'Jobs', _totalJobs.toString(), Colors.teal),
        const SizedBox(width: 12),
        _buildStatCard(Icons.folder_special, 'Projects', _totalProjects.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                title: 'Job\nOpportunities',
                icon: Icons.work,
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminJobsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryCard(
                title: 'Students\nProject',
                icon: Icons.folder_special,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminProjectsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryCard(
                title: 'Courses',
                icon: Icons.library_books,
                color: Colors.deepPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCoursesScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ✅ مربع الطلبات الجديد
        _buildCategoryCard(
          title: 'Job Applications',
          icon: Icons.assignment_turned_in,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminApplicationsScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}