import 'package:flutter/material.dart';
import 'payment_page.dart';
import '../../models/course_models.dart';

class RegisterCoursesPage extends StatefulWidget {
  final Function(List<CourseItem>)? onRegister;
  final Function(String)? onUnregister;
  final List<String>? registeredCourseIds;

  const RegisterCoursesPage({
    super.key,
    this.onRegister,
    this.onUnregister,
    this.registeredCourseIds,
  });

  @override
  State<RegisterCoursesPage> createState() => _RegisterCoursesPageState();
}

class _RegisterCoursesPageState extends State<RegisterCoursesPage> {
  List<CourseItem> availableCourses = [];
  List<String> registeredIds = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    if (widget.registeredCourseIds != null) {
      registeredIds = List.from(widget.registeredCourseIds!);
    }
  }

  void _loadCourses() {
    availableCourses = [
      CourseItem(
        id: 'course_1',
        title: 'Fashion Design Fundamentals',
        description: 'Learn the fundamentals of fashion design from scratch',
        levelNumber: 1,
        price: '99.00',
        totalHours: '8 hours',
        trainerName: 'Sarah Johnson',
        sessions: [
          Session(
            id: 's1',
            title: 'Introduction to Fashion Design',
            description: 'Learn the basics of fashion design',
            curriculum: [
              Lesson(id: 'l1', title: 'What is Fashion Design?', duration: '15 min', type: 'video', url: ''),
              Lesson(id: 'l2', title: 'History of Fashion', duration: '20 min', type: 'video', url: ''),
              Lesson(id: 'l3', title: 'Career Paths', duration: '10 min', type: 'pdf', url: ''),
            ],
          ),
          Session(
            id: 's2',
            title: 'Fashion Drawing Basics',
            description: 'Learn fundamental drawing techniques',
            curriculum: [
              Lesson(id: 'l4', title: 'Tools and Materials', duration: '15 min', type: 'video', url: ''),
              Lesson(id: 'l5', title: 'Croquis Drawing', duration: '30 min', type: 'video', url: ''),
            ],
          ),
          Session(
            id: 's3',
            title: 'Color Theory in Fashion',
            description: 'Understanding color combinations',
            curriculum: [
              Lesson(id: 'l6', title: 'Color Wheel Basics', duration: '20 min', type: 'video', url: ''),
              Lesson(id: 'l7', title: 'Color Harmonies', duration: '25 min', type: 'pdf', url: ''),
            ],
          ),
        ],
        isRegistered: false,
      ),
      CourseItem(
        id: 'course_2',
        title: 'Fabric & Garment Construction',
        description: 'Master fabrics and garment construction techniques',
        levelNumber: 2,
        price: '129.00',
        totalHours: '10 hours',
        trainerName: 'Maria Gonzalez',
        sessions: [
          Session(
            id: 's4',
            title: 'Fabric and Textiles',
            description: 'Learn about different types of fabrics',
            curriculum: [
              Lesson(id: 'l8', title: 'Natural Fabrics', duration: '20 min', type: 'video', url: ''),
              Lesson(id: 'l9', title: 'Synthetic Fabrics', duration: '20 min', type: 'video', url: ''),
            ],
          ),
          Session(
            id: 's5',
            title: 'Garment Construction',
            description: 'Basic techniques for constructing garments',
            curriculum: [
              Lesson(id: 'l10', title: 'Pattern Making', duration: '35 min', type: 'video', url: ''),
              Lesson(id: 'l11', title: 'Sewing Basics', duration: '30 min', type: 'video', url: ''),
            ],
          ),
        ],
        isRegistered: false,
      ),
      CourseItem(
        id: 'course_3',
        title: 'Advanced Fashion Illustration',
        description: 'Take your fashion illustration skills to the next level',
        levelNumber: 3,
        price: '149.00',
        totalHours: '12 hours',
        trainerName: 'Emma Watson',
        sessions: [
          Session(
            id: 's6',
            title: 'Fashion Illustration',
            description: 'Advanced techniques for fashion illustration',
            curriculum: [
              Lesson(id: 'l12', title: 'Proportions and Poses', duration: '25 min', type: 'video', url: ''),
              Lesson(id: 'l13', title: 'Facial Features', duration: '20 min', type: 'video', url: ''),
            ],
          ),
          Session(
            id: 's7',
            title: 'Digital Fashion Design',
            description: 'Using digital tools for fashion design',
            curriculum: [
              Lesson(id: 'l14', title: 'Adobe Illustrator', duration: '40 min', type: 'video', url: ''),
              Lesson(id: 'l15', title: 'Procreate Basics', duration: '35 min', type: 'video', url: ''),
            ],
          ),
        ],
        isRegistered: false,
      ),
    ];
  }

  bool _isCourseRegistered(String courseId) {
    return registeredIds.contains(courseId);
  }

  void _unregisterCourse(CourseItem course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unregister Course'),
        content: Text('Are you sure you want to unregister from "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unregister'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        registeredIds.remove(course.id);
      });

      if (widget.onUnregister != null) {
        widget.onUnregister!(course.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unregistered from "${course.title}" successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _proceedToPayment(CourseItem course) {
    if (_isCourseRegistered(course.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already registered for this course!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          course: course,
          onPaymentSuccess: () {
            setState(() {
              registeredIds.add(course.id);
            });
            if (widget.onRegister != null) {
              widget.onRegister!([course]);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course registered successfully!'), backgroundColor: Colors.green),
            );
          },
        ),
      ),
    );
  }

  void _showCourseDetails(CourseItem course) {
    final isRegistered = _isCourseRegistered(course.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.style, size: 32, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text('Level ${course.levelNumber} • ${course.totalHours}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('\$${course.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Instructor: ${course.trainerName}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(course.description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const Divider(height: 24),
                    const Text('Course Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...course.sessions.map((session) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.playlist_play, size: 20, color: Colors.deepPurple),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(session.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                Text(session.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          isRegistered
                              ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.check, size: 16, color: Colors.green),
                          )
                              : Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.lock, size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )).toList(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isRegistered ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(isRegistered ? Icons.check_circle : Icons.info_outline, size: 14, color: isRegistered ? Colors.green : Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isRegistered ? 'You are already enrolled in this course' : 'Course content will be available after registration',
                              style: TextStyle(fontSize: 11, color: isRegistered ? Colors.green : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isRegistered)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _unregisterCourse(course);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Unregister Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _proceedToPayment(course);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Register Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Fashion Design Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple])),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableCourses.length,
        itemBuilder: (context, index) => _buildCourseCard(availableCourses[index]),
      ),
    );
  }

  Widget _buildCourseCard(CourseItem course) {
    final isRegistered = _isCourseRegistered(course.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,  // ✅ دائمًا أبيض
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ رأس البطاقة (بدون تغيير اللون)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]), // ✅ دائمًا بنفسجي
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.style, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(course.description, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)), maxLines: 2),
                    ],
                  ),
                ),
                // ✅ الزر فقط يتغير لونه
                if (isRegistered)
                  GestureDetector(
                    onTap: () => _unregisterCourse(course),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,  // ✅ فقط الزر أخضر
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Enrolled', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _proceedToPayment(course),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                      child: const Text('Register', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ),
                  ),
              ],
            ),
          ),
          // معلومات الكورس (بدون تغيير)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(child: Text(course.trainerName, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                const SizedBox(width: 12),
                Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text('Level ${course.levelNumber}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(course.totalHours, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          // أسفل البطاقة (بدون تغيير)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 4),
                    Text(
                      '${course.sessions.length} sessions',
                      style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showCourseDetails(course),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Preview', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}