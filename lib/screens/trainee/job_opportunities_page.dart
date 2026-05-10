// 📄 lib/screens/trainee/job_opportunities_page.dart
// ✅ Safe version with null checks + error handling

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/job/job_bloc.dart';
import '../../bloc/job/job_event.dart';
import '../../bloc/job/job_state.dart';
import '../../models/job_models.dart';

class JobOpportunitiesPage extends StatefulWidget {
  const JobOpportunitiesPage({super.key});
  @override
  State<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isFirstLoad = true;
  bool _isLoadingPrefs = true; // ✅ لمنع العرض قبل تحميل التفضيلات

  List<JobModel> _cachedJobs = [];
  Set<String> _appliedJobIds = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // ✅ تهيئة آمنة مع معالجة الأخطاء
  Future<void> _initialize() async {
    try {
      await _loadAppliedJobs();
    } catch (e) {
      print('⚠️ Error loading prefs: $e');
      _appliedJobIds = {}; // fallback
    } finally {
      if (mounted) setState(() => _isLoadingPrefs = false);
    }
    _loadJobs();
  }

  Future<void> _loadAppliedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final applied = prefs.getStringList('applied_jobs') ?? [];
      if (mounted) {
        setState(() => _appliedJobIds = applied.toSet());
      }
    } catch (e) {
      print('⚠️ Failed to load applied jobs: $e');
      if (mounted) setState(() => _appliedJobIds = {});
    }
  }

  Future<void> _saveAppliedJob(String jobId, bool isApplied) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (isApplied) {
        _appliedJobIds.add(jobId);
      } else {
        _appliedJobIds.remove(jobId);
      }
      await prefs.setStringList('applied_jobs', _appliedJobIds.toList());
    } catch (e) {
      print('⚠️ Failed to save applied job: $e');
    }
  }

  void _loadJobs() {
    context.read<JobBloc>().add(LoadJobsEvent());
  }

  void _searchJobs() {
    context.read<JobBloc>().add(SearchJobsEvent(query: _searchQuery, category: null));
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    context.read<JobBloc>().add(SearchJobsEvent(query: '', category: null));
  }

  void _showJobDetails(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailSheet(
        job: job,
        isPersistedApplied: _appliedJobIds.contains(job.id),
        onJobStatusChanged: _updateJobStatus,
      ),
    );
  }

  void _updateJobStatus(String jobId, bool isApplied) {
    setState(() {
      final index = _cachedJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _cachedJobs[index] = _cachedJobs[index].copyWith(isApplied: isApplied);
      }
      if (isApplied) {
        _appliedJobIds.add(jobId);
      } else {
        _appliedJobIds.remove(jobId);
      }
    });
    _saveAppliedJob(jobId, isApplied);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ عرض شاشة تحميل أثناء تهيئة التفضيلات
    if (_isLoadingPrefs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Jobs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]))),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobApplied) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted!'), backgroundColor: Colors.green));
          } else if (state is JobWithdrawn) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application withdrawn!'), backgroundColor: Colors.orange));
          } else if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is JobsLoaded) {
            _isFirstLoad = false;
            _cachedJobs = state.jobs.map((job) {
              if (_appliedJobIds.contains(job.id)) {
                return job.copyWith(isApplied: true);
              }
              return job;
            }).toList();
          }

          if (state is JobLoading && _isFirstLoad) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (_cachedJobs.isNotEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _searchJobs();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search jobs...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch) : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cachedJobs.length,
                    itemBuilder: (context, index) => _buildJobCard(_cachedJobs[index]),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No jobs available'));
        },
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(job.companyLogo, style: const TextStyle(fontSize: 28)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(job.company, style: TextStyle(color: Colors.grey[600]))])),
                  if (_appliedJobIds.contains(job.id) || job.isApplied)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Text('Applied', style: TextStyle(color: Colors.green, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(child: Text(job.location, style: TextStyle(color: Colors.grey[600]))),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(job.salary, style: TextStyle(color: Colors.grey[600])),
              ]),
              const SizedBox(height: 8),
              Text(job.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 💼 Job Detail Bottom Sheet - Safe Version
// ============================================================

class JobDetailSheet extends StatefulWidget {
  final JobModel job;
  final bool isPersistedApplied;
  final Function(String, bool) onJobStatusChanged;

  const JobDetailSheet({super.key, required this.job, required this.isPersistedApplied, required this.onJobStatusChanged});

  @override
  State<JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends State<JobDetailSheet> {
  bool _isProcessing = false;
  late bool _localIsApplied;

  @override
  void initState() {
    super.initState();
    _localIsApplied = widget.isPersistedApplied || widget.job.isApplied;
  }

  void _applyForJob() {
    if (_isProcessing) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() => _isProcessing = true);
      setState(() => _localIsApplied = true);
      widget.onJobStatusChanged(widget.job.id, true);
      context.read<JobBloc>().add(ApplyForJobEvent(
        jobId: widget.job.id,
        userId: authState.user.id,
        userName: authState.user.name,
        userEmail: authState.user.email,
      ));
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      });
    }
  }

  void _withdrawApplication() {
    if (_isProcessing) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() => _isProcessing = true);
      setState(() => _localIsApplied = false);
      widget.onJobStatusChanged(widget.job.id, false);
      context.read<JobBloc>().add(WithdrawApplicationEvent(jobId: widget.job.id, userId: authState.user.id));
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application withdrawn!'), backgroundColor: Colors.orange));
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 50, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(widget.job.companyLogo, style: const TextStyle(fontSize: 40))))),
                    const SizedBox(height: 16),
                    Center(child: Text(widget.job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 4),
                    Center(child: Text(widget.job.company, style: TextStyle(color: Colors.grey[600]))),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.location_on, 'Location', widget.job.location),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.attach_money, 'Salary', widget.job.salary),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.work, 'Job Type', widget.job.type),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.timeline, 'Experience', widget.job.experience),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.calendar_today, 'Deadline', _formatDate(widget.job.deadline)),
                    const Divider(height: 32),
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.job.description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 20),
                    const Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...widget.job.requirements.map((req) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.check_circle, size: 16, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(req, style: const TextStyle(fontSize: 14)))]))),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : (_localIsApplied ? _withdrawApplication : _applyForJob),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _localIsApplied ? Colors.orange : Colors.deepPurple,
                          foregroundColor: Colors.white, // ✅ White text
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_localIsApplied ? 'Withdraw Application' : 'Apply Now', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, size: 18, color: Colors.deepPurple), const SizedBox(width: 12), SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))), Expanded(child: Text(value, style: const TextStyle(fontSize: 14)))]);
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}