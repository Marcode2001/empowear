// 📄 lib/screens/trainee/my_courses_page.dart
// ============================================================
// 📚 صفحة عرض الكورسات المسجلة للطالب (My Courses Page)
// ✅ النسخة المعدلة - تجلب الجلسات والمحتوى من الـ API ديناميكياً
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';
import '../../bloc/course/course_state.dart';
import '../../models/course_models.dart';
import '../../repositories/course_repository.dart';

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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<CourseItem> courses = [];
  String _selectedCategoryId = '';

  // ✅ Cache للجلسات (المفتاح: courseId)
  final Map<String, List<Session>> _cachedSessions = {};
  // ✅ Cache للمحتوى (المفتاح: '${courseId}_${sessionId}')
  final Map<String, List<CourseContent>> _cachedContents = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

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

  List<CourseItem> get _filteredCourses {
    if (_searchQuery.isEmpty) return courses;
    return courses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.trainerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get _totalResultsCount => _filteredCourses.length;

  // ✅ جلب الجلسات من الـ API
  Future<List<Session>> _fetchSessions(String courseId) async {
    try {
      return await CourseRepository().getCourseSessions(courseId);
    } catch (e) {
      print('❌ Error fetching sessions: $e');
      return [];
    }
  }

  // ✅ جلب المحتوى الخاص بجلسة معينة
  Future<List<CourseContent>> _fetchContentForSession(String courseId, int sessionId) async {
    try {
      final allContent = await CourseRepository().getCourseContent(courseId);
      return allContent.where((c) => c.courseSession == sessionId).toList();
    } catch (e) {
      print('❌ Error fetching content: $e');
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
    return Scaffold(
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
    );
  }

  Widget _buildCourseCard(CourseItem course) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurriculumPage(
            course: course,
            cachedSessions: _cachedSessions,
            cachedContents: _cachedContents,
            fetchSessions: _fetchSessions,
            fetchContentForSession: _fetchContentForSession,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(course.totalHours, style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: course.progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.deepPurple,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${course.progress}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${course.totalLessons} lessons', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 📖 صفحة المنهاج (Curriculum Page) - مع جلب ديناميكي
// ============================================================

class CurriculumPage extends StatefulWidget {
  final CourseItem course;
  final Map<String, List<Session>> cachedSessions;
  final Map<String, List<CourseContent>> cachedContents;
  final Future<List<Session>> Function(String) fetchSessions;
  final Future<List<CourseContent>> Function(String, int) fetchContentForSession;

  const CurriculumPage({
    super.key,
    required this.course,
    required this.cachedSessions,
    required this.cachedContents,
    required this.fetchSessions,
    required this.fetchContentForSession,
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

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      List<Session> sessions;
      if (widget.cachedSessions.containsKey(widget.course.id)) {
        sessions = widget.cachedSessions[widget.course.id]!;
      } else {
        sessions = await widget.fetchSessions(widget.course.id);
        widget.cachedSessions[widget.course.id] = sessions;
      }
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
      });
    } catch (e) {
      print('❌ Error loading sessions: $e');
      setState(() => _isLoadingSessions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // 🎓 رأس الكورس (Course Header)
          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(widget.course.totalHours, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.course.progress}%',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          Expanded(
            child: _isLoadingSessions
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions available for this course yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return _buildSessionCard(session);
              },
            ),
          ),
        ],
      ),
    );
  }

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
          child: const Icon(Icons.video_library, color: Colors.white, size: 24),
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
        children: [
          // ✅ جلب المحتوى ديناميكياً لكل جلسة
          FutureBuilder<List<CourseContent>>(
            future: widget.cachedContents.containsKey('${widget.course.id}_${session.id}')
                ? Future.value(widget.cachedContents['${widget.course.id}_${session.id}'])
                : widget.fetchContentForSession(widget.course.id, session.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No content available for this session',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                );
              }
              final contents = snapshot.data!;
              if (!widget.cachedContents.containsKey('${widget.course.id}_${session.id}')) {
                widget.cachedContents['${widget.course.id}_${session.id}'] = contents;
              }
              return Column(
                children: [
                  ...contents.map((content) => _buildLessonCard(content)),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(CourseContent content) {
    final isVideo = content.contentType.toLowerCase() == 'video';
    final isPdf = content.contentType.toLowerCase() == 'pdf';

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
                      'Order: ${content.contentOrder}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (content.fileUrl != null && content.fileUrl!.isNotEmpty) {
                // TODO: فتح الرابط باستخدام url_launcher
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening: ${content.title}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No file available')),
                );
              }
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