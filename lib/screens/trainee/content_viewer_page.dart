// 📄 lib/screens/trainee/content_viewer_page.dart
// ============================================================
// 🖼️ صفحة عرض المحتوى (PDF, صور, فيديو)
// ============================================================
// هذه الصفحة تعرض الملف (PDF، فيديو، صورة) عند الضغط على الدرس

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/course_models.dart';

class ContentViewerPage extends StatelessWidget {
  // الكائن الذي نريد عرضه (يحتوي على رابط الملف)
  final CourseContent content;

  const ContentViewerPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // 🔍 للتصحيح: نطبع رابط الملف في الكونسول لنرى القيمة الحقيقية
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📁 [ContentViewerPage] عنوان الملف الخام: ${content.fileUrl}');
    print('📁 [ContentViewerPage] الرابط الكامل: ${content.fullUrl}');
    print('📁 [ContentViewerPage] نوع الملف: ${content.contentType}');
    print('📁 [ContentViewerPage] هل يوجد ملف: ${content.hasFile}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return Scaffold(
      // شريط العنوان العلوي
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      // محتوى الصفحة
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎨 أيقونة كبيرة حسب نوع المحتوى
              Icon(
                content.icon,
                size: 80,
                color: content.color,
              ),
              const SizedBox(height: 24),

              // 📝 عنوان المحتوى
              Text(
                content.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 🏷️ نوع المحتوى (PDF, VIDEO, IMAGE)
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

              // 🔗 عرض رابط الملف (للنسخ أو التصحيح)
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
                      content.fileUrl ?? 'لا يوجد رابط',
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 🚀 زر فتح الملف (يظهر فقط إذا كان هناك ملف)
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

              // ⚠️ رسالة إذا لم يوجد ملف
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

  // ============================================================
  // 🚀 دالة فتح الملف (تستخدم url_launcher)
  // ============================================================
  Future<void> _openFile(BuildContext context) async {
    // التأكد من وجود ملف
    if (!content.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد ملف لعرضه'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ استخدام الرابط الكامل من النموذج
    final String url = content.fullUrl;

    print('🚀 [ContentViewerPage] محاولة فتح الرابط: $url');

    try {
      // تحويل الرابط إلى Uri
      final uri = Uri.parse(url);

      // التحقق من إمكانية فتح الرابط
      if (await canLaunchUrl(uri)) {
        // فتح الرابط في المتصفح أو التطبيق المناسب
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('✅ [ContentViewerPage] تم فتح الرابط بنجاح');
      } else {
        throw 'لا يمكن فتح الرابط $url';
      }
    } catch (e) {
      print('❌ [ContentViewerPage] فشل فتح الملف: $e');

      // عرض رسالة خطأ للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل فتح الملف: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      // عرض رابط الملف في رسالة منفصلة للتصحيح
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('رابط الملف'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    }
  }
}