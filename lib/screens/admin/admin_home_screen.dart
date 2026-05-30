// admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_certificates_page.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/job/job_bloc.dart';
import '../../bloc/job/job_event.dart';
import '../../bloc/job/job_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

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
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    // ✅ الحصول على userId من AuthBloc
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    // ✅ تحميل البيانات من JobBloc مع تمرير userId
    if (userId != null) {
      context.read<JobBloc>().add(LoadJobsEvent(userId: userId));
    }

    // ✅ تحميل المشاريع
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoggingOut = true);
      try {
        // ✅ إرسال حدث تسجيل الخروج
        context.read<AuthBloc>().add(const LogoutEvent());

        // ✅ عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully'), backgroundColor: Colors.green),
        );

        // ✅ الانتقال إلى شاشة تسجيل الدخول
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoggingOut = false);
      }
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

    // ✅ إذا كان المستخدم غير مسجل، اخرج من هذه الشاشة
    if (authState is AuthUnauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        // ✅ زر Logout في الـ AppBar فقط
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
      body: _isLoggingOut
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            Text('Logging out...'),
          ],
        ),
      )
          : RefreshIndicator(
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
              _buildManagementList(),
              const SizedBox(height: 30),

              // ✅ أضف هكذا بالضبط
              const SizedBox(height: 30),  // لاحظ: height: 30 وليس 30 فقط
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

  // ✅ دالة بناء قائمة الإدارة (عمودية) - تحت بعض
  Widget _buildManagementList() {
    return Column(
      children: [
        // Job Opportunities
        _buildManagementCard(
          title: 'Job Opportunities',
          icon: Icons.work,
          color: Colors.teal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminJobsScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Students Project
        _buildManagementCard(
          title: 'Students Project',
          icon: Icons.folder_special,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminProjectsScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Courses
        _buildManagementCard(
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
        const SizedBox(height: 12),

        // Certificates
        _buildManagementCard(
          title: 'Certificates',
          icon: Icons.card_membership,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminCertificatesPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Job Applications
        _buildManagementCard(
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

  // ✅ بطاقة الإدارة (عرض كامل)
  Widget _buildManagementCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

}