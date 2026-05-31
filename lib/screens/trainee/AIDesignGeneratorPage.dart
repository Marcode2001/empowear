// 📄 lib/screens/trainee/ai_design_generator_page.dart
// ============================================================
// 🎨 صفحة توليد تصاميم الأزياء بالذكاء الاصطناعي
// ============================================================

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../repositories/ai_repository.dart';

class AIDesignGeneratorPage extends StatefulWidget {
  const AIDesignGeneratorPage({super.key});

  @override
  State<AIDesignGeneratorPage> createState() => _AIDesignGeneratorPageState();
}

class _AIDesignGeneratorPageState extends State<AIDesignGeneratorPage> {
  final AIRepository _aiRepository = AIRepository();

  // ✅ متغيرات الحالة
  File? _selectedImage;
  bool _isLoading = false;
  String? _generatedResult;
  bool _is3DResult = false;
  String? _resultImageUrl;

  // ✅ متغيرات النص
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  String _enteredSeason = '';
  String _seasonError = '';

  // ✅ قائمة الفصول المسموحة
  final List<String> _validSeasons = ['spring', 'summer', 'autumn', 'winter'];
  final Map<String, String> _seasonDisplayNames = {
    'spring': 'Spring',
    'summer': 'Summer',
    'autumn': 'Autumn',
    'winter': 'Winter',
  };

