// 📄 lib/screens/trainer/receive_student_projects_page.dart
// ============================================================
// 📥 صفحة استلام مشاريع الطلاب - متوافقة مع API
// ============================================================

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReceiveStudentProjectsPage extends StatefulWidget {
  const ReceiveStudentProjectsPage({super.key});

  @override
  State<ReceiveStudentProjectsPage> createState() => _ReceiveStudentProjectsPageState();
}

class _ReceiveStudentProjectsPageState extends State<ReceiveStudentProjectsPage> {
  List<dynamic> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(
        endpoint: 'design-submission/trainer-all-submissions/',
        requireAuth: true,
      );
      if (response['success']) {
        final data = response['data'];
        setState(() {
          _submissions = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading submissions: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitGrade(String submissionId, String grade) async {
    try {
      final response = await ApiService.post(
        endpoint: 'design-evaluation/trainer-create/',
        data: {
          'design_submission': int.tryParse(submissionId) ?? 0,
          'grade_letter': grade,
        },
        requireAuth: true,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade submitted successfully!'), backgroundColor: Colors.green),
        );
        _loadSubmissions(); // إعادة تحميل القائمة
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit grade'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('❌ Error submitting grade: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Projects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        // 🏹 تغيير لون سهم الرجوع إلى الأبيض
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text('No projects submitted yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _submissions.length,
        itemBuilder: (context, index) {
          final submission = _submissions[index];
          return _buildSubmissionCard(submission);
        },
      ),
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    final id = submission['id']?.toString() ?? '';
    final title = submission['title'] ?? 'Untitled';
    final studentName = submission['trainee_full_name'] ?? submission['trainee_name'] ?? 'Unknown';
    final courseTitle = submission['course_title'] ?? 'Unknown Course';
    final sessionTitle = submission['session_title'] ?? 'Unknown Session';
    final imageUrl = submission['image'] ?? '';
    final status = submission['submission_status'] ?? 'Pending';
    final isEvaluated = status == 'Evaluated';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.assignment, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    if (isEvaluated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Graded', style: TextStyle(fontSize: 11, color: Colors.green)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(child: Text(studentName, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.school, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(child: Text(courseTitle, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.video_library, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(child: Text(sessionTitle, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                  ],
                ),
                const SizedBox(height: 16),
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'http://192.168.1.22:8000$imageUrl',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!isEvaluated)
                  _buildGradeSelector(
                    onGradeSelected: (grade) => _submitGrade(id, grade),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSelector({
    required Function(String) onGradeSelected,
  }) {
    final List<String> grades = [
      'A+',
      'A',
      'B+',
      'B',
      'C+',
      'C',
      'D',
      'F'
    ];

    String? selectedGrade;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Grade',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: grades.map((grade) {
                final isSelected = selectedGrade == grade;
                final isF = grade == 'F';

                return GestureDetector(
                  onTap: () {
                    setModalState(() {
                      // ✅ إذا كانت الدرجة محددة بالفعل، قم بإلغاء تحديدها
                      // ✅ وإلا قم بتحديد الدرجة الجديدة
                      if (selectedGrade == grade) {
                        selectedGrade = null; // إلغاء التحديد
                      } else {
                        selectedGrade = grade; // تحديد الدرجة الجديدة
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? (isF
                          ? const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                      )
                          : const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                      ))
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      grade,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedGrade != null
                    ? () => onGradeSelected(selectedGrade!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  'Submit Grade',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}