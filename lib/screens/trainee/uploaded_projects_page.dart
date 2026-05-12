// 📄 lib/screens/trainee/upload_project_page.dart
// ============================================================
// 📤 صفحة رفع مشروع جديد - متوافقة مع API design-submission
// ✅ تسمح باختيار الكورس والجلسة من قائمة منسدلة
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';
import '../../bloc/course/course_state.dart';
import '../../models/course_models.dart';
import '../../services/api_service.dart';
import 'package:empower/repositories/course_repository.dart';

class UploadProjectPage extends StatefulWidget {
  // ✅ البيانات الاختيارية (يمكن تمريرها من الصفحات الأخرى)
  final int? preselectedCourseId;     // معرف الكورس المختار مسبقاً
  final int? preselectedSessionId;    // معرف الجلسة المختارة مسبقاً
  final String? preselectedCourseTitle; // عنوان الكورس (للعرض فقط)

  const UploadProjectPage({
    super.key,
    this.preselectedCourseId,
    this.preselectedSessionId,
    this.preselectedCourseTitle,
  });

  @override
  State<UploadProjectPage> createState() => _UploadProjectPageState();
}

class _UploadProjectPageState extends State<UploadProjectPage> {
  // ============================================================
  // 📝 متحكمات حقول الإدخال
  // ============================================================
  final TextEditingController _titleController = TextEditingController();

  // 🖼️ الصورة المختارة
  File? _selectedImage;

  // ⏳ حالة التحميل
  bool _isSubmitting = false;

  // 📚 بيانات الكورسات والجلسات
  List<CourseItem> _registeredCourses = [];
  bool _isLoadingCourses = true;
  int? _selectedCourseId;
  int? _selectedSessionId;
  int? _selectedSessionOrder;
  String? _selectedCourseTitle;
  List<Session> _sessions = [];
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    _loadRegisteredCourses();

