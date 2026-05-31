// 📄 lib/screens/trainee/register_courses_page.dart
// ============================================================
// 📝 صفحة تسجيل الكورسات (Register Courses Page)
// ✅ بدون زر Unregister - بعد الدفع لا يمكن إلغاء التسجيل
// ✅ الكورسات غير المسجلة محتواها مقفول
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_page.dart';
import 'content_viewer_page.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';
import '../../bloc/course/course_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../models/user_model.dart';
import '../../models/course_models.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/chat_repository.dart';

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
  bool _isLoading = true;
  bool _isProcessing = false;

  String? _expandedCourseId;
  int? _expandedSessionId;

  final Map<String, List<Session>> _cachedSessions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (widget.registeredCourseIds != null) {
      registeredIds = List.from(widget.registeredCourseIds!);
    }

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final repo = CourseRepository();

      final registeredCourses =
      await repo.loadRegisteredCourses(authState.user.id);

      registeredIds = registeredCourses.map((c) => c.id).toList();

      context.read<CourseBloc>().add(
        LoadAvailableCoursesEvent(
          userId: authState.user.id,
          userType: authState.user.userType,
        ),
      );
    }
  }

  bool _isCourseRegistered(String courseId) {
    return registeredIds.contains(courseId);
  }

  void _proceedToPayment(CourseItem course) {
    if (_isCourseRegistered(course.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already registered for this course!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_isProcessing) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          course: course,
          onPaymentSuccess: () async {
            try {
              final chatRepo = ChatRepository();
              final result = await chatRepo.createConversationForTrainee(
                int.parse(course.id),
              );
              print("💬 CREATE CONVERSATION RESULT: $result");
            } catch (e) {
              print("❌ CREATE CONVERSATION ERROR: $e");
            }

            // ✅ FIX 1: Refresh from backend instead of relying on local state only
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              // Reload available courses from backend to get updated registration status
              context.read<CourseBloc>().add(
                LoadAvailableCoursesEvent(
                  userId: authState.user.id,
                  userType: authState.user.userType,
                ),
              );

              // Also reload registered courses to ensure consistency
              final repo = CourseRepository();
              final updatedRegisteredCourses = await repo.loadRegisteredCourses(authState.user.id);
              setState(() {
                registeredIds = updatedRegisteredCourses.map((c) => c.id).toList();
              });
            }

            // Update local state as fallback
            setState(() {
              if (!registeredIds.contains(course.id)) {
                registeredIds.add(course.id);
              }
              final index = availableCourses.indexWhere((c) => c.id == course.id);
              if (index != -1) {
                availableCourses[index] = availableCourses[index].copyWith(
                  isRegistered: true,
                );
              }
            });

            if (widget.onRegister != null) {
              widget.onRegister!([course]);
            }

            if (authState is AuthAuthenticated) {
              context.read<ChatBloc>().add(
                LoadConversationsEvent(
                  userId: authState.user.id,
                  userType: UserType.trainee,
                ),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course registered successfully! 🎉'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _toggleCourseExpansion(String courseId) {
    final isRegistered = _isCourseRegistered(courseId);
    if (!isRegistered) return;

    setState(() {
      if (_expandedCourseId == courseId) {
        _expandedCourseId = null;
        _expandedSessionId = null;
      } else {
        _expandedCourseId = courseId;
        _expandedSessionId = null;
      }
    });
  }

  void _toggleSessionExpansion(int sessionId) {
    setState(() {
      if (_expandedSessionId == sessionId) {
        _expandedSessionId = null;
      } else {
        _expandedSessionId = sessionId;
      }
    });
  }

  Future<List<Session>> _fetchSessions(String courseId) async {
    try {
      return await CourseRepository().getCourseSessions(courseId);
    } catch (e) {
      print('❌ Error fetching sessions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Available Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is AvailableCoursesLoaded && !_isProcessing) {
            setState(() {
              availableCourses = state.availableCourses;
              for (var course in availableCourses) {
                if (course.isRegistered) {
                  registeredIds = availableCourses
                      .where((c) => c.isRegistered)
                      .map((c) => c.id)
                      .toList();
                }
              }
              _isLoading = false;
            });
          } else if (state is CourseError) {
            setState(() => _isLoading = false);
            final isAutoLoadError = state.message.toLowerCase().contains('load');
            if (!isAutoLoadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          } else if (state is CourseLoading) {
            setState(() => _isLoading = true);
          }
        },
        child: _isLoading
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading courses...'),
        ]))
            : availableCourses.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No courses available', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ]))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: availableCourses.length,
          itemBuilder: (context, index) {
            if (index == availableCourses.length - 1) {
              return Column(
                children: [
                  _buildCourseCard(availableCourses[index]),
                  const SizedBox(height: 80),
                ],
              );
            }
            return _buildCourseCard(availableCourses[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseItem course) {
    final isRegistered = _isCourseRegistered(course.id);
    final isExpanded = _expandedCourseId == course.id;

    return Container(
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.style, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        course.description,
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isRegistered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Registered', style: TextStyle(fontSize: 11, color: Colors.white)),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _proceedToPayment(course),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Basic info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        course.trainerName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bar_chart, size: 12, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text(
                            'Level ${course.levelNumber}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.deepPurple),
                          const SizedBox(width: 6),
                          Text(
                            course.courseType,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_money, size: 12, color: Colors.green),
                          const SizedBox(width: 2),
                          Text(
                            '${course.price}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (course.toolsRequired.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.build, size: 16, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tools: ${course.toolsRequired}',
                            style: const TextStyle(fontSize: 11, color: Colors.teal),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isRegistered)
                      TextButton.icon(
                        onPressed: () => _toggleCourseExpansion(course.id),
                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.deepPurple),
                        label: Text(
                          isExpanded ? 'Hide Sessions' : 'View Sessions',
                          style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor: Colors.deepPurple.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              'Register to access content',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded sessions - only for registered courses
          if (isExpanded && isRegistered) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.video_library, size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  const Text(
                    'Course Sessions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Session>>(
              future: _cachedSessions.containsKey(course.id)
                  ? Future.value(_cachedSessions[course.id])
                  : _fetchSessions(course.id),
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
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No sessions available for this course',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                final sessions = snapshot.data!;
                if (!_cachedSessions.containsKey(course.id)) {
                  _cachedSessions[course.id] = sessions;
                }
                return Column(
                  children: sessions.map((session) => _buildSessionTile(session, course)).toList(),
                );
              },
            ),
          ],

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(Session session, CourseItem course) {
    final isSessionExpanded = _expandedSessionId == session.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        key: ValueKey(session.id),
        leading: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_circle_outline, size: 18, color: Colors.white),
        ),
        title: Text(
          'Session ${session.sessionOrder ?? 0}: ${session.title}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          session.description.isNotEmpty ? session.description : 'No description',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        initiallyExpanded: isSessionExpanded,
        onExpansionChanged: (expanded) {
          if (expanded) {
            setState(() {
              _expandedSessionId = session.id;
            });
          }
        },
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📚 Course Content',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 12),
                if (session.contents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No content available for this session yet',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                else
                  ...session.contents.map((content) => _buildContentTile(content)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTile(CourseContent content) {
    IconData icon;
    Color color;
    switch (content.contentType.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'video':
        icon = Icons.video_library;
        color = Colors.blue;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${content.contentType} • Part ${content.contentOrder}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18, color: Colors.deepPurple),
            onPressed: () {
              if (content.hasFile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentViewerPage(content: content),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No file available for this content'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}