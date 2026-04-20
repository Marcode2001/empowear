// استيراد مكتبة Flutter الأساسية لبناء واجهات المستخدم
import 'package:flutter/material.dart';

// الكلاس الرئيسي للشاشة (StatefulWidget عشان نقدر نغير حالة الشاشة)
class TraineeHomeScreen extends StatefulWidget {
  const TraineeHomeScreen({super.key});

  // دالة لإنشاء حالة (State) الكلاس
  @override
  State<TraineeHomeScreen> createState() => _TraineeHomeScreenState();
}

// كلاس الحالة (State) حيث نكتب الكود اللي يتغير
class _TraineeHomeScreenState extends State<TraineeHomeScreen> {
  // متغير يخزن رقم الصفحة المحددة حالياً (0 = الصفحة الأولى)
  int _selectedIndex = 0;

  // قائمة تحتوي على صفحات التطبيق (4 صفحات)
  final List<Widget> _screens = [
    const HomePage(),      // الصفحة الرئيسية (الرقم 0)
    const AiToolsPage(),   // صفحة أدوات الذكاء الاصطناعي (الرقم 1)
    const ChatsListPage(), // صفحة الدردشات (الرقم 2)
    const ProfilePage(), // صفحة الملف الشخصي (الرقم 3)
  ];

  // قائمة تحتوي على عناوين الصفحات اللي تظهر في الـ AppBar
  final List<String> _titles = [
    'Home',       // عنوان الصفحة الرئيسية
    'AI Tools',   // عنوان صفحة AI Tools
    'Chats',      // عنوان صفحة الدردشة
    'Profile',    // عنوان صفحة الملف الشخصي
  ];

  // دالة بناء واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================== شريط العلوي (AppBar) ====================
      appBar: AppBar(
        // النص اللي يظهر في الشريط العلوي (حسب الصفحة المحددة)
        title: Text(
          _titles[_selectedIndex], // نختار العنوان من قائمة _titles
          style: const TextStyle(
            color: Colors.white,           // لون النص أبيض
            fontWeight: FontWeight.bold,   // خط عريض
          ),
        ),
        backgroundColor: Colors.deepPurple, // لون خلفية الشريط بنفسجي
        centerTitle: true,                   // النص يكون في المنتصف
        elevation: 0,                        // إزالة الظل من الشريط
      ),

      // ==================== المحتوى الرئيسي (Body) ====================
      body: _screens[_selectedIndex], // نعرض الصفحة حسب الرقم المختار

