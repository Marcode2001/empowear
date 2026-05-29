// 📄 lib/screens/trainee/trainee_home_screen.dart
// ============================================================
// 🏠 الشاشة الرئيسية للطالب - النسخة الكاملة
// ============================================================
// الوظيفة:
// - تعرض واجهة الطالب الرئيسية مع شريط تنقل سفلي (Bottom Navigation)
// - تحتوي على 4 صفحات فرعية: Home, AI Tools, Chat, Profile
// - صفحة "الرئيسية" تعرض: بطاقة ترحيب، أزرار خدمات سريعة، قائمة الكورسات المسجل فيها
// - تتفاعل مع AuthBloc لعرض اسم المستخدم، و CourseBloc لعرض الكورسات

// 📦 استيراد المكتبات الأساسية
import 'package:flutter/material.dart';           // مكتبة فلاتر الأساسية
import 'package:flutter_bloc/flutter_bloc.dart';  // مكتبة إدارة الحالة (BLoC)

// 🧠 استيراد الـ BLoCs اللازمة
import '../../bloc/auth/auth_bloc.dart';          // BLoC المصادقة (تسجيل دخول/خروج)
import '../../bloc/course/course_bloc.dart';      // BLoC الكورسات (جلب، تسجيل، إلخ)
import '../../bloc/course/course_event.dart';     // أحداث الكورسات
import '../../bloc/course/course_state.dart';     // حالات الكورسات

// 📦 استيراد نماذج البيانات
import '../../models/course_models.dart';         // نموذج بيانات الكورس (CourseItem)

// 🖼️ استيراد الصفحات الفرعية للتنقل بينها
import 'my_courses_page.dart';           // صفحة عرض تفاصيل الكورسات المسجل فيها
import 'job_opportunities_page.dart';    // صفحة فرص العمل
import 'ai_tools.dart';                  // صفحة أدوات الذكاء الاصطناعي
import 'chat_page.dart';                 // صفحة المحادثات
import 'profile_page.dart';              // صفحة البروفايل الشخصي
import 'students_projects_page.dart';    // صفحة مشاريع الطلاب
import 'uploaded_projects_page.dart';    // صفحة رفع المشاريع
import 'register_courses_page.dart';     // صفحة تسجيل كورسات جديدة (اللي برمنّاها فوق)

// ============================================================
// 🏗️ كلاس الشاشة الرئيسية (TraineeHomeScreen)
// ============================================================
// هذا الكلاس يمثل "القالب" الخارجي للشاشة الرئيسية، ويدير التنقل بين الصفحات الفرعية
class TraineeHomeScreen extends StatefulWidget {
  const TraineeHomeScreen({super.key});  // constructor قياسي بدون بارامترات

  @override
  // ✅ نعود بحالة الشاشة (المنطق الداخلي)
  State<TraineeHomeScreen> createState() => _TraineeHomeScreenState();
}

// ============================================================
// 🧠 كلاس حالة الشاشة الرئيسية (المنطق الداخلي)
// ============================================================
class _TraineeHomeScreenState extends State<TraineeHomeScreen> {
  // 📊 متغير لتتبع الصفحة المختارة حالياً في شريط التنقل السفلي
  // 0 = Home, 1 = AI Tools, 2 = Chat, 3 = Profile
  int _selectedIndex = 0;

  // 📱 قائمة الصفحات التي سيتم عرضها عند تغيير التبويب
  // كل عنصر في القائمة هو ويدجت يمثل صفحة كاملة
  final List<Widget> _screens = [
    const HomePage(),        // الصفحة الرئيسية (تعرض الكورسات والخدمات)
    const AiToolsPage(),     // صفحة أدوات الذكاء الاصطناعي
    const ChatsListPage(),   // صفحة المحادثات مع المدربين
    const ProfilePage(),     // صفحة البروفايل الشخصي للطالب
  ];

