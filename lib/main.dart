// 📄 lib/main.dart
// ============================================================
// 🚀 نقطة الدخول الرئيسية للتطبيق
// ============================================================
// الوظيفة:
// - تهيئة التطبيق قبل تشغيله (WidgetsFlutterBinding)
// - توفير جميع الـ BLoCs عبر MultiBlocProvider
// - تحديد الصفحة الأولى التي يراها المستخدم حسب حالته

// 📦 استيراد المكتبات الأساسية
import 'package:flutter/material.dart';           // مكتبة فلاتر الأساسية
import 'package:flutter_bloc/flutter_bloc.dart';  // مكتبة إدارة الحالة (BLoC)
import 'package:shared_preferences/shared_preferences.dart';  // للتخزين المحلي
import 'package:http/http.dart' as http;          // للاتصال بالإنترنت (موجود للضرورة)

// 🧠 استيراد جميع الـ BLoCs
import 'bloc/auth/auth_bloc.dart';      // BLoC المصادقة (تسجيل دخول/خروج)
import 'bloc/course/course_bloc.dart';  // BLoC الكورسات
import 'bloc/project/project_bloc.dart'; // BLoC المشاريع
import 'bloc/chat/chat_bloc.dart';      // BLoC المحادثات
import 'bloc/job/job_bloc.dart';        // BLoC الوظائف

// 🔗 استيراد جميع الـ Repositories (الوسيط مع الباك إند)
import 'repositories/auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/job_repository.dart';

// 🖼️ استيراد الشاشات الرئيسية
import 'screens/auth/login_screen.dart';        // شاشة تسجيل الدخول
import 'screens/trainee/trainee_home_screen.dart'; // صفحة الطالب الرئيسية
import 'screens/trainer/trainer_home_screen.dart'; // صفحة المدرب الرئيسية

// 👤 استيراد نموذج المستخدم
import 'models/user_model.dart';

// ============================================================
// 🏁 دالة البداية: main()
// ============================================================
void main() async {
  // ✅ ضروري جداً: نهيئ الربط بين فلاتر والبلاتفورم قبل أي شيء
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ نهيئ SharedPreferences عشان نقدر نستخدمها لاحقاً (لحفظ التوكن مثلاً)
  await SharedPreferences.getInstance();

  // ✅ يمكن إضافة تهيئة HTTP هنا إذا لزم الأمر (مثل إضافة interceptors)

  // ✅ أخيراً: نشغل التطبيق!
  runApp(const MyApp());
}

