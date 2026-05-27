// 📄 lib/screens/trainee/content_viewer_page.dart
// ============================================================
// 🖼️ صفحة عرض المحتوى - نسخة متكاملة مع تعليقات
// تدعم: PDF, Video, Image
// ============================================================

// استيراد المكتبات المطلوبة
import 'dart:io';                              // للتعامل مع الملفات
import 'package:flutter/material.dart';        // واجهات Flutter
import 'package:video_player/video_player.dart'; // تشغيل الفيديو
import 'package:chewie/chewie.dart';           // واجهة تحكم متقدمة للفيديو
import 'package:http/http.dart' as http;       // طرق HTTP (لتحميل PDF)
import 'package:path_provider/path_provider.dart'; // الحصول على مسار التخزين المؤقت
import 'package:open_file/open_file.dart';     // فتح الملفات الخارجية (PDF)
import '../../models/course_models.dart';       // نماذج البيانات الخاصة بالكورس

// ============================================================
// الواجهة الرئيسية للصفحة
// ============================================================
class ContentViewerPage extends StatefulWidget {
  final CourseContent content;  // المحتوى المراد عرضه (PDF/فيديو/صورة)

  const ContentViewerPage({super.key, required this.content});

  @override
  State<ContentViewerPage> createState() => _ContentViewerPageState();
}

// ============================================================
// حالة الصفحة (State) - تحتوي على المنطق الرئيسي
// ============================================================
class _ContentViewerPageState extends State<ContentViewerPage> {
  // متحكم الفيديو - يستخدم لتشغيل وإيقاف والتحكم بالفيديو
  VideoPlayerController? _videoController;

  // متحكم Chewie - يضيف واجهة تحكم احترافية (أزرار تقدم، كتم، شاشة كاملة)
  ChewieController? _chewieController;

  // متغير يشير إلى ما إذا كان المحتوى قيد التحميل
  bool _isLoading = true;

  // رسالة الخطأ - تظهر عند فشل التحميل
  String? _errorMessage;

  // ==========================================================
  // دورة حياة الصفحة: تُستدعى عند إنشاء الصفحة
  // ==========================================================
  @override
  void initState() {
    super.initState();
    // نستخدم WidgetsBinding لتنفيذ الكود بعد اكتمال بناء الواجهة
    // هذا يضمن أن Context جاهز قبل تنفيذ العمليات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleContent();  // معالجة المحتوى حسب نوعه
    });
  }

  // ==========================================================
  // دورة حياة الصفحة: تُستدعى عند تدمير الصفحة
  // نقوم بتحرير الموارد لتجنب تسرب الذاكرة
  // ==========================================================
  @override
  void dispose() {
    _videoController?.dispose();    // تحرير متحكم الفيديو
    _chewieController?.dispose();   // تحرير متحكم Chewie
    super.dispose();
  }

  // ==========================================================
  // المعالج الرئيسي: يقرر كيفية عرض المحتوى حسب نوعه
  // ==========================================================
  Future<void> _handleContent() async {
    final bool isPdf = widget.content.type == 'pdf';      // هل هو PDF؟
    final bool isVideo = widget.content.type == 'video';  // هل هو فيديو؟

    if (isPdf) {
      // PDF: تحميل وفتح في تطبيق خارجي
      await _downloadAndOpenPdf(widget.content.fullUrl);
    } else if (isVideo) {
      // فيديو: تشغيل داخل التطبيق
      await _initVideoPlayer();
    } else {
      // أنواع أخرى (صور، نص، إلخ)
      setState(() => _isLoading = false);
    }
  }

  // ==========================================================
  // تشغيل الفيديو باستخدام VideoPlayer + Chewie
  // Chewie يوفر: شريط تقدم، أزرار تحكم، شاشة كاملة، تغيير السرعة
  // ==========================================================
  // ==========================================================
// تشغيل الفيديو باستخدام VideoPlayer + Chewie
// مع إزالة زر Cancel من قائمة السرعة
// ==========================================================
  // ==========================================================
