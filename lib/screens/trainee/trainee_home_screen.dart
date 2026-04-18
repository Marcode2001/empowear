import 'package:flutter/material.dart';

class TraineeHomeScreen extends StatefulWidget {
  const TraineeHomeScreen({super.key});

  @override
  State<TraineeHomeScreen> createState() => _TraineeHomeScreenState();
}

class _TraineeHomeScreenState extends State<TraineeHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MyCoursesPage(),
    const UploadProjectPage(),
    const ProjectsUploadedPage(),
    const ChatsPage(),
  ];

  final List<String> _titles = [
    'My Courses',
    'Upload Project',
    'Projects Uploaded',
    'Chats',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}

// ==================== صفحة My Courses ====================
class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
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
        const SizedBox(height: 16),
        _buildCourseCard('CourseName', 'Trainee name'),
        _buildCourseCard('CourseName', 'Trainee name'),
        _buildCourseCard('CourseName', 'Trainee name'),
        _buildCourseCard('CourseName', 'Trainee name'),
      ],
    );
  }

  Widget _buildCourseCard(String courseName, String traineeName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu_book, color: Colors.deepPurple),
        ),
        title: Text(courseName),
        subtitle: Text(traineeName),
        trailing: const Text('30 Students'),
        onTap: () {},
      ),
    );
  }
}

// ==================== صفحة Upload Project ====================
class UploadProjectPage extends StatelessWidget {
  const UploadProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Upload Project', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Enter Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== صفحة Projects Uploaded ====================
class ProjectsUploadedPage extends StatelessWidget {
  const ProjectsUploadedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProjectCard('Student Name', 'Project Name'),
        _buildProjectCard('Student Name', 'Project Name'),
        _buildProjectCard('Student Name', 'Project Name'),
        _buildProjectCard('Student Name', 'Project Name'),
      ],
    );
  }

  Widget _buildProjectCard(String studentName, String projectName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, color: Colors.deepPurple),
        ),
        title: Text(projectName),
        subtitle: Text(studentName),
        trailing: const Icon(Icons.visibility),
        onTap: () {},
      ),
    );
  }
}

// ==================== صفحة Chats ====================
class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Expanded(
          child: ListView(
            children: [
              _buildChatTile('starrysKies23', 'HI', '9:41 AM'),
              _buildChatTile('starrysKies23', 'HI', '9:41 AM'),
              _buildChatTile('starrysKies23', 'HI', '9:41 AM'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(String name, String message, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.withOpacity(0.2),
        child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.deepPurple)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      onTap: () {},
    );
  }
}