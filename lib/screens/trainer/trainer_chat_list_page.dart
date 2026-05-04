// 📄 lib/screens/trainer/trainer_chat_list_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trainer_chat_page.dart';

class TrainerChatListPage extends StatefulWidget {
  const TrainerChatListPage({super.key});

  @override
  State<TrainerChatListPage> createState() => _TrainerChatListPageState();
}

class _TrainerChatListPageState extends State<TrainerChatListPage> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> chats = [
    {'id': 'stu_001', 'name': 'Ahmed Mohamed', 'message': 'Can I postpone the project submission?', 'time': '10:30 AM', 'avatar': 'A', 'unread': true},
    {'id': 'stu_002', 'name': 'Sara Ali', 'message': 'Thank you, I understood the lesson well', 'time': 'Yesterday', 'avatar': 'S', 'unread': true},
    {'id': 'stu_003', 'name': 'Khaled Yousef', 'message': 'The session link is not working for me', 'time': 'Yesterday', 'avatar': 'K', 'unread': true},
    {'id': 'stu_004', 'name': 'Layla Hassan', 'message': 'Project uploaded successfully ✅', 'time': 'Monday', 'avatar': 'L', 'unread': true},
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadStates();
  }

  Future<void> _loadUnreadStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var chat in chats) {
        final id = chat['id'] as String;
        final isRead = prefs.getBool('read_$id') ?? false;
        chat['unread'] = !isRead;
      }
    });
  }

  void _markAsRead(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('read_$studentId', true);

    if (mounted) {
      setState(() {
        final index = chats.indexWhere((c) => c['id'] == studentId);
        if (index != -1) {
          chats[index]['unread'] = false;
        }
      });
    }
  }

  void _updateChatAfterSend(String studentId, String lastMsg, String newTime) {
    if (mounted) {
      setState(() {
        final index = chats.indexWhere((c) => c['id'] == studentId);
        if (index != -1) {
          chats[index]['message'] = lastMsg;
          chats[index]['time'] = newTime;
          final updatedChat = chats.removeAt(index);
          chats.insert(0, updatedChat);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = chats.where((chat) {
      return chat['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredChats.isEmpty
                ? Center(
              child: Text(
                'No conversations found',
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
                : ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainerChatDetailPage(
                          name: chat['name'],
                          avatar: chat['avatar'],
                          studentId: chat['id'],
                          onChatUpdated: _updateChatAfterSend,
                        ),
                      ),
                    );
                    _markAsRead(chat['id']);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        child: Text(
                          chat['avatar'],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      title: Text(
                        chat['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        chat['message'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            chat['time'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (chat['unread'] == true)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}