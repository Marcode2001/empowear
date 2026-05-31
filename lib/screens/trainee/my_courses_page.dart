// 📄 lib/screens/trainee/my_courses_page.dart
// ============================================================
// 📚 صفحة عرض الكورسات المسجلة للطالب (My Courses Page)
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_certificates_page.dart';
import 'certificate_page.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';
import '../../bloc/course/course_state.dart';

import '../../bloc/certificate/certificate_bloc.dart';
import '../../bloc/certificate/certificate_event.dart';
import '../../bloc/certificate/certificate_state.dart';

import '../../models/course_models.dart';
import '../../repositories/course_repository.dart';
import 'content_viewer_page.dart';

// ============================================================
// صفحة My Courses (تعرض الكورسات المسجلة فقط)
// ============================================================

class MyCoursesPage extends StatefulWidget {
  final String? selectedCourseId;
  final List<CourseItem>? courses;

  const MyCoursesPage({
    super.key,
    this.selectedCourseId,
    this.courses,
  });

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  // متغيرات البحث
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<CourseItem> courses = [];
  String _selectedCategoryId = '';

  // ✅ Cache للجلسات مع المحتوى (لتجنب جلب البيانات عدة مرات)
  final Map<String, List<Session>> _cachedSessions = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // تحميل الكورسات من الـ widget
  void _loadCourses() {
    if (widget.courses != null && widget.courses!.isNotEmpty) {
      setState(() {
        courses = widget.courses!;
        if (widget.selectedCourseId != null) {
          _selectedCategoryId = widget.selectedCourseId!;
        }
      });
    }
  }

