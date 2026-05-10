// 📄 lib/screens/trainer/trainer_courses_main_page.dart
import 'package:flutter/material.dart';
import '../../models/course_models.dart';  // ✅ استيراد النماذج الموجودة
import 'trainer_curriculum_page.dart';

// ============================================================
// نموذج التصنيف (Category) - نعرفه هنا لأن غير موجود في المودل
// ============================================================
class CategoryModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final List<CourseItem> courses;  // ✅ استخدام CourseItem من المودل

  CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.courses,
  });
}

// ============================================================
// صفحة كورسات المدرب الرئيسية
// ============================================================

class TrainerCoursesMainPage extends StatefulWidget {
  final String? selectedCategoryId;
  final List<CategoryModel>? registeredCategories;
  final String? selectedCourseId;

  const TrainerCoursesMainPage({
    super.key,
    this.selectedCategoryId,
    this.registeredCategories,
    this.selectedCourseId,
  });

  @override
  State<TrainerCoursesMainPage> createState() => _TrainerCoursesMainPageState();
}

class _TrainerCoursesMainPageState extends State<TrainerCoursesMainPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = '';
  List<CategoryModel> categories = [];

  // ✅ بيانات تجريبية باستخدام CourseItem و Session و Lesson
  // ✅ بيانات تجريبية باستخدام CourseItem و Session و Lesson
  // ✅ بيانات تجريبية (بدون استخدام curriculum مباشرة)
  final List<CategoryModel> _sampleCategories = [
    CategoryModel(
      id: '1',
      title: 'Fashion Illustration',
      description: 'Learn fashion illustration basics',
      icon: '🎨',
      color: Colors.deepPurple,
      courses: [
        CourseItem(
          id: 'c1',
          title: 'Fashion Illustration',
          description: 'Complete fashion illustration course',
          levelNumber: 1,
          courseType: 'Practical',
          toolsRequired: 'Pencil, paper',
          trainerProfile: 1,
          price: 'Free',
          totalHours: '12h',
          trainerName: 'Emma Watson',
          studentsCount: 45,
          sessions: [],  // ✅ فارغ مؤقتاً
          isRegistered: true,
          progress: 75,
        ),
        CourseItem(
          id: 'c2',
          title: 'Digital Fashion Design',
          description: 'Digital design techniques',
          levelNumber: 2,
          courseType: 'Practical',
          toolsRequired: 'Tablet, software',
          trainerProfile: 1,
          price: '99 SAR',
          totalHours: '10h',
          trainerName: 'Sarah Johnson',
          studentsCount: 32,
          sessions: [],
          isRegistered: false,
          progress: 0,
        ),
      ],
    ),
    CategoryModel(
      id: '2',
      title: 'Advanced Fashion Illustration',
      description: 'Master advanced techniques',
      icon: '👗',
      color: Colors.orange,
      courses: [
        CourseItem(
          id: 'c3',
          title: 'Advanced Fashion Illustration',
          description: 'Take your skills to next level',
          levelNumber: 3,
          courseType: 'Theory',
          toolsRequired: 'Sketchbook, pencils',
          trainerProfile: 1,
          price: '149 SAR',
          totalHours: '15h',
          trainerName: 'Emma Watson',
          studentsCount: 38,
          sessions: [],
          isRegistered: false,
          progress: 0,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.registeredCategories != null && widget.registeredCategories!.isNotEmpty) {
      categories = widget.registeredCategories!;
      if (widget.selectedCategoryId != null) {
        _selectedCategoryId = widget.selectedCategoryId!;
      } else {
        _selectedCategoryId = categories.first.id;
      }
    } else {
      categories = _sampleCategories;
      if (widget.selectedCategoryId != null) {
        _selectedCategoryId = widget.selectedCategoryId!;
      } else {
        _selectedCategoryId = categories.first.id;
      }
    }
  }

  List<MapEntry<CategoryModel, List<CourseItem>>> get _filteredCategoriesAndCourses {
    if (_searchQuery.isEmpty) {
      return categories.expand((category) {
        return [MapEntry(category, category.courses)];
      }).toList();
    }

    final results = <MapEntry<CategoryModel, List<CourseItem>>>[];
    for (var category in categories) {
      final categoryMatches = category.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchingCourses = category.courses.where((course) {
        return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.trainerName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      if (categoryMatches || matchingCourses.isNotEmpty) {
        results.add(MapEntry(category, categoryMatches ? category.courses : matchingCourses));
      }
    }
    return results;
  }

  int get _totalResultsCount {
    if (_searchQuery.isEmpty) return categories.fold(0, (sum, category) => sum + category.courses.length);
    int count = 0;
    for (var entry in _filteredCategoriesAndCourses) {
      count += entry.value.length;
    }
    return count;
  }

  List<CourseItem> get _filteredCourses {
    if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    try {
      final selectedCategory = categories.firstWhere((c) => c.id == _selectedCategoryId);
      var courses = List<CourseItem>.from(selectedCategory.courses);
      if (_searchQuery.isNotEmpty) {
        courses = courses.where((course) {
          return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              course.trainerName.toLowerCase().contains(_searchQuery.toLowerCase());
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
      body: categories.isEmpty
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

            if (_searchQuery.isEmpty && categories.isNotEmpty)
              Column(
                children: [
                  // أزرار التصنيفات
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categories.map((category) {
                        final isSelected = _selectedCategoryId == category.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategoryId = category.id;
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 48) / 2,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? LinearGradient(colors: [category.color, category.color.withOpacity(0.7)]) : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? category.color : Colors.grey.shade300, width: isSelected ? 0 : 1.5),
                              boxShadow: [BoxShadow(color: isSelected ? category.color.withOpacity(0.3) : Colors.grey.withOpacity(0.1), blurRadius: 6)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(category.icon, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(
                                  category.title,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${category.courses.length} courses',
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

                  // عنوان القسم
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCategoryId.isNotEmpty && categories.isNotEmpty
                                ? categories.firstWhere((c) => c.id == _selectedCategoryId).title
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

                  // قائمة الكورسات
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
                itemCount: _filteredCategoriesAndCourses.length,
                itemBuilder: (context, index) {
                  final entry = _filteredCategoriesAndCourses[index];
                  final category = entry.key;
                  final matchingCourses = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Text(category.icon, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(category.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
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

  // ✅ بطاقة الكورس
  Widget _buildCourseCard(CourseItem course) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrainerCurriculumPage(course: course)),
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
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(course.trainerName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
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
            const SizedBox(height: 12),
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
                Text('${course.sessions.length} sessions', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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

class TrainerCurriculumPage extends StatelessWidget {
  final CourseItem course;

  const TrainerCurriculumPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  course.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Trainer: ${course.trainerName}',
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
                          Text(course.totalHours, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                            '${course.progress}%',
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

          // قائمة الدروس
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: course.sessions.length,
              itemBuilder: (context, index) {
                final session = course.sessions[index];
                return ExpansionTile(
                  title: Text(
                    session.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(session.description),
                  children: session.curriculum.map((lesson) {
                    return _buildLessonCard(lesson);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    final isVideo = lesson.type == 'video';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isVideo
                  ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                  : const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isVideo ? Icons.play_arrow : Icons.picture_as_pdf,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      lesson.duration,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVideo ? Colors.deepPurple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lesson.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isVideo ? Colors.deepPurple : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isVideo
                  ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                  : const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isVideo ? 'Watch' : 'View PDF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}