// 📄 lib/screens/trainee/content_viewer_page.dart
// ============================================================
// 🖼️ صفحة عرض المحتوى داخل التطبيق (PDF, صور, فيديو)
// ============================================================

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/course_models.dart';

class ContentViewerPage extends StatelessWidget {
  final CourseContent content;

  const ContentViewerPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final String url = content.fullUrl;
    final bool isPdf = content.type == 'pdf';
    final bool isVideo = content.type == 'video';
    final bool isImage = content.type == 'image';

    print('🎬 [ContentViewer] Opening: $url');
    print('🎬 [ContentViewer] Type: ${content.type}');

    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          // زر مشاركة الرابط
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // يمكن إضافة مشاركة الرابط لاحقاً
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black87,
        child: Center(
          child: _buildContentByType(url, isPdf, isVideo, isImage, context),
        ),
      ),
    );
  }

  Widget _buildContentByType(
      String url,
      bool isPdf,
      bool isVideo,
      bool isImage,
      BuildContext context,
      ) {
    // ✅ عرض PDF باستخدام WebView
    if (isPdf && url.isNotEmpty) {
      return WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                print('📄 Loading PDF: $url');
              },
              onPageFinished: (String url) {
                print('✅ PDF loaded: $url');
              },
              onWebResourceError: (WebResourceError error) {
                print('❌ PDF Error: ${error.description}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading PDF: ${error.description}')),
                );
              },
            ),
          )
          ..loadRequest(Uri.parse(url)),
      );
    }

    // ✅ عرض فيديو باستخدام WebView (يدعم تشغيل الفيديو)
    if (isVideo && url.isNotEmpty) {
      return WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                print('🎬 Loading Video: $url');
              },
              onPageFinished: (String url) {
                print('✅ Video loaded: $url');
              },
              onWebResourceError: (WebResourceError error) {
                print('❌ Video Error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(url)),
      );
    }

    // ✅ عرض صورة
    if (isImage && url.isNotEmpty) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // محاولة إعادة تحميل الصفحة
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                ),
              ],
            );
          },
        ),
      );
    }

    // ✅ إذا لم يوجد رابط أو نوع غير معروف
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No valid content to display',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'URL: $url',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go Back'),
        ),
      ],
    );
  }
}