  // فلترة الكورسات حسب البحث
  List<CourseItem> get _filteredCourses {
    if (_searchQuery.isEmpty) return courses;
    return courses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.trainerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // عدد النتائج
  int get _totalResultsCount => _filteredCourses.length;

  // ✅ الدالة الرئيسية: جلب الجلسات مع المحتوى من API
  Future<List<Session>> _fetchSessionsWithContent(String courseId) async {
    try {
      print('📚 [MyCourses] جلب الجلسات مع المحتوى للكورس: $courseId');
      // نستخدم الدالة الجديدة التي تجلب الجلسات والمحتوى معاً
      final sessions = await CourseRepository().getCourseSessionsWithContent(courseId);
      print('✅ [MyCourses] تم جلب ${sessions.length} جلسة');

      // طباعة تفاصيل الجلسات والمحتوى للتصحيح
      for (var session in sessions) {
        print('   📗 الجلسة ${session.sessionOrder}: ${session.title} - ${session.contents.length} دروس');
        for (var content in session.contents) {
          print('      📄 ${content.title} (${content.contentType}) - الرابط: ${content.fileUrl}');
        }
      }

      return sessions;
    } catch (e) {
      print('❌ [MyCourses] خطأ: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CertificateBloc, CertificateState>(
      listener: (context, state) {
        if (state is CertificateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is CertificateSuccess) {
          final url = state.certificateUrl;

          if (url.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid certificate URL")),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CertificateViewerPage(pdfUrl: url),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('My Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
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
        body: courses.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No courses registered yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Go to Register Course to start learning',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // حقل البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by course name or trainer...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$_totalResultsCount results found', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No courses found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredCourses.length,
                itemBuilder: (context, index) => _buildCourseCard(_filteredCourses[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🃏 بناء بطاقة الكورس (المعدلة لإظهار جميع المعلومات)
  // ============================================================
  Widget _buildCourseCard(CourseItem course) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurriculumPage(
            course: course,
            cachedSessions: _cachedSessions,
            fetchSessionsWithContent: _fetchSessionsWithContent,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والمدرب
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(course.trainerName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ المعلومات الإضافية (المستوى، النوع، السعر، عدد الطلاب)
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _infoChip("Level ${course.levelNumber}", Icons.bar_chart),
                _infoChip(course.courseType, Icons.category),
                _infoChip("${course.price} \$", Icons.attach_money),

              ],
            ),

            const SizedBox(height: 8),

            // ✅ الأدوات المطلوبة
            if (course.toolsRequired.isNotEmpty)
              Text(
                "Tools: ${course.toolsRequired}",
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // زر الحصول على الشهادة
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final levelNumber = course.levelNumber;

                    if (levelNumber == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Level number not available")),
                      );
                      return;
                    }

                    context.read<CertificateBloc>().add(
                      GenerateCertificateEvent(
                        levelNumber: course.levelNumber,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Get Certificate",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

    );

  }


  // ✅ دالة مساعدة لعرض المعلومات بشكل منسدل (Chip)
  Widget _infoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11)),
        ],
      ),

    );

  }

}

// ============================================================
// 📖 صفحة المنهاج (Curriculum Page) - المعدلة
// ============================================================

class CurriculumPage extends StatefulWidget {
  final CourseItem course;
  final Map<String, List<Session>> cachedSessions;
  final Future<List<Session>> Function(String) fetchSessionsWithContent;

  const CurriculumPage({
    super.key,
    required this.course,
    required this.cachedSessions,
    required this.fetchSessionsWithContent,
  });

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  List<Session> _sessions = [];
  bool _isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // تحميل الجلسات (من cache أو من API)
  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      List<Session> sessions;
      // نتحقق من cache أولاً
      if (widget.cachedSessions.containsKey(widget.course.id)) {
        sessions = widget.cachedSessions[widget.course.id]!;
        print('✅ [Curriculum] استخدام الجلسات من cache');
      } else {
        // نجلب من API
        sessions = await widget.fetchSessionsWithContent(widget.course.id);
        widget.cachedSessions[widget.course.id] = sessions;
        print('✅ [Curriculum] تم جلب ${sessions.length} جلسة من API');
      }
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
      });
    } catch (e) {
      print('❌ [Curriculum] خطأ: $e');
      setState(() => _isLoadingSessions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple])),
        ),
      ),
      body: Column(
        children: [
          // رأس الكورس
          _buildCourseHeader(),
          const SizedBox(height: 16),
          // عنوان المنهاج
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Curriculum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // قائمة الجلسات
          Expanded(
            child: _isLoadingSessions
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                // ✅ إضافة مسافة في آخر عنصر
                if (index == _sessions.length - 1) {
                  return Column(
                    children: [
                      _buildSessionCard(_sessions[index]),
                      const SizedBox(height: 60), // ✅ مسافة إضافية في نهاية الصفحة
                    ],
                  );
                }
                return _buildSessionCard(_sessions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // رأس الكورس (Header)
  Widget _buildCourseHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            widget.course.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Trainer: ${widget.course.trainerName}',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),

        ],
      ),
    );
  }

  // شريط معلومات صغير
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // حالة عدم وجود جلسات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No sessions available for this course yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 20), // ✅ مسافة إضافية في حالة عدم وجود جلسات
        ],
      ),
    );
  }

  // ============================================================
  // 🎴 بطاقة الجلسة
  // ============================================================
  Widget _buildSessionCard(Session session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.file_copy_rounded, color: Colors.white, size: 24),
        ),
        title: Text(
          session.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              session.description.isNotEmpty ? session.description : 'No description',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.lessonsCount} lessons',
              style: TextStyle(fontSize: 11, color: Colors.deepPurple),
            ),
          ],
        ),
        // ✅ المحتوى موجود مباشرة في session.contents
        children: session.contents.isEmpty
            ? [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No content available for this session'),
          ),
          const SizedBox(height: 8), // ✅ مسافة صغيرة بعد النص
        ]
            : session.contents.map((content) => _buildLessonCard(content)).toList(),
      ),
    );
  }

  // ============================================================
  // 📄 بطاقة الدرس
  // ============================================================
  Widget _buildLessonCard(CourseContent content) {
    final isVideo = content.contentType.toLowerCase() == 'video';
    final isPdf = content.contentType.toLowerCase() == 'pdf';

    // للتصحيح: نطبع رابط الملف
    print('📄 [LessonCard] ${content.title} - الرابط: ${content.fileUrl}');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // أيقونة الدرس
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isVideo
                  ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                  : (isPdf
                  ? const LinearGradient(colors: [Colors.red, Colors.deepOrange])
                  : const LinearGradient(colors: [Colors.blue, Colors.lightBlue])),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVideo ? Icons.play_arrow : (isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // معلومات الدرس
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVideo ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content.contentType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isVideo ? Colors.deepPurple : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Part ${content.contentOrder}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // زر فتح الملف
          GestureDetector(
            onTap: () {
              // ننتقل إلى صفحة عرض المحتوى
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentViewerPage(content: content),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isVideo
                    ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                    : (isPdf
                    ? const LinearGradient(colors: [Colors.red, Colors.deepOrange])
                    : const LinearGradient(colors: [Colors.blue, Colors.lightBlue])),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isVideo ? 'Watch' : (isPdf ? 'View PDF' : 'Open'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}