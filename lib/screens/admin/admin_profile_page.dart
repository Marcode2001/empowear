// 📄 lib/screens/admin/admin_profile_page.dart
// ============================================================
// 👤 صفحة بروفايل الأدمن
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String adminName = 'Admin';
    String adminEmail = 'admin@empower.com';

    if (authState is AuthAuthenticated) {
      adminName = authState.user.name;
      adminEmail = authState.user.email;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // 👤 صورة البروفايل
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                adminName[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 📝 اسم الأدمن والإيميل
          Text(adminName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(adminEmail, style: TextStyle(fontSize: 14, color: Colors.grey[600])),

          const SizedBox(height: 32),

          // ⚙️ قائمة الإعدادات
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: Column(
              children: [
                _buildProfileOption(Icons.person, 'Edit Profile', () {}),
                _buildProfileOption(Icons.lock, 'Change Password', () {}),
                _buildProfileOption(Icons.notifications, 'Notifications', () {}),
                _buildProfileOption(Icons.language, 'Language', () {}),
                _buildProfileOption(Icons.privacy_tip, 'Privacy Settings', () {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🚪 زر تسجيل الخروج
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutConfirm(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⚙️ خيار في البروفايل
  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.deepPurple, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 🚪 تأكيد تسجيل الخروج
  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}