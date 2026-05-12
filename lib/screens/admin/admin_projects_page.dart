// 📄 lib/screens/admin/admin_projects_page.dart
// ============================================================
// 🖼️ صفحة إدارة مشاريع الطلاب المميزة للأدمن
// ============================================================

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/project_models.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  List<FeaturedProject> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        endpoint: 'projects/admin-all/',
        requireAuth: true,
      );

      if (response['success'] == true && response['data'] is List) {
        setState(() {
          _projects = (response['data'] as List)
              .map((json) => FeaturedProject.fromJson(json))
              .toList();
        });
      } else {
        setState(() {
          _projects = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading projects: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createProject(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        endpoint: 'projects/create/',
        data: data,
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project created successfully'), backgroundColor: Colors.green),
          );
          await _loadProjects();
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

  Future<void> _deleteProject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this student project?'),
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
        endpoint: 'projects/$id/',
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully'), backgroundColor: Colors.green),
          );
          await _loadProjects();
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

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final studentNameCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Student Project'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: studentNameCtrl,
                  decoration: const InputDecoration(labelText: 'Student Name *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Project Title *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: imageUrlCtrl,
                  decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
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
                _createProject({
                  'student_name': studentNameCtrl.text,
                  'project_title': titleCtrl.text,
                  'description': descriptionCtrl.text,
                  'imageUrl': imageUrlCtrl.text.isNotEmpty ? imageUrlCtrl.text : null,
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Projects'),
        backgroundColor: Colors.deepPurple,
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
              onPressed: _loadProjects,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _projects.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No student projects yet', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap + to add a featured project', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _projects.length,
        itemBuilder: (ctx, index) {
          final project = _projects[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المشروع
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: project.imageUrl != null
                        ? Image.network(
                      project.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    )
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                // معلومات المشروع
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.studentName,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () => _deleteProject(project.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}