// تشغيل الفيديو - نسخة بدون زر Cancel
// ==========================================================
  Future<void> _initVideoPlayer() async {
    final String url = widget.content.fullUrl;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();

      print('🎬 Video duration: ${_videoController!.value.duration}');

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,  // ❌ تعطيل تغيير السرعة (يزيل زر السرعة وزر Cancel)
        showControls: true,
        showOptions: false,  // ❌ إخفاء قائمة الخيارات
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.deepPurple,
          handleColor: Colors.deepPurple,
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.purple.shade300,
        ),
      );

      setState(() {
        _isLoading = false;
      });

      print('✅ Video player initialized: $url');
    } catch (e) {
      print('❌ Video Error: $e');
      setState(() {
        _errorMessage = 'Failed to load video: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  // ==========================================================
  // تحميل وفتح ملف PDF
  // ==========================================================
  Future<void> _downloadAndOpenPdf(String url) async {
    // بدء التحميل
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // عرض رسالة للمستخدم: "جاري التحميل"
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading PDF...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // تحميل الملف من الخادم باستخدام HTTP GET
      final response = await http.get(Uri.parse(url));

      // التحقق من نجاح التحميل
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF (Status: ${response.statusCode})');
      }

      // الحصول على المجلد المؤقت للتطبيق
      final dir = await getTemporaryDirectory();

      // إنشاء اسم فريد للملف باستخدام الوقت الحالي
      final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // إنشاء الملف في المجلد المؤقت
      final file = File('${dir.path}/$fileName');

      // كتابة بيانات PDF إلى الملف
      await file.writeAsBytes(response.bodyBytes);

      print('✅ PDF downloaded to: ${file.path}');

      // فتح الملف باستخدام التطبيق الافتراضي لقراءة PDF
      final result = await OpenFile.open(file.path);

      // التحقق من نتيجة الفتح
      if (result.type == ResultType.done) {
        print('✅ PDF opened successfully');
        // العودة إلى الصفحة السابقة بعد الفتح
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Cannot open PDF: ${result.message}');
      }
    } catch (e) {
      // في حالة حدوث خطأ أثناء التحميل أو الفتح
      print('❌ PDF Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });

        // عرض رسالة خطأ للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ==========================================================
  // بناء واجهة المستخدم (UI)
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    // تحديد نوع المحتوى
    final bool isPdf = widget.content.type == 'pdf';
    final bool isVideo = widget.content.type == 'video';
    final bool isImage = widget.content.type == 'image';
    final String url = widget.content.fullUrl;

    return Scaffold(
      // شريط التطبيق العلوي (AppBar)
      appBar: AppBar(
        title: Text(
          widget.content.title,  // عنوان المحتوى
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        // خلفية متدرجة
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
        actions: [
          // زر إعادة المحاولة لـ PDF عند وجود خطأ
          if (isPdf && _errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _downloadAndOpenPdf(url),
              tooltip: 'Retry',
            ),
          // زر إعادة المحاولة للفيديو عند وجود خطأ
          if (isVideo && _errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _initVideoPlayer(),
              tooltip: 'Retry',
            ),
        ],
      ),
      // محتوى الصفحة الرئيسي
      body: SafeArea(
        // SafeArea يمنع تداخل المحتوى مع أزرار النظام (شريط الحالة، شريط التنقل)
        child: Container(
          color: Colors.black,  // خلفية سوداء
          child: _buildContentByType(url, isPdf, isVideo, isImage),
        ),
      ),
    );
  }

  // ==========================================================
  // بناء المحتوى حسب النوع (PDF / فيديو / صورة)
  // ==========================================================
  Widget _buildContentByType(String url, bool isPdf, bool isVideo, bool isImage) {

    // ----- حالة PDF: جاري التحميل -----
    if (isPdf && _isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ----- حالة PDF: خطأ في التحميل -----
    if (isPdf && _errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to open PDF',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // زر إعادة المحاولة
            ElevatedButton.icon(
              onPressed: () => _downloadAndOpenPdf(url),
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // ----- حالة الفيديو -----
    if (isVideo) {
      // عرض شاشة الخطأ إذا فشل التحميل
      if (_errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _initVideoPlayer(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      // عرض شاشة التحميل أثناء تجهيز الفيديو
      if (_isLoading) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Preparing video...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      // عرض مشغل الفيديو مع تحكمات Chewie
      if (_chewieController != null) {
        // إضافة مسافة صغيرة أسفل الفيديو لمنع التداخل مع أزرار النظام
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Chewie(
            controller: _chewieController!,
          ),
        );
      }
    }

    // ----- حالة الصور -----
    if (isImage && url.isNotEmpty) {
      // InteractiveViewer يسمح بالتكبير والتصغير والتحريك
      return InteractiveViewer(
        minScale: 0.5,   // أصغر تكبير (50%)
        maxScale: 4.0,   // أكبر تكبير (400%)
        child: Image.network(
          url,
          fit: BoxFit.contain,  // عرض الصورة كاملة دون قص
          loadingBuilder: (context, child, loadingProgress) {
            // أثناء تحميل الصورة: عرض مؤشر التقدم
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // في حالة فشل تحميل الصورة: عرض أيقونة خطأ
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // ----- الحالة الافتراضية (لا يوجد محتوى صالح للعرض) -----
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No valid content to display',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}