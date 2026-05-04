import 'package:flutter/material.dart';
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