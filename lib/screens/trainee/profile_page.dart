// 📄 lib/screens/trainee/profile_page.dart
// ============================================================
// 👤 Trainee Profile Page - Updated & Enhanced
// ✅ Pull-to-refresh for applications + Auto status updates
// ✅ Projects fetched from Backend (ProjectBloc)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/job/job_bloc.dart';
import '../../bloc/job/job_event.dart';
import '../../bloc/job/job_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../models/job_models.dart';
import '../../models/project_models.dart';
import '../auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  bool _isRefreshingProjects = false;

  final Map<String, dynamic> studentStats = {'level': 3};

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProjectBloc>().add(LoadMyProjectsEvent(studentId: authState.user.id));
    }
  }

  Future<void> _onRefreshProjects() async {
    setState(() => _isRefreshingProjects = true);
    _loadProjects();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshingProjects = false);
  }

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        context.read<AuthBloc>().add(const LogoutEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Student';
        String userId = '';
        if (state is AuthAuthenticated) {
          userName = state.user.name;
          userId = state.user.id;
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: _isLoading
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
              : CustomScrollView(
            slivers: [
              // 🎴 SliverAppBar with profile info
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 41,
                              backgroundColor: Colors.deepPurple,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                                style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('Level ${studentStats['level']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),

              // 📋 Main content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 📁 Submitted Projects Section (from ProjectBloc)
                    const Text('Submitted Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _SubmittedProjectsSection(userId: userId, onRefresh: _onRefreshProjects),
                    const SizedBox(height: 24),

                    // 💼 My Applications Section
                    const Text('My Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _MyApplicationsSection(userId: userId),
                    const SizedBox(height: 24),

                    // 🚪 Logout Button
                    _buildLogoutButton(),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚪 Logout Button Widget
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.red.shade700, Colors.red.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 📁 Submitted Projects Section (from ProjectBloc)
// ============================================================

class _SubmittedProjectsSection extends StatefulWidget {
  final String userId;
  final VoidCallback onRefresh;
  const _SubmittedProjectsSection({required this.userId, required this.onRefresh});

  @override
  State<_SubmittedProjectsSection> createState() => _SubmittedProjectsSectionState();
}

class _SubmittedProjectsSectionState extends State<_SubmittedProjectsSection> {
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    context.read<ProjectBloc>().add(LoadMyProjectsEvent(studentId: widget.userId));
  }

  Future<void> _onRefresh() async {
    widget.onRefresh();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is MyProjectsLoaded) {
          final projects = state.projects;

          if (projects.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No projects submitted yet', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Submit a project to see it here', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            );
          }

          // عرض أول 3 مشاريع فقط في الصفحة الرئيسية
          final displayProjects = projects.take(3).toList();

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.deepPurple,
            child: Column(
              children: [
                ...displayProjects.map((project) => _buildProjectCard(project)),
                if (projects.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllProjectsPage(projects: projects),
                          ),
                        );
                      },
                      child: const Text('See All Projects', style: TextStyle(color: Colors.deepPurple)),
                    ),
                  ),
              ],
            ),
          );
        }

        if (state is ProjectLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        if (state is ProjectError) {
          return Center(
            child: Column(
              children: [
                Text('Error: ${state.message}', style: TextStyle(color: Colors.red[400])),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loadProjects,
                  child: const Text('Retry', style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProjectCard(StudentProject project) {
    // تحديد حالة المشروع
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (project.status) {
      case 'graded':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Graded';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة المشروع
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.folder, color: Colors.white, size: 28)),
          ),
          const SizedBox(width: 12),

          // معلومات المشروع
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (project.submissionDate != null)
                  Text(
                    'Submitted: ${_formatDate(project.submissionDate!)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                if (project.grade != null)
                  Text(
                    'Grade: ${project.grade!.toInt()}/100',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
              ],
            ),
          ),

          // شارة الحالة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================
// 💼 My Applications Section
// ============================================================

class _MyApplicationsSection extends StatefulWidget {
  final String userId;
  const _MyApplicationsSection({required this.userId});

  @override
  State<_MyApplicationsSection> createState() => _MyApplicationsSectionState();
}

class _MyApplicationsSectionState extends State<_MyApplicationsSection> {
  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    context.read<JobBloc>().add(LoadUserApplicationsEvent(userId: widget.userId));
  }

  Future<void> _onRefresh() async {
    context.read<JobBloc>().add(RefreshUserApplicationsEvent(userId: widget.userId));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is ApplicationStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application ${state.message.toLowerCase()}'),
              backgroundColor: state.newStatus == ApplicationStatus.approved ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          _loadApplications();
        }
      },
      child: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          final applications = state is UserApplicationsLoaded ? state.applications : [];
          final isLoading = state is JobLoading && applications.isEmpty;

          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
            );
          }

          if (applications.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No applications yet', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Apply for jobs to see them here', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.deepPurple,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: applications.length,
              itemBuilder: (context, index) => _buildApplicationCard(applications[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: application.statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(application.companyLogo, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.jobTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  application.company,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 10, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        application.location,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.attach_money, size: 10, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        application.salary,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied: ${_formatDate(application.appliedDate)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: application.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(application.statusIcon, size: 14, color: application.statusColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    application.statusLabel,
                    style: TextStyle(fontSize: 10, color: application.statusColor, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================
// 📄 All Projects Page
// ============================================================

class AllProjectsPage extends StatelessWidget {
  final List<StudentProject> projects;
  const AllProjectsPage({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Projects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) => _buildProjectCard(projects[index]),
      ),
    );
  }

  Widget _buildProjectCard(StudentProject project) {
    Color statusColor;
    String statusText;

    switch (project.status) {
      case 'graded':
        statusColor = Colors.green;
        statusText = 'Graded';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (project.grade != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradeGradient(project.grade!),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      project.grade!.toInt().toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(project.description),
          const SizedBox(height: 8),
          if (project.submissionDate != null)
            Text('Submitted: ${_formatDate(project.submissionDate!)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          if (project.feedback != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(project.feedback!),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradeGradient(double grade) {
    if (grade >= 90) return [Colors.green, Colors.lightGreen];
    if (grade >= 75) return [Colors.blue, Colors.lightBlue];
    if (grade >= 60) return [Colors.orange, Colors.orangeAccent];
    return [Colors.red, Colors.redAccent];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}