// ============================================================
// 🏗️ كلاس التطبيق الرئيسي (MyApp)
// ============================================================
// الوظيفة:
// - إعداد الثيم والألوان والخطوط للتطبيق
// - توفير جميع الـ BLoCs عبر MultiBlocProvider
// - تحديد الـ MaterialApp وإعداداته

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // constructor قياسي

  @override
  Widget build(BuildContext context) {
    // ✅ MultiBlocProvider: يوفر جميع الـ BLoCs للتطبيق كله
    // أي شاشة تحت هون تقدر تستخدم context.read<SomeBloc>() أو context.watch<SomeBloc>()
    return MultiBlocProvider(
      providers: [

        // 🔐 1. AuthBloc - إدارة المصادقة
        // الوظيفة: تسجيل دخول، تسجيل خروج، التحقق من الجلسة، جلب البروفايل
        BlocProvider(
          create: (context) => AuthBloc()..add(const CheckAuthStatusEvent()),
          // ✅ نرسل حدث التحقق من الحالة فور إنشاء الـ BLoC
          // عشان يتحقق إذا المستخدم مسجل دخول ولا لأ
        ),

        // 📚 2. CourseBloc - إدارة الكورسات
        // الوظيفة: جلب الكورسات، التسجيل، إلغاء التسجيل، تتبع التقدم
        BlocProvider(
          create: (context) => CourseBloc(
            courseRepository: CourseRepository(),  // ✅ نمرر الـ Repository عشان يتصل بالباك إند
          ),
        ),

        // 📁 3. ProjectBloc - إدارة المشاريع
        // الوظيفة: رفع المشاريع، عرضها، تعديلها، حذفها
        BlocProvider(
          create: (context) => ProjectBloc(
            projectRepository: ProjectRepository(),
          ),
        ),

        // 💬 4. ChatBloc - إدارة المحادثات
        // الوظيفة: إرسال رسائل، جلب المحادثات، إشعارات جديدة
        BlocProvider(
          create: (context) => ChatBloc(
            chatRepository: ChatRepository(),
          ),
        ),

        // 💼 5. JobBloc - إدارة فرص العمل (جديد)
        // الوظيفة: عرض الوظائف، التقديم عليها، تتبع حالة الطلب
        BlocProvider(
          create: (_) => JobBloc(
            jobRepository: JobRepository(),
          ),
        ),

      ], // نهاية قائمة providers

      // 🎨 MaterialApp: إعدادات التطبيق الرئيسية
      child: MaterialApp(
        title: 'Empower',  // اسم التطبيق (يظهر في بعض الأجهزة)
        debugShowCheckedModeBanner: false,  // ❌ نخفي شريط "DEBUG" الأحمر في الزاوية

        // 🎨 الثيم: الألوان والخطوط والتصميم العام
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,  // اللون الرئيسي (بنفسجي غامق)
          scaffoldBackgroundColor: Colors.white,  // خلفية الصفحات بيضاء
          fontFamily: 'Poppins',  // الخط المستخدم في كل التطبيق

          // 🎨 إعدادات شريط العنوان (AppBar)
          appBarTheme: const AppBarTheme(
            elevation: 0,  // ❌ نزيل الظل تحت الأبار
            centerTitle: true,  // ✅ نوسط العنوان
            backgroundColor: Colors.deepPurple,  // خلفية الأبار بنفسجية
            foregroundColor: Colors.white,  // لون النصوص والأيقونات أبيض
          ),
        ),

        // 🏠 الصفحة الأولى: نستخدم AppInitializer عشان نوجه المستخدم حسب حالته
        home: const AppInitializer(),
      ),
    );
  }
}

// ============================================================
// 🎯 صفحة التوجيه التلقائي (AppInitializer)
// ============================================================
// الوظيفة:
// - التحقق من حالة تسجيل الدخول عند فتح التطبيق
// - توجيه المستخدم للصفحة المناسبة تلقائياً:
//   • مسجل دخول كطالب → TraineeHomeScreen
//   • مسجل دخول كمدرب → TrainerHomeScreen
//   • غير مسجل → LoginScreen

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // 👂 BlocBuilder: يستمع لتغيرات حالة AuthBloc ويبني الواجهة بناءً عليها
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {

        // 🟡 الحالة 1: جاري التحقق من تسجيل الدخول (تحميل)
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // توسيط عمودي
                children: [
                  // دائرة تحميل بنفسجية
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  SizedBox(height: 16),  // مسافة بين الدائرة والنص
                  Text(
                    'جاري التحميل...',  // نص عربي للمستخدم
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ الحالة 2: تسجيل الدخول ناجح (المستخدم مسجل)
        if (state is AuthAuthenticated) {

          // 🎯 نوجه المستخدم حسب نوع حسابه (دور المستخدم)
          if (state.user.userType == UserType.trainer) {
            // 👨‍🏫 مدرب → يذهب لصفحة المدرب الرئيسية
            return const TrainerHomeScreen();

          } else if (state.user.userType == UserType.admin) {
            // 👑 أدمن → نوجهه مؤقتاً لصفحة المدرب (يمكن نضيف صفحة أدمن لاحقاً)
            return const TrainerHomeScreen();

          } else {
            // 🎓 طالب (أو أي دور آخر) → يذهب لصفحة الطالب الرئيسية
            return const TraineeHomeScreen();
          }
        }

        // ❌ الحالة 3: غير مسجل دخول أو في خطأ → يذهب لصفحة تسجيل الدخول
        // هذه هي الحالة الافتراضية إذا ما تحقق أي من الشروط فوق
        return const LoginScreen();

      }, // نهاية builder
    );
  }
}