      // ==================== الشريط السفلي (Bottom Navigation Bar) ====================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // يثبت الأيقونات كلها (ما يخفي شي)
        currentIndex: _selectedIndex,       // الأيقونة المحددة حالياً
        onTap: (index) {                    // لما المستخدم يضغط على أيقونة
          setState(() {                     // نغير حالة التطبيق
            _selectedIndex = index;         // نغير رقم الصفحة المحددة
          });
        },
        selectedItemColor: Colors.deepPurple, // لون الأيقونة المحددة
        unselectedItemColor: Colors.grey,     // لون الأيقونات الغير محددة
        items: const [                        // قائمة الأيقونات في الشريط السفلي
          BottomNavigationBarItem(
            icon: Icon(Icons.home),           // أيقونة البيت
            label: 'Home',                   // النص تحت الأيقونة
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),   // أيقونة AI Tools
            label: 'AI Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), // أيقونة الدردشة
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),         // أيقونة الملف الشخصي
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== الصفحة الرئيسية (Home Page) ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ScrollView عشان نقدر نتمرر للأسفل
      padding: const EdgeInsets.all(16), // مسافة حول المحتوى 16 بكسل
      child: Column( // ترتيب العناصر عمودياً
        crossAxisAlignment: CrossAxisAlignment.start, // المحاذاة لليسار
        children: [
          // ==================== بطاقة الترحيب والمستوى ====================
          Container(
            padding: const EdgeInsets.all(20), // مسافة داخلية 20 بكسل
            decoration: BoxDecoration(
              gradient: const LinearGradient( // تدرج لوني
                colors: [Colors.deepPurple, Colors.purple], // من بنفسجي غامق لبنفسجي فاتح
                begin: Alignment.topLeft,    // يبدأ من أعلى اليسار
                end: Alignment.bottomRight,  // ينتهي بأسفل اليمين
              ),
              borderRadius: BorderRadius.circular(20), // زوايا دائرية 20 بكسل
            ),
            child: Row( // ترتيب العناصر أفقياً
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // تباعد بين العناصر
              children: [
                Column( // العمود الأيسر (النصوص)
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome 👋', // نص الترحيب
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // مسافة عمودية 8 بكسل
                    const Text(
                      'Marwa Zenalabdin', // اسم الطالب
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, // مسافة يمين ويسار
                        vertical: 6,    // مسافة فوق وتحت
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), // لون أبيض شفاف
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          const Text(
                            'Level 3', // مستوى الطالب
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle, // دائرة
                  ),
                  child: const Icon(
                    Icons.school, // أيقونة المدرسة
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24), // مسافة 24 بكسل

          // ==================== 4 مربعات الخدمات ====================
          // الصف الأول من المربعات (Job Opportunities + Students Project)
          Row(
            children: [
              Expanded(
                child: _buildSquareCard(
                  context,
                  title: 'Job\nOpportunities',
                  icon: Icons.work,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JobOpportunitiesPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSquareCard(
                  context,
                  title: 'Students\nProject',
                  icon: Icons.folder,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentsProjectsPage()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12), // مسافة بين الصفين

          // الصف الثاني من المربعات (Upload Project + Register Course)
          Row(
            children: [
              Expanded(
                child: _buildSquareCard(
                  context,
                  title: 'Upload\nProject',
                  icon: Icons.upload_file,
                  color: Colors.green,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSquareCard(
                  context,
                  title: 'Register\nCourse',
                  icon: Icons.add_circle,
                  color: Colors.deepPurple,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ==================== عنوان الكورسات ====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Courses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // الانتقال إلى صفحة MyCoursesPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyCoursesPage()),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          // ==================== قائمة الكورسات ====================
          ListView.builder(
            shrinkWrap: true, // يأخذ حجم المحتوى فقط
            physics: const NeverScrollableScrollPhysics(), // يمنع التمرير الداخلي
            itemCount: 4, // عدد العناصر 4
            itemBuilder: (context, index) { // نبني كل كورس حسب رقمه
              return _buildCourseCard(
                courseName: 'CourseName ${index + 1}', // اسم الكورس
                trainerName: 'Trainee name',           // اسم المدرب
                progress: '${65 + index * 10}%',       // نسبة التقدم
              );
            },
          ),
        ],
      ),
    );
  }

  // دالة لبناء المربع الواحد (Square Card)
  Widget _buildSquareCard(BuildContext context, {
    required String title,      // عنوان المربع
    required IconData icon,     // الأيقونة
    required Color color,       // اللون
    required VoidCallback onTap, // دالة عند الضغط
  }) {
    return GestureDetector( // تتعرف على ضغطات المستخدم
      onTap: onTap,
      child: Container(
        height: 120, // ارتفاع المربع
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // لون شفاف 10%
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3), // حدود شفافة 30%
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // توسيط عمودي
          children: [
            Icon(icon, color: color, size: 40), // الأيقونة بلون المربع
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center, // النص في المنتصف
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء بطاقة الكورس الواحدة
  Widget _buildCourseCard({
    required String courseName,
    required String trainerName,
    required String progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // مسافة من الأسفل
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // خلفية بيضاء
        borderRadius: BorderRadius.circular(12),
        boxShadow: [ // ظل خفيف
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الكورس
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book,
              color: Colors.deepPurple,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),

          // معلومات الكورس (الاسم - المدرب - شريط التقدم)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trainerName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // شريط التقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: double.parse(progress.replaceAll('%', '')) / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.deepPurple,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // نسبة الإنجاز
          Text(
            progress,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== صفحة أدوات الذكاء الاصطناعي ====================
class AiToolsPage extends StatelessWidget {
  const AiToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'AI Tools',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose how you want AI to help you',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildAiCard(
            'AI Design Generator',
            'Convert sketch into 3D and suggesting the appropriate color',
            Icons.design_services,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildAiCard(
            'AI Material Checker',
            'Suggesting the appropriate type of fabric',
            Icons.checkroom,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildAiCard(
            'AI Chatbot',
            'Get answers to your questions',
            Icons.chat_bubble_outline,
            Colors.green,
          ),
        ],
      ),
    );
  }

  // دالة لبناء بطاقة أداة AI
  Widget _buildAiCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== صفحة الدردشات ====================
class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  // بيانات الدردشات (اسم - رسالة - وقت)
  final List<Map<String, String>> chats = const [
    {'name': 'starrysKies23', 'message': 'HI', 'time': '9:41 AM'},
    {'name': 'Ahmed Ali', 'message': 'How are you?', 'time': 'Yesterday'},
    {'name': 'Sarah', 'message': 'Thanks for your help', 'time': 'Yesterday'},
    {'name': 'Mohammed', 'message': 'See you tomorrow', 'time': '2 days ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // حقل البحث
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ),
        // قائمة الدردشات
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  child: Text(
                    chat['name']![0].toUpperCase(),
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                ),
                title: Text(chat['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(chat['message']!),
                trailing: Text(chat['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== صفحة الملف الشخصي ====================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // الخلفية العلوية (الجزء البنفسجي)
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: -50,
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        'S', // أول حرف من الاسم
                        style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 70), // مسافة لظهور الصورة
          const Text(
            'Sarah Ahmed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'sarah@example.com',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Level 3 - Advanced',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 32),
          // قائمة الإعدادات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuItem(Icons.person_outline, 'Personal Information'),
                _buildMenuItem(Icons.school_outlined, 'My Learning'),
                _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
                _buildMenuItem(Icons.security_outlined, 'Privacy & Security'),
                _buildMenuItem(Icons.help_outline, 'Help & Support'),
                const Divider(height: 32),
                _buildMenuItem(Icons.logout, 'Logout', isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // دالة لبناء عنصر القائمة
  Widget _buildMenuItem(IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.deepPurple),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}

// ==================== صفحة My Courses (كل الكورسات) ====================
// ==================== صفحة My Courses (كل الكورسات) مع بحث ====================
class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  // متغير لتخزين نص البحث
  String _searchQuery = '';

  // متحكم في حقل البحث
  final TextEditingController _searchController = TextEditingController();

  // قائمة الكورسات (كل الكورسات المتاحة)
  final List<Map<String, dynamic>> allCourses = const [
    {'name': 'Flutter Development', 'trainer': 'Dr. Ahmed', 'progress': 75, 'hours': '3 hours'},
    {'name': 'UI/UX Design', 'trainer': 'Sara Ali', 'progress': 45, 'hours': '2 hours'},
    {'name': 'Firebase Basics', 'trainer': 'Mohammed', 'progress': 60, 'hours': '4 hours'},
    {'name': 'State Management', 'trainer': 'Lina', 'progress': 30, 'hours': '2 hours'},
    {'name': 'Animation in Flutter', 'trainer': 'Omar', 'progress': 85, 'hours': '3 hours'},
    {'name': 'Backend Development', 'trainer': 'Nadia', 'progress': 20, 'hours': '5 hours'},
    {'name': 'Database Design', 'trainer': 'Khalid', 'progress': 50, 'hours': '3 hours'},
    {'name': 'Mobile Security', 'trainer': 'Rana', 'progress': 40, 'hours': '2 hours'},
  ];

  // دالة لفلترة الكورسات حسب البحث
  List<Map<String, dynamic>> get _filteredCourses {
    if (_searchQuery.isEmpty) {
      return allCourses;
    }
    return allCourses.where((course) {
      return course['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course['trainer'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // إضافة أيقونة البحث في الـ AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // فتح حقل البحث
              showSearch(
                context: context,
                delegate: CourseSearchDelegate(allCourses),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ==================== حقل البحث المدمج ====================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by course name or trainer...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ==================== عرض عدد النتائج ====================
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_filteredCourses.length} results found',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),

          const SizedBox(height: 8),

          // ==================== قائمة الكورسات ====================
          Expanded(
            child: _filteredCourses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No courses found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear search'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return _buildCourseCardFull(
                  courseName: course['name'] as String,
                  trainerName: course['trainer'] as String,
                  progress: course['progress'] as int,
                  hours: course['hours'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء بطاقة الكورس الكاملة
  Widget _buildCourseCardFull({
    required String courseName,
    required String trainerName,
    required int progress,
    required String hours,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي: أيقونة + اسم الكورس + الوقت
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.deepPurple,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trainerName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.deepPurple),
                    const SizedBox(width: 4),
                    Text(
                      hours,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // شريط التقدم
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.deepPurple,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // زر متابعة
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // هنا توجيه لصفحة تفاصيل الكورس
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue Learning'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== كلاس مخصص للبحث المتقدم (اختياري) ====================
class CourseSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> courses;

  CourseSearchDelegate(this.courses);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = courses.where((course) {
      return course['name'].toLowerCase().contains(query.toLowerCase()) ||
          course['trainer'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return ListTile(
          leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
          title: Text(course['name']),
          subtitle: Text(course['trainer']),
          trailing: Text('${course['progress']}%'),
          onTap: () {
            close(context, null);
            // هنا توجيه لصفحة تفاصيل الكورس
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = courses.where((course) {
      return course['name'].toLowerCase().contains(query.toLowerCase()) ||
          course['trainer'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final course = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
          title: Text(course['name']),
          subtitle: Text(course['trainer']),
          trailing: Text('${course['progress']}%'),
          onTap: () {
            query = course['name'];
            showResults(context);
          },
        );
      },
    );
  }
}

// ==================== صفحة فرص العمل (Job Opportunities) ====================
class JobOpportunitiesPage extends StatefulWidget {
  const JobOpportunitiesPage({super.key});

  @override
  State<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  // متغير للبحث
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // متغير للفلترة حسب النوع
  String _selectedFilter = 'All';

  // قائمة أنواع الوظائف للفلترة
  final List<String> _filters = ['All', 'Remote', 'Full-time', 'Part-time', 'Internship'];

  // بيانات فرص العمل (بدون const)
  final List<Map<String, dynamic>> allJobs = [
    {
      'title': 'Flutter Developer',
      'company': 'Tech Solutions',
      'location': 'Remote',
      'type': 'Full-time',
      'salary': '\$5,000 - \$7,000',
      'description': 'We are looking for a skilled Flutter developer to join our team...',
      'requirements': '3+ years experience in Flutter, Dart, API integration',
      'postedDate': '2 days ago',
      'logo': Icons.code,
      'color': 0xFF6C63FF,
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Creative Studio',
      'location': 'Dubai, UAE',
      'type': 'Full-time',
      'salary': '\$4,000 - \$6,000',
      'description': 'Seeking a creative UI/UX designer with a passion for beautiful designs...',
      'requirements': 'Figma, Adobe XD, portfolio required',
      'postedDate': '5 days ago',
      'logo': Icons.design_services,
      'color': 0xFFFF6B6B,
    },
    {
      'title': 'Backend Developer',
      'company': 'Cloud Systems',
      'location': 'Remote',
      'type': 'Remote',
      'salary': '\$6,000 - \$8,000',
      'description': 'Looking for backend developer experienced in Node.js and databases...',
      'requirements': 'Node.js, MongoDB, Express, API design',
      'postedDate': '1 week ago',
      'logo': Icons.cloud,
      'color': 0xFF4ECDC4,
    },
    {
      'title': 'Product Manager',
      'company': 'Startup Hub',
      'location': 'Riyadh, KSA',
      'type': 'Full-time',
      'salary': '\$7,000 - \$10,000',
      'description': 'Lead product development and coordinate with cross-functional teams...',
      'requirements': '3+ years product management experience, Agile methodology',
      'postedDate': '3 days ago',
      'logo': Icons.analytics,
      'color': 0xFFFFB347,
    },
    {
      'title': 'Frontend Intern',
      'company': 'Web Masters',
      'location': 'Remote',
      'type': 'Internship',
      'salary': '\$1,000 - \$1,500',
      'description': 'Learn and grow with our frontend team. Great opportunity for fresh graduates...',
      'requirements': 'HTML, CSS, JavaScript basics',
      'postedDate': '1 day ago',
      'logo': Icons.web,
      'color': 0xFF9B59B6,
    },
    {
      'title': 'Data Analyst',
      'company': 'Data Corp',
      'location': 'Abu Dhabi, UAE',
      'type': 'Part-time',
      'salary': '\$3,000 - \$4,500',
      'description': 'Analyze data and create reports for business decisions...',
      'requirements': 'SQL, Python, Excel, Power BI',
      'postedDate': '4 days ago',
      'logo': Icons.bar_chart,
      'color': 0xFF2ECC71,
    },
    {
      'title': 'Mobile Developer (iOS)',
      'company': 'App Factory',
      'location': 'Remote',
      'type': 'Full-time',
      'salary': '\$5,500 - \$7,500',
      'description': 'Develop high-quality iOS applications using Swift...',
      'requirements': 'Swift, iOS SDK, MVVM pattern',
      'postedDate': '6 days ago',
      'logo': Icons.phone_iphone,
      'color': 0xFFE74C3C,
    },
    {
      'title': 'DevOps Engineer',
      'company': 'Tech Innovators',
      'location': 'Dubai, UAE',
      'type': 'Remote',
      'salary': '\$8,000 - \$11,000',
      'description': 'Manage cloud infrastructure and CI/CD pipelines...',
      'requirements': 'AWS, Docker, Kubernetes, Jenkins',
      'postedDate': '2 weeks ago',
      'logo': Icons.devices,
      'color': 0xFF1ABC9C,
    },
  ];

  // دالة لفلترة الوظائف حسب البحث والنوع
  List<Map<String, dynamic>> get _filteredJobs {
    var jobs = List<Map<String, dynamic>>.from(allJobs);

    // فلترة حسب النوع
    if (_selectedFilter != 'All') {
      jobs = jobs.where((job) => job['type'] == _selectedFilter).toList();
    }

    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      jobs = jobs.where((job) {
        return job['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job['company'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return jobs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Opportunities',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by job title, company, or location...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // أزرار الفلترة
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepPurple : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isSelected ? Colors.deepPurple : Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // عدد النتائج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredJobs.length} jobs found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (_selectedFilter != 'All' || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear all filters'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // قائمة الوظائف
          Expanded(
            child: _filteredJobs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return _buildJobCard(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء بطاقة الوظيفة
  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailPage(job: job),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(job['color']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        job['logo'] as IconData,
                        color: Color(job['color']),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job['company'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(job['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        job['type'],
                        style: TextStyle(
                          fontSize: 11,
                          color: _getTypeColor(job['type']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      job['location'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      job['salary'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      job['postedDate'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  job['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailPage(job: job),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: const Text('Apply Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لتحديد لون نوع الوظيفة
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Remote':
        return Colors.green;
      case 'Full-time':
        return Colors.blue;
      case 'Part-time':
        return Colors.orange;
      case 'Internship':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// ==================== صفحة تفاصيل الوظيفة ====================
class JobDetailPage extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          job['title'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(job['color']).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      job['logo'] as IconData,
                      color: Color(job['color']),
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['company'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(job['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job['type'],
                      style: TextStyle(
                        color: _getTypeColor(job['type']),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          Icons.location_on,
                          'Location',
                          job['location'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.attach_money,
                          'Salary',
                          job['salary'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    Icons.access_time,
                    'Posted',
                    job['postedDate'],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['requirements'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showApplyDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Remote':
        return Colors.green;
      case 'Full-time':
        return Colors.blue;
      case 'Part-time':
        return Colors.orange;
      case 'Internship':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apply for this job'),
          content: const Text('Are you sure you want to apply for this position? We will notify the employer about your interest.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
// ==================== صفحة مشاريع الطلاب (Students Projects) ====================
class StudentsProjectsPage extends StatefulWidget {
  const StudentsProjectsPage({super.key});

  @override
  State<StudentsProjectsPage> createState() => _StudentsProjectsPageState();
}

class _StudentsProjectsPageState extends State<StudentsProjectsPage> {
  // متغير لتخزين المشاريع القادمة من API
  List<Map<String, dynamic>> projects = [];

  // متغير لحالة التحميل
  bool isLoading = true;

  // متغير للخطأ
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  // دالة لجلب المشاريع من الباك اند
  Future<void> _fetchProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      projects = [
        {
          'title': 'EcoTrack App',
          'studentName': 'Ahmed Mansour',
          'description': 'An app that helps users track their carbon footprint',
          'imageUrl': 'https://picsum.photos/id/1/400/300',
        },
        {
          'title': 'Smart Home',
          'studentName': 'Lina Hassan',
          'description': 'Control smart home devices remotely',
          'imageUrl': 'https://picsum.photos/id/2/400/300',
        },
        {
          'title': 'MediAssist AI',
          'studentName': 'Omar Khalid',
          'description': 'AI-powered medical assistant',
          'imageUrl': 'https://picsum.photos/id/3/400/300',
        },
        {
          'title': 'Food Delivery',
          'studentName': 'Sara Ahmed',
          'description': 'Fast food delivery application',
          'imageUrl': 'https://picsum.photos/id/4/400/300',
        },
        {
          'title': 'Portfolio Gen',
          'studentName': 'Nour ElDin',
          'description': 'Generate beautiful portfolios',
          'imageUrl': 'https://picsum.photos/id/5/400/300',
        },
        {
          'title': 'Space Shooter',
          'studentName': 'Ali Mohammed',
          'description': 'Exciting space shooter game',
          'imageUrl': 'https://picsum.photos/id/6/400/300',
        },
        {
          'title': 'Weather AI',
          'studentName': 'Mariam Adel',
          'description': 'Weather predictions using AI',
          'imageUrl': 'https://picsum.photos/id/7/400/300',
        },
        {
          'title': 'UI Library',
          'studentName': 'Hassan Ali',
          'description': 'UI component library for Flutter',
          'imageUrl': 'https://picsum.photos/id/8/400/300',
        },
      ];
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Students Projects',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            Text('Loading projects...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProjects,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No projects found'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(
          title: project['title'] as String,
          studentName: project['studentName'] as String,
          description: project['description'] as String,
          imageUrl: project['imageUrl'] as String?,
        );
      },
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String studentName,
    required String description,
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        // فتح صفحة تفاصيل المشروع مع الصورة الكاملة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailPage(
              title: title,
              studentName: studentName,
              description: description,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
                  : _buildPlaceholderImage(),
            ),
            // اسم المشروع واسم الطالب
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // صورة افتراضية إذا فشل تحميل الصورة
  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Icon(
        Icons.image,
        size: 40,
        color: Colors.deepPurple,
      ),
    );
  }
}

// ==================== صفحة تفاصيل المشروع (مع صورة كاملة) ====================
class ProjectDetailPage extends StatelessWidget {
  final String title;
  final String studentName;
  final String description;
  final String? imageUrl;

  const ProjectDetailPage({
    super.key,
    required this.title,
    required this.studentName,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة الكاملة في الأعلى
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                imageUrl!,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.deepPurple.withOpacity(0.5),
                ),
              ),
            ),

            // معلومات المشروع
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان المشروع
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // اسم الطالب
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              studentName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}