  @override
  void dispose() {
    _seasonController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  // ✅ التحقق من صحة الفصل
  String? _validateAndNormalizeSeason(String input) {
    if (input.isEmpty) return null;
    final trimmed = input.trim().toLowerCase();
    for (var validSeason in _validSeasons) {
      if (trimmed == validSeason) {
        return _seasonDisplayNames[validSeason];
      }
    }
    return null;
  }

  // ✅ معالجة تغيير الفصل
  void _onSeasonChanged(String value) {
    setState(() {
      final normalized = _validateAndNormalizeSeason(value);
      if (normalized != null) {
        _enteredSeason = normalized;
        _seasonError = '';
      } else {
        _enteredSeason = '';
        _seasonError = 'Please enter Spring, Summer, Autumn, or Winter';
      }
    });
  }

  // ✅ اختيار صورة من المعرض
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _generatedResult = null;
        _is3DResult = false;
        _resultImageUrl = null;
      });
    }
  }

  // ✅ التقاط صورة من الكاميرا
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _generatedResult = null;
        _is3DResult = false;
        _resultImageUrl = null;
      });
    }
  }

  // ============================================================
  // ✅ دالة استخراج البيانات الحقيقية
  // ============================================================

  Map<String, dynamic> _extractRealData(Map<String, dynamic> response) {
    print('🔍 Extracting real data from response...');

    if (response.containsKey('data') && response['data'] is Map) {
      final firstLevel = response['data'] as Map;

      if (firstLevel.containsKey('data') && firstLevel['data'] is Map) {
        print('✅ Found nested data (2 levels deep)');
        return Map<String, dynamic>.from(firstLevel['data']);
      }

      print('✅ Found data at level 1');
      return Map<String, dynamic>.from(firstLevel);
    }

    print('✅ No data wrapper, using root');
    return response;
  }

  /// 🎨 دالة لاستخراج الألوان الموسمية
  List<String> _extractSeasonalColors(Map<String, dynamic> data) {
    print('🔍 Looking for seasonal colors...');

    if (data.containsKey('seasonal_suggestion')) {
      final seasonal = data['seasonal_suggestion'];
      if (seasonal is Map) {
        if (seasonal.containsKey('colors_en')) {
          print('✅ Found seasonal colors in root.seasonal_suggestion.colors_en');
          return List<String>.from(seasonal['colors_en']);
        }
        if (seasonal.containsKey('colors')) {
          print('✅ Found seasonal colors in root.seasonal_suggestion.colors');
          return List<String>.from(seasonal['colors']);
        }
      }
    }

    if (data.containsKey('nlp') && data['nlp'] is Map) {
      final nlp = data['nlp'];
      if (nlp.containsKey('seasonal_suggestion')) {
        final seasonal = nlp['seasonal_suggestion'];
        if (seasonal is Map) {
          if (seasonal.containsKey('colors_en')) {
            print('✅ Found seasonal colors in nlp.seasonal_suggestion.colors_en');
            return List<String>.from(seasonal['colors_en']);
          }
          if (seasonal.containsKey('colors')) {
            print('✅ Found seasonal colors in nlp.seasonal_suggestion.colors');
            return List<String>.from(seasonal['colors']);
          }
        }
      }
    }

    print('❌ No seasonal colors found');
    return [];
  }

  /// 🔥 دالة لاستخراج الألوان الترند
  List<String> _extractTrendingColors(Map<String, dynamic> data) {
    print('🔍 Looking for trending colors...');

    if (data.containsKey('trending_now')) {
      final trending = data['trending_now'];
      if (trending is Map && trending.containsKey('palette')) {
        print('✅ Found trending colors in root.trending_now.palette');
        return List<String>.from(trending['palette']);
      }
    }

    if (data.containsKey('nlp') && data['nlp'] is Map) {
      final nlp = data['nlp'];
      if (nlp.containsKey('trending_now')) {
        final trending = nlp['trending_now'];
        if (trending is Map && trending.containsKey('palette')) {
          print('✅ Found trending colors in nlp.trending_now.palette');
          return List<String>.from(trending['palette']);
        }
      }
    }

    print('❌ No trending colors found');
    return [];
  }

  /// 📝 دالة لاستخراج التحليل النصي
  List<Map<String, dynamic>> _extractAnalysisResults(Map<String, dynamic> data) {
    List<Map<String, dynamic>> results = [];

    if (data.containsKey('analysis_results') && data['analysis_results'] is List) {
      for (var item in data['analysis_results']) {
        if (item is Map) {
          results.add(Map<String, dynamic>.from(item));
        }
      }
    }

    if (data.containsKey('nlp') && data['nlp'] is Map) {
      final nlp = data['nlp'];
      if (nlp.containsKey('analysis_results') && nlp['analysis_results'] is List) {
        for (var item in nlp['analysis_results']) {
          if (item is Map) {
            results.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }

    return results;
  }

  /// 🖼️ دالة لاستخراج رابط الـ 3D
  String? _extractResultUrl(Map<String, dynamic> data) {
    if (data.containsKey('glb') && data['glb'] != null) {
      return data['glb'].toString();
    }

    if (data.containsKey('model_url') && data['model_url'] != null) {
      return data['model_url'].toString();
    }

    if (data.containsKey('cv') && data['cv'] is Map) {
      final cv = data['cv'];
      if (cv.containsKey('model_url') && cv['model_url'] != null) {
        return cv['model_url'].toString();
      }
      if (cv.containsKey('glb_url') && cv['glb_url'] != null) {
        return cv['glb_url'].toString();
      }
    }

    return null;
  }

  // ============================================================
  // ✅ دالة توليد النتيجة الرئيسية (المعدلة)
  // ============================================================
  Future<void> _generateOutput() async {
    final seasonInput = _seasonController.text.trim();
    final textInput = _promptController.text.trim();

    // =========================
    // 1. التحقق من صحة الفصل
    // =========================
    if (seasonInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a season'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final normalizedSeason = _validateAndNormalizeSeason(seasonInput);

    if (normalizedSeason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid season'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // =========================
    // 2. التحقق من وجود صورة أو نص
    // =========================
    if (_selectedImage == null && textInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload image or enter description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final finalText = textInput.isNotEmpty ? textInput : 'fashion design';

    setState(() {
      _isLoading = true;
    });

    try {
      String? resultUrl;
      List<String> seasonalColors = [];
      List<String> trendingColors = [];
      List<Map<String, dynamic>> analysisResults = [];
      String seasonName = normalizedSeason;

      if (_selectedImage != null && textInput.isNotEmpty) {
        // 🟣 صورة + نص
        print('📡 Calling generateDesign (image + text)...');
        final response = await _aiRepository.generateDesign(
          traineeId: '1',
          season: normalizedSeason,
          text: finalText,
          imagePath: _selectedImage!.path,
        );

        print('🤖 AI RESPONSE: $response');

        final realData = _extractRealData(response);
        print('📦 REAL DATA keys: ${realData.keys}');

        seasonalColors = _extractSeasonalColors(realData);
        trendingColors = _extractTrendingColors(realData);
        analysisResults = _extractAnalysisResults(realData);
        resultUrl = _extractResultUrl(realData);
        seasonName = _extractSeasonName(realData, normalizedSeason);

      } else if (_selectedImage != null) {
        // 🔵 صورة فقط - نحتاج Call منفصل لـ NLP عشان نجيب الألوان
        print('📡 Calling analyzeFabricWithCV (image only)...');
        final cvResponse = await _aiRepository.analyzeFabricWithCV(
          traineeId: 1,
          season: normalizedSeason,
          imagePath: _selectedImage!.path,
        );

        print('🤖 CV RESPONSE: $cvResponse');

        final realData = _extractRealData(cvResponse);
        print('📦 CV REAL DATA keys: ${realData.keys}');

        // استخراج رابط الـ 3D model
        resultUrl = _extractResultUrl(realData);

        // ✅ مهم: عمل Call منفصل لـ NLP عشان نجيب الألوان
        print('📡 Calling processText to get colors...');
        try {
          final nlpResponse = await _aiRepository.processText(
            traineeId: 1,
            text: finalText,
            season: normalizedSeason,
          );

          print('🤖 NLP RESPONSE for colors: $nlpResponse');

          final nlpRealData = _extractRealData(nlpResponse);
          print('📦 NLP REAL DATA keys: ${nlpRealData.keys}');

          seasonalColors = _extractSeasonalColors(nlpRealData);
          trendingColors = _extractTrendingColors(nlpRealData);
          analysisResults = _extractAnalysisResults(nlpRealData);
          seasonName = _extractSeasonName(nlpRealData, normalizedSeason);

        } catch (nlpError) {
          print('❌ Error fetching colors from NLP: $nlpError');
          // إذا فشل الـ NLP، نستخدم الألوان الافتراضية
        }

      } else {
        // 🟢 نص فقط
        print('📡 Calling processText (text only)...');
        final response = await _aiRepository.processText(
          traineeId: 1,
          text: finalText,
          season: normalizedSeason,
        );

        print('🤖 AI RESPONSE: $response');

        final realData = _extractRealData(response);
        print('📦 REAL DATA keys: ${realData.keys}');

        seasonalColors = _extractSeasonalColors(realData);
        trendingColors = _extractTrendingColors(realData);
        analysisResults = _extractAnalysisResults(realData);
        seasonName = _extractSeasonName(realData, normalizedSeason);
      }

      // ===============================
      // تعديل عنوان IP
      // ===============================
      if (resultUrl != null) {
        resultUrl = resultUrl
            .replaceAll('127.0.0.1', '192.168.1.22')
            .replaceAll('192.168.1.5', '192.168.1.22');
      }

      // ===============================
      // بناء النص الناتج (بدون 3D model message و analysis)
      // ===============================
      String resultText = '';

      // ✅ الألوان الموسمية
      if (seasonalColors.isNotEmpty) {
        resultText += '🎨 Seasonal Colors ($seasonName):\n';
        for (var color in seasonalColors) {
          resultText += '   • $color\n';
        }
        resultText += '\n';
      }

      // ✅ الألوان الترند
      if (trendingColors.isNotEmpty) {
        resultText += '🔥 Trending Colors:\n';
        for (var color in trendingColors) {
          resultText += '   • $color\n';
        }
        resultText += '\n';
      }

      // ✅ إذا كان صورة فقط وما في ألوان من NLP
      if (_selectedImage != null && textInput.isEmpty && seasonalColors.isEmpty) {
        resultText += '💡 Tip: Add a description to get personalized color suggestions!\n\n';
      }

      // ✅ رسالة افتراضية
      if (resultText.trim().isEmpty) {
        resultText = '✅ Design generated successfully!\n'
            '🌸 Season: $seasonName\n'
            '✨ Try uploading an image to generate a 3D model!';
      }

      setState(() {
        _generatedResult = resultText;
        _resultImageUrl = resultUrl;
        _is3DResult = resultUrl != null &&
            resultUrl.toLowerCase().endsWith('.glb');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Design Generated Successfully'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ AI ERROR: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 📅 دالة مساعدة لاستخراج اسم الموسم
  String _extractSeasonName(Map<String, dynamic> data, String defaultSeason) {
    if (data.containsKey('seasonal_suggestion')) {
      final seasonal = data['seasonal_suggestion'];
      if (seasonal is Map && seasonal.containsKey('season')) {
        return seasonal['season'].toString();
      }
    }

    if (data.containsKey('nlp') && data['nlp'] is Map) {
      final nlp = data['nlp'];
      if (nlp.containsKey('seasonal_suggestion')) {
        final seasonal = nlp['seasonal_suggestion'];
        if (seasonal is Map && seasonal.containsKey('season')) {
          return seasonal['season'].toString();
        }
      }
    }

    return defaultSeason;
  }

  // ✅ دالة مساعدة للحصول على ألوان الموسم (للعرض المؤقت)
  String _getSeasonColors(String season) {
    final s = season.toLowerCase();
    if (s.contains('spring')) return 'Pink, Green, Yellow, Lavender';
    if (s.contains('summer')) return 'Yellow, Orange, Blue, Coral';
    if (s.contains('autumn') || s.contains('fall')) return 'Brown, Orange, Red, Burgundy';
    if (s.contains('winter')) return 'White, Blue, Silver, Navy';
    return 'Purple, Gold, Silver';
  }

  // ✅ زر رفع الصورة
  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Design Generator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================== الهيدر ====================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text('AI Design Generator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Enter a season, describe your idea, or upload a sketch to convert for 3D',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color:  Colors.deepPurple.withOpacity(0.5),),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================== حقل الفصل ====================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.deepPurple, size: 18),
                            const SizedBox(width: 6),
                            const Text('Season', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Required', style: TextStyle(fontSize: 8, color: Colors.red)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _seasonController,
                          onChanged: _onSeasonChanged,
                          decoration: InputDecoration(
                            hintText: 'Choose season',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(Icons.spa, size: 18, color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            errorText: _seasonError.isNotEmpty ? _seasonError : null,
                            errorStyle: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children: _validSeasons.map((season) {
                              return GestureDetector(
                                onTap: () {
                                  final displayName = _seasonDisplayNames[season]!;
                                  _seasonController.text = displayName;
                                  _onSeasonChanged(displayName);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    _seasonDisplayNames[season]!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.deepPurple[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================== حقل الوصف ====================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_note, color: Colors.deepPurple, size: 18),
                            const SizedBox(width: 6),
                            const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Optional', style: TextStyle(fontSize: 8, color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _promptController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Describe what you want to create...',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!), // 🟡 رمادي فاتح للبوردر
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!), // 🟡 رمادي فاتح للبوردر
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[500]!, width: 2), // 🟡 رمادي غامق شوي عند التركيز
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================== رفع الصورة ====================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image, color: Colors.deepPurple, size: 18),
                            const SizedBox(width: 6),
                            const Text('Upload Sketch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Optional', style: TextStyle(fontSize: 8, color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.deepPurple.withOpacity(0.2), width: 1.5),
                          ),
                          child: _selectedImage == null
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload, size: 45, color: Colors.deepPurple.withOpacity(0.4)),
                              const SizedBox(height: 8),
                              Text('No image selected', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildImageButton(
                                    icon: Icons.photo_library,
                                    label: 'Gallery',
                                    onPressed: _pickImage,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildImageButton(
                                    icon: Icons.camera_alt,
                                    label: 'Camera',
                                    onPressed: _takePhoto,
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
                            ],
                          )
                              : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(_selectedImage!, fit: BoxFit.contain),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.black.withOpacity(0.6),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _generatedResult = null;
                                        _is3DResult = false;
                                        _resultImageUrl = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================== زر التوليد ====================
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateOutput,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 10),
                          Text('Generate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================== عرض النتيجة ====================
                  if (_generatedResult != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _is3DResult ? Icons.three_mp : Icons.description,
                                color: Colors.deepPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _is3DResult ? ' 3D Result!' : ' Text Result',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _generatedResult!,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Colors.deepPurple,
                            ),
                          ),

                          // عرض الـ 3D model
                          if (_resultImageUrl != null && _resultImageUrl!.toLowerCase().endsWith('.glb'))
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SizedBox(
                                height: 400,
                                child: ModelViewer(
                                  src: _resultImageUrl!,
                                  alt: "3D Model",
                                  ar: true,
                                  autoRotate: true,
                                  cameraControls: true,
                                  backgroundColor: Colors.white,
                                  disableZoom: false,
                                  loading: Loading.eager,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}