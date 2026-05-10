// 📄 lib/screens/trainee/upload_project_page.dart
// ============================================================
// 📤 صفحة رفع مشروع جديد (Upload Project Page)
// ============================================================
// الوظيفة: تسمح للطالب برفع مشروعه الخاص
// 1. إدخال اسم المشروع
// 2. إدخال اسم الكورس
// 3. رفع صورة (تظهر كاملة بدون قص)
// 4. إرسال البيانات إلى المدرب للتصحيح

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/project/project_bloc.dart';
import '../../models/project_models.dart';

class UploadProjectPage extends StatefulWidget {
  // ✅ معاملات الصفحة (اختيارية - يمكن تمريرها من الصفحات الأخرى)
  final String? projectId;      // معرف المشروع (إذا كان مطلوباً من المدرب)
  final String? courseName;     // اسم الكورس (يمكن تعبئته تلقائياً)

  const UploadProjectPage({
    super.key,
    this.projectId,
    this.courseName,
  });

  @override
  State<UploadProjectPage> createState() => _UploadProjectPageState();
}

class _UploadProjectPageState extends State<UploadProjectPage> {
  // ============================================================
  // 📝 متحكمات حقول الإدخال (Controllers)
  // ============================================================
  final TextEditingController _projectNameController = TextEditingController();   // اسم المشروع
  final TextEditingController _courseNameController = TextEditingController();     // اسم الكورس
  final TextEditingController _trainerNameController = TextEditingController();    // اسم المدرب

  // 🖼️ متغير الصورة المختارة
  File? _selectedImage;

  // ⏳ حالة التحميل (إظهار مؤشر التحميل أثناء الإرسال)
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // ✅ تعبئة الحقول إذا كانت هناك بيانات موجودة (ممررة من الصفحة السابقة)
    if (widget.courseName != null) {
      _courseNameController.text = widget.courseName!;
    }
  }

  @override
  void dispose() {
    // 🧹 تنظيف المتحكمات لتجنب تسرب الذاكرة
    _projectNameController.dispose();
    _courseNameController.dispose();
    _trainerNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // 📸 دوال اختيار الصورة
  // ============================================================

  /// اختيار صورة من المعرض (Gallery)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// التقاط صورة من الكاميرا (Camera)
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
  void _submitProject() async {
    // ✅ التحقق من صحة المدخلات
    if (_projectNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter project name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_courseNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter course name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

    // ✅ الحصول على بيانات المستخدم من AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // ✅ إرسال حدث رفع المشروع إلى ProjectBloc
      context.read<ProjectBloc>().add(SubmitProjectEvent(
        projectId: widget.projectId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: authState.user.id,
        studentName: authState.user.name,
        projectUrl: _selectedImage!.path,
        description: '',
      ));
    }

    // ✅ إخفاء مؤشر التحميل
    setState(() {
      _isSubmitting = false;
    });

    // ✅ عرض رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project submitted successfully! Waiting for trainer review.'),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ تنظيف الحقول بعد الإرسال
    _projectNameController.clear();
    _courseNameController.clear();
    _trainerNameController.clear();
    setState(() {
      _selectedImage = null;
    });

    // ✅ العودة إلى الصفحة السابقة
    Navigator.pop(context);
  }

  // ============================================================
  // 🎨 بناء واجهة المستخدم (UI)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 شريط التطبيق العلوي (AppBar)
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
      // 👂 الاستماع لتغيرات حالة ProjectBloc (لإظهار رسائل النجاح/الخطأ)
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    // 🏷️ عنوان القسم
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

                    // ✅ حقل اسم المشروع (مطلوب)
                    TextFormField(
                      controller: _projectNameController,
                      decoration: InputDecoration(
                        labelText: 'Project Name',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
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
                    const SizedBox(height: 16),

                    // ✅ حقل اسم الكورس (مطلوب)
                    TextFormField(
                      controller: _courseNameController,
                      decoration: InputDecoration(
                        labelText: 'Course Name',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.school, color: Colors.deepPurple),
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
              // 📸 قسم رفع الصورة (تظهر كاملة بدون قص)
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
                    // 🏷️ عنوان القسم
                    const Row(
                      children: [
                        Icon(Icons.image, color: Colors.deepPurple),
                        SizedBox(width: 10),
                        Text(
                          'Project Image',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ أزرار اختيار الصورة (Gallery + Camera)
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

                    // ✅ عرض الصورة المختارة (تظهر كاملة بدون قص)
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

                    // ✅ تنبيه بخصوص الصورة
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
                              'Upload a clear image of your project work',
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

              // ============================================================
              // ✅ زر إرسال المشروع (SUBMIT )
              // ============================================================
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

              const SizedBox(height: 80),

              // ✅ ملاحظة حول عملية التسليم
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
                        'Your project will be reviewed by the trainer. You will see the grade in your profile once reviewed.',
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