    // ✅ إذا تم تمرير بيانات مسبقة، استخدمها
    if (widget.preselectedCourseId != null) {
      _selectedCourseId = widget.preselectedCourseId;
      _selectedCourseTitle = widget.preselectedCourseTitle;
      if (widget.preselectedSessionId != null) {
        _selectedSessionId = widget.preselectedSessionId;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ============================================================
  // 📚 تحميل الكورسات المسجلة
  // ============================================================
  Future<void> _loadRegisteredCourses() async {
    setState(() => _isLoadingCourses = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CourseBloc>().add(LoadRegisteredCoursesEvent(userId: authState.user.id , userType: authState.user.userType,));
    }

    // انتظار تحميل الكورسات من الـ BLoC
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoadingCourses = false);
  }

  // ============================================================
  // 📚 تحميل جلسات كورس معين
  // ============================================================
  Future<void> _loadSessions(int courseId) async {
    setState(() {
      _isLoadingSessions = true;
      _sessions = [];
      _selectedSessionId = null;
      _selectedSessionOrder = null;
    });

    try {
      final sessions = await CourseRepository().getCourseSessions(courseId.toString());
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل الجلسات: $e');
      setState(() => _isLoadingSessions = false);
    }
  }

  // ============================================================
  // 📸 دوال اختيار الصورة
  // ============================================================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // ============================================================
  // 📤 دالة إرسال المشروع
  // ============================================================
  Future<void> _submitProject() async {
    // ✅ التحقق من صحة المدخلات
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter project title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ التحقق من اختيار الكورس
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ التحقق من اختيار الجلسة
    if (_selectedSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a session'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ التحقق من اختيار الصورة
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or take a photo of your project'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ إظهار مؤشر التحميل
    setState(() {
      _isSubmitting = true;
    });

    try {
      // ✅ بناء البيانات المطلوبة للـ API
      final fields = {
        'course': _selectedCourseId.toString(),
        'course_session': _selectedSessionId.toString(),
        'session_order': (_selectedSessionOrder ?? 1).toString(),
        'title': _titleController.text.trim(),
      };

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 [Upload] إرسال مشروع جديد:');
      print('   course: ${fields['course']}');
      print('   course_session: ${fields['course_session']}');
      print('   session_order: ${fields['session_order']}');
      print('   title: ${fields['title']}');
      print('   image path: ${_selectedImage!.path}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ إرسال الطلب إلى الـ API
      final response = await ApiService.postMultipart(
        endpoint: 'design-submission/trainee-create/',
        fields: fields,
        filePath: _selectedImage!.path,
        fileFieldName: 'image',
      );

      print('📊 [Upload] استجابة الخادم: ${response['statusCode']}');
      print('📝 [Upload] البيانات: ${response['data']}');

      setState(() {
        _isSubmitting = false;
      });

      if (response['success']) {
        // ✅ عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted successfully! Waiting for trainer review.'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ تنظيف الحقول
        _titleController.clear();
        setState(() {
          _selectedImage = null;
        });

        // ✅ العودة إلى الصفحة السابقة
        Navigator.pop(context);
      } else {
        // ❌ عرض رسالة خطأ
        String errorMessage = 'Failed to submit project';
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          if (data['error'] != null) {
            errorMessage = data['error'].toString();
          } else if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ [Upload] خطأ: $e');
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // 🎨 بناء واجهة المستخدم
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Project',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is RegisteredCoursesLoaded) {
            setState(() {
              _registeredCourses = state.registeredCourses;
              _isLoadingCourses = false;

              // ✅ إذا لم يتم اختيار كورس مسبقاً وكان هناك كورسات، اختر الأول
              if (_selectedCourseId == null && _registeredCourses.isNotEmpty) {
                _selectedCourseId = int.tryParse(_registeredCourses.first.id);
                _selectedCourseTitle = _registeredCourses.first.title;
                if (_selectedCourseId != null) {
                  _loadSessions(_selectedCourseId!);
                }
              }
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // 📚 اختيار الكورس
              // ============================================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.school, color: Colors.deepPurple, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Select Course',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ قائمة منسدلة لاختيار الكورس
                    if (_isLoadingCourses)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_registeredCourses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No registered courses found. Please register for a course first.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedCourseId,
                        decoration: InputDecoration(
                          hintText: 'Select a course',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _registeredCourses.map((course) {
                          return DropdownMenuItem<int>(
                            value: int.tryParse(course.id),
                            child: Text(course.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                            final selectedCourse = _registeredCourses.firstWhere(
                                  (c) => int.tryParse(c.id) == value,
                              orElse: () => _registeredCourses.first,
                            );
                            _selectedCourseTitle = selectedCourse.title;
                          });
                          if (value != null) {
                            _loadSessions(value);
                          }
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============================================================
              // 📚 اختيار الجلسة
              // ============================================================
              // ============================================================
// 📚 اختيار الجلسة (Session Selection) - نسخة معدلة
// ============================================================
              if (_selectedCourseId != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.video_library, color: Colors.deepPurple, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Select Session',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ✅ قائمة منسدلة لاختيار الجلسة (مع تقليم النص)
                      if (_isLoadingSessions)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_sessions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No sessions available for this course.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: DropdownButtonFormField<int>(
                            value: _selectedSessionId,
                            isExpanded: true,
                            hint: const Text('Select a session'),
                            decoration: InputDecoration(
                              hintText: 'Select a session',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _sessions.map((session) {
                              // ✅ تقليص النص الطويل
                              String sessionText = 'Session ${session.sessionOrder ?? 0}: ${session.title}';
                              if (sessionText.length > 45) {
                                sessionText = sessionText.substring(0, 45) + '...';
                              }
                              return DropdownMenuItem<int>(
                                value: session.id,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 70,
                                  child: Text(
                                    sessionText,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSessionId = value;
                                final selectedSession = _sessions.firstWhere(
                                      (s) => s.id == value,
                                  orElse: () => _sessions.first,
                                );
                                _selectedSessionOrder = selectedSession.sessionOrder;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ============================================================
              // 📝 نموذج إدخال بيانات المشروع
              // ============================================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.deepPurple),
                        SizedBox(width: 10),
                        Text(
                          'Project Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ حقل عنوان المشروع (title) - مطلوب
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Project Title *',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintText: 'e.g., Final Dress Design',
                        prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 📸 قسم رفع الصورة
              // ============================================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.image, color: Colors.deepPurple),
                        SizedBox(width: 10),
                        Text(
                          'Project Image *',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // أزرار اختيار الصورة
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // عرض الصورة المختارة
                    if (_selectedImage != null)
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 250,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white.withOpacity(0.95),
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.deepPurple),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // تنبيه
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Upload a clear image of your project work (JPG, PNG)',
                              style: TextStyle(fontSize: 11, color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // زر الإرسال
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _isSubmitting ? null : _submitProject,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        alignment: Alignment.center,
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
                          'SUBMIT PROJECT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ملاحظة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your project will be reviewed by the trainer. You will see the evaluation in your profile once reviewed.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}