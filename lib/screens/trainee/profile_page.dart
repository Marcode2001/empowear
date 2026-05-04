// استيراد مكتبة Flutter الأساسية لبناء واجهات المستخدم
import 'package:flutter/material.dart';
// استيراد مكتبة Provider للتعامل مع حالة المستخدم (مثل تسجيل الدخول والخروج)
import 'package:provider/provider.dart';
// استيراد ملف AuthProvider الذي يحتوي على دوال تسجيل الدخول والخروج
import '../../providers/auth_provider.dart';
// استيراد ملف UserModel الذي يحتوي على نموذج بيانات المستخدم
import '../../models/user_model.dart';
// استيراد صفحة تسجيل الدخول للانتقال إليها عند تسجيل الخروج
import '../auth/login_screen.dart';

// ============================================================
// صفحة البروفايل (Profile Page)
// ============================================================

// تعريف كلاس صفحة البروفايل (StatefulWidget لأن الصفحة تحتوي على حالة متغيرة)
class ProfilePage extends StatefulWidget {
  // Konstruktor للصفحة
  const ProfilePage({super.key});

  // دالة لإنشاء حالة (State) الصفحة
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// كلاس الحالة (State) حيث يحتوي على المنطق والبيانات
class _ProfilePageState extends State<ProfilePage> {
  // متغير يظهر حالة التحميل عند تسجيل الخروج (true = جاري التحميل، false = لا يوجد تحميل)
  bool _isLoading = false;

  // بيانات مستوى الطالب الحالي (ستأتي من API لاحقاً)
  final Map<String, dynamic> studentStats = {
    'level': 3,  // مستوى الطالب (رقم المستوى)
  };

  // ============================================================
  // بيانات المشاريع المرسلة (ستأتي من API لاحقاً)
  // ============================================================

  // قائمة بجميع المشاريع التي أرسلها الطالب
  // بيانات المشاريع المرسلة (مع التأكد من عدم وجود null)
  final List<Map<String, dynamic>> allProjects = [
    {
      'name': 'E-commerce App',
      'submissionDate': '2024-03-15',
      'status': 'Graded',
      'grade': 'A',
      'feedback': 'Excellent work! Great UI design.',
      'trainer': 'Dr. Ahmed',
    },
    {
      'name': 'Portfolio Website',
      'submissionDate': '2024-03-20',
      'status': 'Graded',
      'grade': 'A+',
      'feedback': 'Outstanding! Perfect responsive design.',
      'trainer': 'Sara Ali',
    },
    {
      'name': 'Weather App',
      'submissionDate': '2024-04-01',
      'status': 'Pending',
      'grade': '-',
      'feedback': 'Waiting for trainer review',
      'trainer': 'Omar',
    },
    {
      'name': 'Chat Application',
      'submissionDate': '2024-04-10',
      'status': 'Rejected',
      'grade': 'F',
      'feedback': 'Needs improvement. Missing real-time features.',
      'trainer': 'Lina',
    },
  ];

  // ============================================================
  // بيانات طلبات التوظيف (ستأتي من API لاحقاً)
  // ============================================================

  // قائمة بجميع طلبات التوظيف التي قدمها الطالب
  final List<Map<String, dynamic>> allJobApplications = [
    {
      'title': 'Flutter Developer',               // عنوان الوظيفة
      'company': 'Tech Solutions',                // اسم الشركة
      'appliedDate': '2024-03-01',                // تاريخ التقديم
      'status': 'Pending',                        // الحالة (Pending, Accepted, Rejected)
      'statusColor': Colors.orange,               // لون الحالة (برتقالي لقيد المراجعة)
      'message': 'Your application is under review', // رسالة الحالة
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Creative Studio',
      'appliedDate': '2024-03-05',
      'status': 'Accepted',
      'statusColor': Colors.green,                // أخضر للمقبول
      'message': 'Congratulations! You have been accepted.',
    },
    {
      'title': 'Mobile Developer',
      'company': 'App Factory',
      'appliedDate': '2024-03-10',
      'status': 'Rejected',
      'statusColor': Colors.red,                  // أحمر للمرفوض
      'message': 'Thank you for applying, but we moved forward with others.',
    },
  ];

  // ============================================================
  // دالة تسجيل الخروج
  // ============================================================