  // 🏷️ قائمة عناوين الصفحات (تظهر في الـ AppBar عند تغيير التبويب)
  final List<String> _titles = [
    'Home',
    'AI Tools',
    'Chats',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 شريط العنوان العلوي (AppBar) - يتغير حسب الصفحة المختارة
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],  // العنوان يتغير ديناميكياً حسب _selectedIndex
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,  // توسيط العنوان
        elevation: 0,  // إزالة الظل تحت الأبار لمظهر أنظف
        flexibleSpace: Container(
          // 🌈 خلفية متدرجة (جراديانت) للأبار
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],  // من بنفسجي غامق لفاتح
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // 🖼️ جسم الشاشة: يعرض الصفحة المختارة من القائمة _screens
      // عندما يتغير _selectedIndex، فلاتر يعيد بناء هذا الجزء ويعرض الصفحة الجديدة
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // 🧭 شريط التنقل السفلي (BottomNavigationBar)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // ثابت لعرض 4 عناصر (بدون انكماش)
        currentIndex: _selectedIndex,  // العنصر النشط حالياً (يتغير عند الضغط)
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // 🧠 إعادة تحميل الكورسات كل مرة نرجع فيها للهوم
          if (index == 0) {
            final authState = context.read<AuthBloc>().state;

            if (authState is AuthAuthenticated) {
              context.read<CourseBloc>().add(
                LoadRegisteredCoursesEvent(
                  userId: authState.user.id,
                  userType: authState.user.userType,
                ),
              );
            }
          }
        },
        selectedItemColor: Colors.deepPurple,  // لون العنصر النشط (أيقونة + نص)
        unselectedItemColor: Colors.grey,      // لون العناصر غير النشطة
        items: const [
          // كل عنصر يحتوي على أيقونة وتسمية
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ============================================================
// 🏠 كلاس الصفحة الرئيسية داخل الشاشة (HomePage)
// ============================================================
// هذه هي الصفحة التي تظهر عند اختيار "Home" من شريط التنقل
// تعرض: بطاقة ترحيب، أزرار خدمات سريعة، قائمة الكورسات المسجل فيها
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CourseItem> _cachedCourses = [];
  // ✅ ملاحظة هامة: ما نحتاج متغير محلي للكورسات هنا
  // لأننا بنستخدم الـ State مباشرة من CourseBloc عبر BlocBuilder

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ نجيب حالة المستخدم الحالية
    final authState = context.read<AuthBloc>().state;

    // ✅ نجيب حالة الكورسات الحالية
    final courseState = context.read<CourseBloc>().state;

    // ✅ إذا المستخدم مسجل دخول
    // والكورسات لسا مو محملة
    if (authState is AuthAuthenticated &&
        courseState is! RegisteredCoursesLoaded &&
        courseState is! CourseLoading) {

      print('🚀 HOME PAGE → Loading registered courses...');

      context.read<CourseBloc>().add(
        LoadRegisteredCoursesEvent(
          userId: authState.user.id,
          userType: authState.user.userType,
        ),
      );
    }
  }

  // ============================================================
  // 📝 دالة إضافة كورس مسجل (تُستدعى من صفحة RegisterCoursesPage)
  // ============================================================
  // هذه الدالة بتنادى لما الطالب يسجل في كورس جديد من صفحة التسجيل
  // وظيفتها: تحديث قائمة الكورسات في الصفحة الرئيسية فوراً
  bool _isRegistering = false;

  void _addRegisteredCourse(CourseItem course) {
    if (_isRegistering) return;

    _isRegistering = true;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CourseBloc>().add(
        RegisterCourseEvent(
          course: course,
          userId: authState.user.id,
          userType: authState.user.userType,
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isRegistering = false;
    });
  }

  // ============================================================
  // 🗑️ دالة إلغاء تسجيل كورس
  // ============================================================
  // هذه الدالة بتنادى لما الطالب يلغي تسجيله من كورس
  void _unregisterCourse(String courseId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // 🚀 نرسل حدث إلغاء التسجيل للـ BLoC
      // الـ BLoC رح يتصل بالباك إند ويحذف طلب التسجيل
      context.read<CourseBloc>().add(
        UnregisterCourseEvent(
          courseId: courseId,
          userId: authState.user.id,
          userType: authState.user.userType,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👂 نستمع لحالة المصادقة لعرض اسم المستخدم في بطاقة الترحيب
    // watch يعني: إذا تغيرت الحالة، فلاتر رح يعيد بناء هذا الجزء تلقائياً
    final authState = context.watch<AuthBloc>().state;
    String userName = 'Student';  // قيمة افتراضية إذا ما في اسم
    if (authState is AuthAuthenticated) {
      userName = authState.user.name;  // نأخذ الاسم الحقيقي من بيانات المستخدم
    }

    // 👂 نستمع لحالة CourseBloc لعرض الكورسات
    // BlocBuilder: يعيد بناء الواجهة كلما تغيرت حالة الـ BLoC
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, courseState) {

        // ✅ استخراج قائمة الكورسات من الـ State مباشرة
        // إذا كانت الحالة RegisteredCoursesLoaded، نأخذ القائمة، وإلا نأخذ قائمة فاضية
        /// ✅ منع اختفاء الكورسات عند أي rebuild أو loading
        List<CourseItem> registeredCourses = [];

        /// ✅ إذا وصلت بيانات جديدة نخزنها
        if (courseState is RegisteredCoursesLoaded) {
          registeredCourses = courseState.registeredCourses;
          _cachedCourses = registeredCourses;
        } else {
          registeredCourses = _cachedCourses;
        }  // قائمة فاضية إذا الحالة مو ناجحة بعد

        return SingleChildScrollView(  // 📜 للسماح بالتمرير إذا المحتوى أطول من الشاشة
          padding: const EdgeInsets.all(16),  // هوامش داخلية حول كل المحتوى
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // محاذاة العناصر لليسار
            children: [

              // ============================================================
              // 🎴 1. بطاقة الترحيب (Welcome Card)
              // ============================================================
              Container(
                padding: const EdgeInsets.all(20),  // هوامش داخلية للبطاقة
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],  // خلفية متدرجة
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),  // حواف دائرية
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // توزيع العناصر: نص يمين، أيقونة يسار
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  // محاذاة النصوص لليسار
                      children: [
                        const Text('Welcome 👋',  // ترحيب
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),  // مسافة بين الترحيب والاسم
                        // عرض اسم المستخدم (ديناميكي)
                        Text(userName,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        // شارة المستوى (Level Badge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),  // خلفية شبه شفافة
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Level 3', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    // أيقونة المدرسة في دائرة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,  // شكل دائري
                      ),
                      child: const Icon(Icons.school, color: Colors.white, size: 50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),  // مسافة كبيرة بعد بطاقة الترحيب

              // ============================================================
              // 🔲 2. مربعات الخدمات السريعة (4 أزرار)
              // ============================================================
              // الصف الأول: فرص عمل + مشاريع الطلاب
              Row(
                children: [
                  Expanded(  // نأخذ نصف العرض
                    child: _buildSquareCard(
                      context,
                      title: 'Job\nOpportunities',  // عنوان الزر (يدعم سطور متعددة بـ \n)
                      icon: Icons.work,  // أيقونة الوظيفة
                      color: Colors.orange,  // لون الزر
                      onTap: () {
                        // ✅ عند الضغط: ننتقل لصفحة فرص العمل
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const JobOpportunitiesPage()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),  // مسافة بين الزرين
                  Expanded(
                    child: _buildSquareCard(
                      context,
                      title: 'Students\nProject',
                      icon: Icons.folder,
                      color: Colors.blue,
                      onTap: () {
                        // ✅ عند الضغط: ننتقل لصفحة مشاريع الطلاب
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentsProjectsPage()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),  // مسافة بين الصفين

              // الصف الثاني: رفع مشروع + تسجيل كورس
              Row(
                children: [
                  Expanded(
                    child: _buildSquareCard(
                      context,
                      title: 'Upload\nProject',
                      icon: Icons.upload_file,
                      color: Colors.teal,
                      onTap: () {
                        // ✅ عند الضغط: ننتقل لصفحة رفع المشروع
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UploadProjectPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSquareCard(
                      context,
                      title: 'Register\nCourse',
                      icon: Icons.add_circle,
                      color: Colors.deepPurple,
                      onTap: () {
                        // 🚀 الانتقال لصفحة تسجيل الكورسات
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterCoursesPage(
                              // ✅ عند التسجيل الناجح، نضيف الكورسات للقائمة في الصفحة الرئيسية
                              onRegister: (courses) {
                                for (var course in courses) {
                                  _addRegisteredCourse(course);  // ننادي الدالة عشان تحدث الـ BLoC
                                }
                              },
                              // ✅ عند إلغاء التسجيل، نحدث الصفحة الرئيسية
                              onUnregister: _unregisterCourse,
                              // ✅ نمرر قائمة الكورسات المسجل فيها عشان نعرف شو نعرض في صفحة التسجيل
                              registeredCourseIds: registeredCourses.map((c) => c.id).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),  // مسافة كبيرة بعد أزرار الخدمات

              // ============================================================
              // 📚 3. قسم "مسارات التعلم" مع زر "عرض الكل"
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  // عنوان يمين، زر يسار
                children: [
                  const Text('My Learning Tracks',  // عنوان القسم
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  // زر "عرض الكل" يظهر فقط إذا في كورسات مسجل فيها
                  if (registeredCourses.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        // 🚀 الانتقال لصفحة الكورسات مع تمرير القائمة كاملة
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyCoursesPage(courses: registeredCourses),
                          ),
                        );
                      },
                      child: const Text('See All',  // نص الزر
                          style: TextStyle(color: Colors.deepPurple, fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
              const SizedBox(height: 12),  // مسافة تحت العنوان

              // ============================================================
              // 📋 4. قائمة الكورسات المسجل فيها
              // ============================================================

              // 🟡 حالة: جاري التحميل (ننتظر البيانات من الباك إند)
              if (courseState is CourseLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),  // دائرة التحميل الدوارة
                  ),
                )

              // 🔴 حالة: خطأ أثناء جلب البيانات
              else if (courseState is CourseError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      courseState.message,  // نعرض رسالة الخطأ القادمة من الـ BLoC
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )

              // ⚪ حالة: لا توجد كورسات مسجل فيها (قائمة فاضية)
              else if (registeredCourses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,  // خلفية فاتحة
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),  // حدود خفيفة
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined, size: 60, color: Colors.grey),  // أيقونة مدرسة
                        const SizedBox(height: 12),
                        const Text('No learning tracks yet',  // رسالة تشجيع
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap "Register Course" to start learning',  // توجيه للمستخدم
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  )

                // ✅ حالة: عرض قائمة الكورسات (البيانات جاهزة)
                else
                  ListView.builder(
                    shrinkWrap: true,  // لجعل الـ ListView يأخذ مساحة محتواه فقط (مهم داخل SingleChildScrollView)
                    physics: const NeverScrollableScrollPhysics(),  // منع التمرير الداخلي لأن الأب Scrollable
                    itemCount: registeredCourses.length,  // عدد الكورسات للعرض
                    itemBuilder: (context, index) {
                      final course = registeredCourses[index];  // الكورس الحالي في التكرار
                      return _buildCourseCard(course);  // ننادي دالة بناء بطاقة الكورس
                    },
                  ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 🎴 دالة مساعدة: بناء بطاقة كورس واحد في القائمة
  // ============================================================
  Widget _buildCourseCard(CourseItem course) {
    return GestureDetector(
      onTap: () {
        // ✅ عند الضغط على الكورس، ننتقل لصفحته مع تمرير البيانات
        // نمرر الكورس كقائمة من عنصر واحد عشان MyCoursesPage تشتغل
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyCoursesPage(
              courses: [course],  // قائمة من عنصر واحد
              selectedCourseId: course.id,  // نحدد الكورس المختار
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),  // مسافة أسفل البطاقة
        padding: const EdgeInsets.all(16),  // هوامش داخلية
        decoration: BoxDecoration(
          color: Colors.white,  // خلفية بيضاء
          borderRadius: BorderRadius.circular(16),  // حواف دائرية
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),  // ظل خفيف جداً
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // 🖼️ أيقونة الكورس في مربع ملون (جراديانت)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 28)),
            ),
            const SizedBox(width: 16),  // مسافة بين الأيقونة والمعلومات

            // 📝 معلومات الكورس (العنوان، المدرب، إلخ)
            Expanded(  // نأخذ المساحة المتبقية للمعلومات
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,  // عنوان الكورس
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),

                  // صف: اسم المدرب + عدد الطلاب
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(course.trainerName,  // اسم المدرب
                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Icon(Icons.people_outline, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${course.studentsCount} students',  // عدد الطلاب
                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // صف: المدة + عدد الجلسات
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(course.totalHours,  // المدة الكلية
                          style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      const SizedBox(width: 12),
                      Icon(Icons.video_library, size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text('${course.sessions.length} sessions',  // عدد الجلسات
                          style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),

            // 🏷️ شارة المستوى (Level Badge) على اليمين
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Level ${course.levelNumber}',  // رقم المستوى
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔲 دالة مساعدة: بناء مربع خدمة (مثل "فرص عمل")
  // ============================================================
  Widget _buildSquareCard(BuildContext context, {
    required String title,      // عنوان المربع (يدعم \n لسطور متعددة)
    required IconData icon,     // الأيقونة المعروضة
    required Color color,       // اللون الرئيسي للمربع
    required VoidCallback onTap, // الدالة اللي بتنادى عند الضغط
  }) {
    return GestureDetector(
      onTap: onTap,  // تنفيذ الدالة عند الضغط على المربع
      child: Container(
        height: 100,  // ارتفاع ثابت للمربع
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),  // خلفية فاتحة من اللون الرئيسي
          borderRadius: BorderRadius.circular(16),  // حواف دائرية
          border: Border.all(color: color.withOpacity(0.3), width: 1),  // حدود خفيفة بنفس اللون
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // توسيط عمودي للمحتوى
          children: [
            Icon(icon, color: color, size: 32),  // الأيقونة باللون الرئيسي
            const SizedBox(height: 6),  // مسافة بين الأيقونة والعنوان
            // العنوان (يدعم سطور متعددة بـ \n)
            Text(title,
                textAlign: TextAlign.center,  // توسيط النص
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}