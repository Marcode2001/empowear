import 'package:flutter/material.dart';
import '../../models/course_models.dart';

// ============================================================
// نماذج البيانات (Models)
// ============================================================

/// نموذج الدرس (Lesson)
class LessonModel {
  final String title;
  final String duration;
  final bool isCompleted;
  final String videoUrl;
  final String type;

  LessonModel({
    required this.title,
    required this.duration,
    this.isCompleted = false,
    this.videoUrl = '',
    this.type = 'video',
  });
}

/// نموذج الكورس (Course)
class CourseModel {
  final String id;
  final String name;
  final String trainer;
  final int progress;
  final String hours;
  final List<LessonModel> curriculum;

  CourseModel({
    required this.id,
    required this.name,
    required this.trainer,
    required this.progress,
    required this.hours,
    required this.curriculum,
  });
}

/// نموذج الجلسة (Session)
class SessionModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final List<CourseModel> courses;

  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.courses,
  });
}

// ============================================================
// صفحة My Courses (تعرض الكورسات المسجلة فقط)
// ============================================================

class MyCoursesPage extends StatefulWidget {
  final String? selectedSessionId;
  final List<SessionModel>? registeredSessions;

  const MyCoursesPage({super.key, this.selectedSessionId,this.registeredSessions,
  });

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedSessionId = '';
  List<SessionModel> sessions = [];

  @override
  void initState() {
    super.initState();

    // ✅ استخدم الكورسات المسجلة إن وجدت، وإلا قائمة فارغة
    if (widget.registeredSessions != null && widget.registeredSessions!.isNotEmpty) {
      sessions = widget.registeredSessions!;
      if (widget.selectedSessionId != null) {
        _selectedSessionId = widget.selectedSessionId!;
      } else {
        _selectedSessionId = sessions.first.id;
      }
    } else {
      sessions = [];
    }
  }

  // ✅ دالة لتحميل الكورسات المسجلة (ستأتي من API لاحقاً)
  void _loadRegisteredCourses() {
    // ✅ حالياً: بيانات فارغة، ستأتي من HomePage
    // سيتم تمرير الكورسات المسجلة من HomePage عبر constructor
    sessions = [];
  }

  // ✅ دالة لتحديث الكورسات المسجلة (تستدعى من HomePage)
  void updateRegisteredCourses(List<SessionModel> registeredSessions) {
    setState(() {
      sessions = registeredSessions;
      if (sessions.isNotEmpty && _selectedSessionId.isEmpty) {
        _selectedSessionId = sessions.first.id;
      }
    });
  }

  // دالة لفلترة الجلسات والكورسات حسب البحث
  List<MapEntry<SessionModel, List<CourseModel>>> get _filteredSessionsAndCourses {
    if (_searchQuery.isEmpty) {
      return sessions.expand((session) {
        return [MapEntry(session, session.courses)];
      }).toList();
    }

    final results = <MapEntry<SessionModel, List<CourseModel>>>[];
    for (var session in sessions) {
      final sessionMatches = session.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchingCourses = session.courses.where((course) {
        return course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.trainer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      if (sessionMatches || matchingCourses.isNotEmpty) {
        results.add(MapEntry(session, sessionMatches ? session.courses : matchingCourses));
      }
    }
    return results;
  }

  int get _totalResultsCount {
    if (_searchQuery.isEmpty) return sessions.fold(0, (sum, session) => sum + session.courses.length);
    int count = 0;
    for (var entry in _filteredSessionsAndCourses) {
      count += entry.value.length;
    }
    return count;
  }

  List<CourseModel> get _filteredCourses {
    if (_selectedSessionId.isEmpty && sessions.isNotEmpty) {
      _selectedSessionId = sessions.first.id;
    }

    try {
      final selectedSession = sessions.firstWhere((s) => s.id == _selectedSessionId);
      var courses = List<CourseModel>.from(selectedSession.courses);
      if (_searchQuery.isNotEmpty) {
        courses = courses.where((course) {
          return course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              course.trainer.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
      return courses;
    } catch (e) {
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
      body: sessions.isEmpty
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
          : SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // ==================== حقل البحث ====================
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

            if (_searchQuery.isEmpty && sessions.isNotEmpty)
              Column(
                children: [
                  // ==================== أزرار الجلسات ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: sessions.map((session) {
                        final isSelected = _selectedSessionId == session.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSessionId = session.id;
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 48) / 2,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? LinearGradient(colors: [session.color, session.color.withOpacity(0.7)]) : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? session.color : Colors.grey.shade300, width: isSelected ? 0 : 1.5),
                              boxShadow: [BoxShadow(color: isSelected ? session.color.withOpacity(0.3) : Colors.grey.withOpacity(0.1), blurRadius: 6)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(session.icon, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(
                                  session.title,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${session.courses.length} courses',
                                  style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== عنوان القسم ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSessionId.isNotEmpty && sessions.isNotEmpty
                                ? sessions.firstWhere((s) => s.id == _selectedSessionId).title
                                : '',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${_filteredCourses.length} courses',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== قائمة الكورسات ====================
                  _filteredCourses.isEmpty
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
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) => _buildCourseCard(_filteredCourses[index]),
                  ),
                ],
              ),

            if (_searchQuery.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _filteredSessionsAndCourses.length,
                itemBuilder: (context, index) {
                  final entry = _filteredSessionsAndCourses[index];
                  final session = entry.key;
                  final matchingCourses = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Text(session.icon, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(session.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                              child: Text('${matchingCourses.length} courses', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                      ...matchingCourses.map((course) => _buildCourseCard(course)).toList(),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== بطاقة الكورس ====================
  Widget _buildCourseCard(CourseModel course) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CurriculumPage(course: course))),
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
                  decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.menu_book, color: Colors.deepPurple, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(course.trainer, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.deepPurple),
                      const SizedBox(width: 4),
                      Text(course.hours, style: const TextStyle(fontSize: 11, color: Colors.deepPurple)),
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
                Text('${course.curriculum.length} lessons', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// صفحة المنهاج (Curriculum Page)
// ============================================================
class CurriculumPage extends StatelessWidget {
  final CourseModel course;

  const CurriculumPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.menu_book, color: Colors.deepPurple, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Trainer: ${course.trainer}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: course.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.deepPurple,
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${course.progress}% Complete', style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
                    Text('${course.curriculum.length} Lessons', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: course.curriculum.length,
              itemBuilder: (context, index) {
                final lesson = course.curriculum[index];
                return _buildLessonCard(lesson, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: lesson.isCompleted
                ? Colors.green.withOpacity(0.1)
                : (lesson.type == 'video' ? Colors.deepPurple.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: lesson.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                : Icon(
              lesson.type == 'video' ? Icons.play_arrow : Icons.picture_as_pdf,
              color: lesson.type == 'video' ? Colors.deepPurple : Colors.orange,
              size: 24,
            ),
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: lesson.isCompleted ? FontWeight.normal : FontWeight.w500,
            color: lesson.isCompleted ? Colors.grey[600] : Colors.black87,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.access_time, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(lesson.duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: lesson.isCompleted
            ? const Icon(Icons.play_circle_outline, color: Colors.grey)
            : ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: lesson.type == 'video' ? Colors.deepPurple : Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(lesson.type == 'video' ? 'Watch' : 'View'),
        ),
      ),
    );
  }
}