  // دالة غير متزامنة (async) لتسجيل الخروج
  Future<void> _logout() async {
    // عرض نافذة تأكيد (AlertDialog) قبل تسجيل الخروج
    final confirm = await showDialog<bool>(
      context: context,  // السياق الحالي للتطبيق
      builder: (context) => AlertDialog(
        // جعل زوايا النافذة دائرية بمقدار 20 بكسل
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // عنوان النافذة
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        // محتوى النافذة (السؤال)
        content: const Text('Are you sure you want to logout?'),
        // أزرار الإجراءات
        actions: [
          // زر الإلغاء (يعيد false)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          // زر تأكيد تسجيل الخروج (يعيد true)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,      // لون الزر أحمر
              foregroundColor: Colors.white,    // لون النص أبيض
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // إذا وافق المستخدم (confirm == true) وكانت الصفحة لا تزال مفتوحة (mounted)
    if (confirm == true && mounted) {
      // إظهار مؤشر التحميل
      setState(() => _isLoading = true);

      // الحصول على AuthProvider وإلغاء الاستماع لتجنب التحديثات غير الضرورية
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // استدعاء دالة تسجيل الخروج من AuthProvider
      await authProvider.logout();

      // إذا كانت الصفحة لا تزال مفتوحة
      if (mounted) {
        // الانتقال إلى صفحة تسجيل الدخول وإزالة جميع الصفحات السابقة من الـ Stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,  // إزالة جميع الصفحات (true = إبقاء، false = إزالة)
        );
      }
    }
  }

  // ============================================================
  // دالة بناء واجهة المستخدم الرئيسية (UI)
  // ============================================================

  // دالة build تبني واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    // الحصول على AuthProvider لقراءة بيانات المستخدم الحالي
    final authProvider = Provider.of<AuthProvider>(context);
    // الحصول على كائن المستخدم الحالي (قد يكون null إذا لم يسجل الدخول)
    final user = authProvider.currentUser;

    // إرجاع الـ Scaffold (الهيكل الأساسي للصفحة)
    return Scaffold(
      // لون خلفية الصفحة رمادي فاتح جداً
      backgroundColor: Colors.grey.shade50,
      // المحتوى الرئيسي للصفحة (يتغير حسب حالة التحميل)
      body: _isLoading
      // إذا كان جاري التحميل، عرض مؤشر تحميل
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // توسيط عمودي
          children: [
            // مؤشر التحميل الدائري بلون بنفسجي
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            // نص يوضح أن الخروج جارٍ
            Text('Logging out...'),
          ],
        ),
      )
      // إذا لم يكن جاري التحميل، عرض المحتوى باستخدام CustomScrollView
          : CustomScrollView(
        slivers: [
          // ============================================================
          // SliverAppBar - شريط علوي ممتد مع صورة المستخدم
          // ============================================================
          SliverAppBar(
            expandedHeight: 250,      // ارتفاع الشريط عند التمدد (250 بكسل)
            pinned: true,             // يثبت الشريط في الأعلى عند التمرير للأسفل
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                // خلفية بتدرج لوني من البنفسجي الغامق إلى البنفسجي الفاتح
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,      // نقطة بداية التدرج (أعلى اليسار)
                    end: Alignment.bottomRight,    // نقطة نهاية التدرج (أسفل اليمين)
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,  // توسيط عمودي
                  children: [
                    const Spacer(),  // مسافة مرنة في الأعلى (توسع العناصر)

                    // الصورة الرمزية (دائرة تحتوي على أول حرف من الاسم)
                    Container(
                      width: 90,    // عرض 90 بكسل
                      height: 90,   // ارتفاع 90 بكسل
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,  // شكل دائري
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),  // ظل أبيض شفاف
                            blurRadius: 20,    // نصف قطر التمويه
                            spreadRadius: 5,   // نصف قطر الانتشار
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 41,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            // عرض أول حرف من الاسم، إذا كان الاسم موجوداً، وإلا عرض 'M'
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'M',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),  // مسافة عمودية 12 بكسل

                    // اسم المستخدم (من AuthProvider)
                    Text(
                      user?.name ?? 'Marwa Zenalabdin',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // مستوى الطالب (مع أيقونة نجمة)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,  // يأخذ حجم المحتوى فقط
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Level ${studentStats['level']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),  // مسافة مرنة في الأسفل
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // المحتوى الرئيسي (SliverList مع جميع العناصر)
          // ============================================================
          SliverPadding(
            padding: const EdgeInsets.all(16),  // مسافة حول المحتوى 16 بكسل
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ============================================================
                // القسم 1: Submitted Projects (المشاريع المرسلة)
                // ============================================================
                _buildSectionHeader(
                  icon: Icons.assignment_turned_in,  // أيقونة المشاريع
                  title: 'Submitted Projects',
                  count: allProjects.length,
                  showSeeAll: allProjects.length > 2,  // يظهر زر See All إذا كان أكثر من 2
                  onSeeAll: () {
                    // عند الضغط على See All، الانتقال إلى صفحة تعرض كل المشاريع
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllProjectsPage(projects: allProjects),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),  // مسافة 12 بكسل

                // عرض أول 2 مشروع فقط في الصفحة الرئيسية (take(2))
                ...allProjects.take(2).map((project) => _buildSubmittedProjectCard(project)),

                const SizedBox(height: 24),  // مسافة 24 بكسل بين الأقسام

                // ============================================================
                // القسم 2: Job Applications (طلبات التوظيف)
                // ============================================================
                _buildSectionHeader(
                  icon: Icons.work_history,  // أيقونة طلبات التوظيف
                  title: 'Job Applications',
                  count: allJobApplications.length,
                  showSeeAll: allJobApplications.length > 2,
                  onSeeAll: () {
                    // عند الضغط على See All، الانتقال إلى صفحة تعرض كل طلبات التوظيف
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllJobApplicationsPage(jobs: allJobApplications),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // إذا كانت قائمة طلبات التوظيف فارغة، عرض رسالة "لا توجد طلبات"
                if (allJobApplications.isEmpty)
                  _buildEmptyState('No job applications yet')
                else
                // عرض أول 2 طلب فقط في الصفحة الرئيسية (take(2))
                  ...allJobApplications.take(2).map((job) => _buildJobApplicationCard(job)),

                const SizedBox(height: 24),

                // ============================================================
                // زر تسجيل الخروج
                // ============================================================
                _buildLogoutButton(),

                // ✅ مسافة أسفل الصفحة (30 بكسل) لمنع التصاق المحتوى بأزرار الموبايل
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // دالة لبناء عنوان القسم مع زر See All في أعلى اليمين
  // ============================================================
  Widget _buildSectionHeader({
    required IconData icon,          // أيقونة القسم
    required String title,          // عنوان القسم
    required int count,             // عدد العناصر في القسم
    required bool showSeeAll,       // هل يظهر زر See All؟
    required VoidCallback onSeeAll, // دالة تنفذ عند الضغط على See All
  }) {
    return Row(
      children: [
        // أيقونة القسم داخل مربع بتدرج بنفسجي
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),

        // عنوان القسم
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),  // يدفع العناصر إلى اليمين

        // عدد العناصر (مثلاً: 4)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // زر See All (يظهر فقط إذا showSeeAll == true)
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 12, color: Colors.deepPurple),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // دالة لبناء بطاقة المشروع المرسل
  // ============================================================
  Widget _buildSubmittedProjectCard(Map<String, dynamic> project) {
    // تحديد اللون والأيقونة حسب حالة المشروع
    Color statusColor;
    IconData statusIcon;

    // Switch case لاختيار اللون والأيقونة حسب الحالة
    switch (project['status']) {
      case 'Graded':      // تم التصحيح
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Pending':     // قيد المراجعة
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Rejected':    // مرفوض
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:            // غير معروف
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    // إرجاع بطاقة المشروع
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),  // ظل رمادي شفاف جداً
            blurRadius: 5,
            offset: const Offset(0, 2),            // إزاحة الظل (2 بكسل للأسفل)
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحالة
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),

          // معلومات المشروع (الاسم - المدرب)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  project['trainer'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // الدرجة (إذا كانت موجودة وليست '-')
          if (project['grade'] != '-')
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradeGradient(project['grade']),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  project['grade'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // دالة لبناء بطاقة طلب التوظيف
  // ============================================================
  Widget _buildJobApplicationCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الوظيفة بلون الحالة
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: job['statusColor'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.work, color: job['statusColor'], size: 20),
          ),
          const SizedBox(width: 12),

          // معلومات الوظيفة (العنوان - الشركة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job['company'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // الحالة والتاريخ (معروضين في عمود على اليمين)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: job['statusColor'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: job['statusColor'],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job['appliedDate'],
                style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // دالة لبناء رسالة "لا توجد عناصر" (عندما تكون القائمة فارغة)
  // ============================================================
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // أيقونة صندوق الوارد
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          // نص الرسالة (مثل "No job applications yet")
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // دالة لبناء زر تسجيل الخروج
  // ============================================================
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,  // يأخذ العرض الكامل
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade500],  // تدرج أحمر
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,  // خلفية شفافة لتظهر التدرج
        child: InkWell(
          onTap: _logout,  // استدعاء دالة تسجيل الخروج عند الضغط
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // دالة للحصول على تدرج لوني حسب الدرجة (A, B, C, F)
  // ============================================================
  List<Color> _getGradeGradient(String grade) {
    // استخدام switch لتحديد الألوان حسب الدرجة
    switch (grade) {
      case 'A+':  // درجات عالية جداً
      case 'A':   // درجة عالية
        return [Colors.green, Colors.lightGreen];     // أخضر → أخضر فاتح
      case 'B':   // درجة متوسطة
        return [Colors.blue, Colors.lightBlue];        // أزرق → أزرق فاتح
      case 'C':   // درجة منخفضة
        return [Colors.orange, Colors.orangeAccent];   // برتقالي → برتقالي فاتح
      case 'F':   // راسب
        return [Colors.red, Colors.redAccent];         // أحمر → أحمر فاتح
      default:    // أي درجة أخرى أو غير معروفة
        return [Colors.grey, Colors.grey];              // رمادي → رمادي
    }
  }
}

// ============================================================
// صفحة عرض كل المشاريع (عند الضغط على See All في قسم المشاريع)
// ============================================================

// كلاس صفحة "كل المشاريع" (StatelessWidget لأنها تحتوي على بيانات ثابتة)
class AllProjectsPage extends StatelessWidget {
  // قائمة المشاريع التي سيتم عرضها (تُمرر من الصفحة السابقة)
  final List<Map<String, dynamic>> projects;

  // Konstruktor يستقبل قائمة المشاريع
  const AllProjectsPage({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(
        title: const Text('All Projects'),  // عنوان الصفحة
        backgroundColor: Colors.deepPurple,   // لون الخلفية بنفسجي غامق
        foregroundColor: Colors.white,        // لون النص والأيقونات أبيض
      ),
      // المحتوى الرئيسي: ListView.builder لبناء قائمة قابلة للتمرير
      body: ListView.builder(
        // المسافات حول المحتوى (left, top, right, bottom)
        // ✅ bottom: 80 يخلق مسافة بين آخر بطاقة وأزرار الموبايل
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        // عدد العناصر = طول قائمة المشاريع
        itemCount: projects.length,
        // بناء كل عنصر حسب رقمه (index)
        itemBuilder: (context, index) => _buildProjectCard(projects[index]),
      ),
    );
  }

  // دالة لبناء بطاقة المشروع الواحدة (داخل صفحة All Projects)
  Widget _buildProjectCard(Map<String, dynamic> project) {
    // تحديد لون الحالة حسب حالة المشروع
    Color statusColor;
    switch (project['status']) {
      case 'Graded':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي: اسم المشروع + الدرجة (إذا كانت موجودة)
          Row(
            children: [
              Expanded(
                child: Text(
                  project['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (project['grade'] != '-')
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradeGradient(project['grade']),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      project['grade'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // معلومات المدرب
          Text('Trainer: ${project['trainer']}'),
          // تاريخ الإرسال
          Text('Submitted: ${project['submissionDate']}'),
          const SizedBox(height: 8),
          // صندوق الملاحظات بلون خفيف حسب الحالة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(project['feedback']),
          ),
          const SizedBox(height: 8),
          // الحالة (محاذاة إلى اليمين)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                project['status'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة لتحديد تدرج لوني حسب الدرجة (مكررة من الصفحة الرئيسية)
  List<Color> _getGradeGradient(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return [Colors.green, Colors.lightGreen];
      case 'B':
        return [Colors.blue, Colors.lightBlue];
      case 'C':
        return [Colors.orange, Colors.orangeAccent];
      case 'F':
        return [Colors.red, Colors.redAccent];
      default:
        return [Colors.grey, Colors.grey];
    }
  }
}

// ============================================================
// صفحة عرض كل طلبات التوظيف (عند الضغط على See All في قسم طلبات التوظيف)
// ============================================================

// كلاس صفحة "كل طلبات التوظيف"
class AllJobApplicationsPage extends StatelessWidget {
  // قائمة طلبات التوظيف
  final List<Map<String, dynamic>> jobs;

  const AllJobApplicationsPage({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Applications'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        // ✅ bottom: 80 يخلق مسافة في الأسفل
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: jobs.length,
        itemBuilder: (context, index) => _buildJobCard(jobs[index]),
      ),
    );
  }

  // دالة لبناء بطاقة طلب التوظيف الواحدة
  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الوظيفة
          Text(
            job['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // اسم الشركة
          Text(job['company'], style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          // صندوق رسالة الحالة (بلون الحالة)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: job['statusColor'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(job['message']),
          ),
          const SizedBox(height: 8),
          // الصف السفلي: تاريخ التقديم + الحالة
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Applied on ${job['appliedDate']}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: job['statusColor'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: job['statusColor'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}