import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/job/job_bloc.dart';
import '../../bloc/job/job_event.dart';
import '../../bloc/job/job_state.dart';
import '../../models/job_models.dart';
import '../../services/api_service.dart';

class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {
  List<JobModel> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        endpoint: 'jobs/',
        requireAuth: true,
      );

      if (response['success'] == true && response['data'] is List) {
        setState(() {
          _jobs = (response['data'] as List)
              .map((json) => JobModel.fromJson(json))
              .toList();
        });
      } else {
        setState(() {
          _jobs = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading jobs: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createJob(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        endpoint: 'jobs/create/',
        data: data,
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job created successfully'), backgroundColor: Colors.green),
          );
          await _loadJobs();
        }
      } else {
        throw Exception(response['message'] ?? 'Creation failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateJob(String id, Map<String, dynamic> data) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.patch(
        endpoint: 'jobs/$id/',
        data: data,
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job updated successfully'), backgroundColor: Colors.green),
          );
          await _loadJobs();
        }
      } else {
        throw Exception(response['message'] ?? 'Update failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteJob(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job opportunity?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.delete(
        endpoint: 'jobs/$id/',
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job deleted successfully'), backgroundColor: Colors.green),
          );
          await _loadJobs();
        }
      } else {
        throw Exception(response['message'] ?? 'Deletion failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddEditDialog({JobModel? job}) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: job?.title ?? '');
    final companyCtrl = TextEditingController(text: job?.company ?? '');
    final locationCtrl = TextEditingController(text: job?.location ?? '');
    final typeCtrl = TextEditingController(text: job?.type ?? 'Full-time');
    final salaryCtrl = TextEditingController(text: job?.salary ?? '');
    final descriptionCtrl = TextEditingController(text: job?.description ?? '');
    final requirementsCtrl = TextEditingController(text: job?.requirements.join('\n') ?? '');
    final experienceCtrl = TextEditingController(text: job?.experience ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(job == null ? 'Add Job Opportunity' : 'Edit Job Opportunity'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Job Title *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(labelText: 'Company Name *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                DropdownButtonFormField<String>(
                  value: typeCtrl.text,
                  decoration: const InputDecoration(labelText: 'Job Type'),
                  items: const [
                    DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                    DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                    DropdownMenuItem(value: 'Freelance', child: Text('Freelance')),
                    DropdownMenuItem(value: 'Internship', child: Text('Internship')),
                  ],
                  onChanged: (value) => typeCtrl.text = value ?? 'Full-time',
                ),
                TextFormField(
                  controller: salaryCtrl,
                  decoration: const InputDecoration(labelText: 'Salary'),
                ),
                TextFormField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: requirementsCtrl,
                  decoration: const InputDecoration(labelText: 'Requirements (one per line)'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: experienceCtrl,
                  decoration: const InputDecoration(labelText: 'Experience Level'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);

                final requirements = requirementsCtrl.text
                    .split('\n')
                    .where((r) => r.trim().isNotEmpty)
                    .toList();

                final jobData = {
                  'title': titleCtrl.text,
                  'company': companyCtrl.text,
                  'location': locationCtrl.text,
                  'type': typeCtrl.text,
                  'salary': salaryCtrl.text,
                  'description': descriptionCtrl.text,
                  'requirements': requirements,
                  'experience': experienceCtrl.text,
                };

                if (job == null) {
                  _createJob(jobData);
                } else {
                  _updateJob(job.id, jobData);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Opportunities',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ✅ تغيير لون سهم الرجوع إلى الأبيض
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadJobs,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _jobs.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No job opportunities available', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap + to add one', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length,
        itemBuilder: (ctx, index) {
          final job = _jobs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Text(
                  job.company.isNotEmpty ? job.company[0].toUpperCase() : 'J',
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.company, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    job.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showAddEditDialog(job: job),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => _deleteJob(job.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // ✅ تغيير لون علامة الزائد إلى الأبيض
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}