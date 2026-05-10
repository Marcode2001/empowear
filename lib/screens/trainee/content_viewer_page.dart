// 📄 lib/screens/trainee/content_viewer_page.dart
// ============================================================
// 🖼️ صفحة عرض المحتوى (PDF, صور, فيديو)
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';  // ✅ تأكد من وجود هذا الاستيراد
import '../../models/course_models.dart';

class ContentViewerPage extends StatelessWidget {
  final CourseContent content;

  const ContentViewerPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // أيقونة كبيرة حسب نوع المحتوى
              Icon(
                content.icon,
                size: 80,
                color: content.color,
              ),
              const SizedBox(height: 24),

              // عنوان المحتوى
              Text(
                content.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // نوع المحتوى
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: content.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'النوع: ${content.contentType.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: content.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // رابط الملف (للنسخ)
              if (content.hasFile)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'رابط الملف:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        content.fileUrl!,
                        style: const TextStyle(fontSize: 11, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // زر فتح الملف
              if (content.hasFile)
                ElevatedButton.icon(
                  onPressed: () => _openFile(context),
                  icon: const Icon(Icons.open_in_browser, size: 20),
                  label: const Text(
                    'فتح الملف',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: content.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

              // رسالة إذا لم يوجد ملف
              if (!content.hasFile)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'لا يوجد ملف لعرضه',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ دالة فتح الملف
  Future<void> _openFile(BuildContext context) async {
    if (!content.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد ملف لعرضه'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String url = content.fileUrl!;

    // ⚠️ غير هذا الرابط حسب عنوان جهازك
    const String baseUrl = 'http://192.168.1.22:8000';

    final String fullUrl = url.startsWith('http')
        ? url
        : '$baseUrl$url';

    try {
      final uri = Uri.parse(fullUrl);

      // ✅ استخدام canLaunchUrl و launchUrl (موجودين في url_launcher)
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'لا يمكن فتح الرابط';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل فتح الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}