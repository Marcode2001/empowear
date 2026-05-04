import 'package:flutter/material.dart';

class ReceiveStudentProjectsPage extends StatefulWidget {
  const ReceiveStudentProjectsPage({super.key});

  @override
  State<ReceiveStudentProjectsPage> createState() => _ReceiveStudentProjectsPageState();
}

class _ReceiveStudentProjectsPageState extends State<ReceiveStudentProjectsPage> {
  // قائمة المشاريع المقدمة من الطلاب
  final List<Map<String, dynamic>> submittedProjects = [
    {
      'id': '1',
      'title': 'E-commerce App UI',
      'studentName': 'Ahmed Mansour',
      'submittedDate': '2024-05-15',
      'description': 'Complete e-commerce app design with cart and checkout screens',
      'imageUrl': null,
      'grade': null, // الدرجة (تظهر بعد التقييم)
    },
    {
      'id': '2',
      'title': 'Portfolio Website',
      'studentName': 'Sara Ahmed',
      'submittedDate': '2024-05-14',
      'description': 'Personal portfolio website showcasing best work and skills',
      'imageUrl': null,
      'grade': null,
    },
    {
      'id': '3',
      'title': 'Weather App',
      'studentName': 'Omar Khalid',
      'submittedDate': '2024-05-13',
      'description': 'Weather application with real-time data and 7-day forecast',
      'imageUrl': null,
      'grade': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط العلوي مع تدرج لوني
      appBar: AppBar(
        title: const Text(
          'Student Projects',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: submittedProjects.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
              ),
              const SizedBox(height: 20),
              Text(
                'No Projects Submitted',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Projects submitted by students will appear here',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: submittedProjects.length,
          itemBuilder: (context, index) {
            final project = submittedProjects[index];
            return _buildProjectCard(project);
          },
        ),
      ),
    );
  }

  // دالة لبناء بطاقة المشروع
  Widget _buildProjectCard(Map<String, dynamic> project) {
    final hasGraded = project['grade'] != null; // هل تم تقييم المشروع؟
    final grade = project['grade']; // الدرجة
    final isFGrade = grade == 'F'; // هل الدرجة F؟

    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة التفاصيل عند الضغط
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailPage(
              project: project,
              onGradeSubmitted: (grade) {
                setState(() {
                  project['grade'] = grade; // تحديث الدرجة
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف العنوان والأيقونة
                  Row(
                    children: [
                      // أيقونة المشروع مع تدرج لوني
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.assignment, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          project['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // عرض الدرجة إذا تم التقييم
                      if (hasGraded)
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: isFGrade ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFGrade ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              grade,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isFGrade ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // معلومات الطالب والتاريخ
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        project['studentName'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        project['submittedDate'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // وصف مختصر للمشروع
                  Text(
                    project['description'].length > 100
                        ? '${project['description'].substring(0, 100)}...'
                        : project['description'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // زر عرض التفاصيل مع تدرج لوني
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== صفحة تفاصيل المشروع ====================
class ProjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> project;
  final Function(String) onGradeSubmitted;
  const ProjectDetailPage({
    super.key,
    required this.project,
    required this.onGradeSubmitted,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String? _selectedGrade; // الدرجة المختارة
  bool _isSubmitting = false; // حالة الإرسال
  bool _isGraded = false; // هل تم التقييم مسبقاً؟

  // قائمة الدرجات المتاحة
  final List<Map<String, dynamic>> _grades = [
    {'value': 'A+', 'color': Colors.green},
    {'value': 'A', 'color': Colors.green},
    {'value': 'B+', 'color': Colors.green},
    {'value': 'B', 'color': Colors.green},
    {'value': 'C+', 'color': Colors.green},
    {'value': 'C', 'color': Colors.green},
    {'value': 'D', 'color': Colors.green},
    {'value': 'F', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _isGraded = widget.project['grade'] != null;
    if (_isGraded) {
      _selectedGrade = widget.project['grade']; // تعيين الدرجة الموجودة
    }
  }

  // دالة لإرسال الدرجة
  void _submitGrade() {
    // التحقق من اختيار درجة
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a grade'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // محاكاة عملية الإرسال
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSubmitting = false;
      });

      // إرسال الدرجة فقط (بدون فيدباك)
      widget.onGradeSubmitted(_selectedGrade!);

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grade submitted for ${widget.project['studentName']}'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // العودة للصفحة السابقة
    });
  }

  // دالة لتحديد لون الدرجة
  Color _getGradeColor(String grade) {
    if (grade == 'F') return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project['title'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // أيقونة الطالب مع تدرج لوني واسمه
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              widget.project['studentName'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // أيقونة التاريخ مع تدرج لوني
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submission Date',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.project['submittedDate'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // أيقونة الوصف مع تدرج لوني ونص الوصف
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.project['description'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // معاينة المشروع
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // أيقونة المعاينة مع تدرج لوني
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Project Preview',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 50, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('No preview available'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download),
                            label: const Text('Download Project File'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // قسم التقييم (درجات فقط)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple.withOpacity(0), Colors.purple.withOpacity(0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // أيقونة التقييم مع تدرج لوني
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.grade, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Grade',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // عنوان اختيار الدرجة
                        const Text(
                          'Select Grade',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500 , color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 12),

                        // أزرار اختيار الدرجات (بدون أنيميشن)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _grades.map((grade) {
                            final isSelected = _selectedGrade == grade['value'];
                            final isF = grade['value'] == 'F';
                            return GestureDetector(
                              onTap: _isGraded ? null : () {
                                setState(() {
                                  _selectedGrade = grade['value'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  // تدرج لوني للدرجة المحددة
                                  gradient: isSelected
                                      ? (isF
                                      ? const LinearGradient(
                                    colors: [Colors.red, Colors.redAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                      : const LinearGradient(
                                    colors: [Colors.green, Colors.lightGreen],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ))
                                      : null,
                                  color: !isSelected ? Colors.white : null,
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: Text(
                                  grade['value'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.deepPurple,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.bold
                                    ,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 40),

                        // زر إرسال التقييم مع تدرج لوني
                        if (!_isGraded)
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitGrade,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Submit Grade',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          )
                        else
                        // عرض رسالة عند التقييم المسبق
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getGradeColor(widget.project['grade']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: _getGradeColor(widget.project['grade'])),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Already Graded',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: _getGradeColor(widget.project['grade'])),
                                      ),
                                      Text(
                                        'Grade: ${widget.project['grade']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}