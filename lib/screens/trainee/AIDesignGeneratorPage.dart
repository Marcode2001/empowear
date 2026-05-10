// 📄 lib/screens/trainee/ai_design_generator_page.dart
// ============================================================
// 🎨 صفحة توليد تصاميم الأزياء بالذكاء الاصطناعي
// ============================================================
// الوظيفة: تحويل الرسمات إلى تصاميم 3D
// - إدخال الفصل (مطلوب)
// - إدخال وصف (اختياري)
// - رفع صورة (اختياري)
// - توليد نتيجة (نصية أو 3D)

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AIDesignGeneratorPage extends StatefulWidget {
  const AIDesignGeneratorPage({super.key});

  @override
  State<AIDesignGeneratorPage> createState() => _AIDesignGeneratorPageState();
}

class _AIDesignGeneratorPageState extends State<AIDesignGeneratorPage> {
  // ✅ متغيرات الحالة
  File? _selectedImage;
  bool _isLoading = false;
  String? _generatedResult;
  bool _is3DResult = false;

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
      if (value.isEmpty) {
        _seasonError = '';
      } else {
        final normalized = _validateAndNormalizeSeason(value);
        if (normalized != null) {
          _seasonError = '';
          if (_seasonController.text != normalized) {
            _seasonController.value = TextEditingValue(
              text: normalized,
              selection: TextSelection.collapsed(offset: normalized.length),
            );
          }
        } else {
          _seasonError = 'Please enter a valid season: Spring, Summer, Autumn, or Winter';
        }
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
      });
    }
  }

  // ✅ توليد النتيجة
  Future<void> _generateOutput() async {
    // التحقق من الفصل
    final seasonInput = _seasonController.text.trim();
    if (seasonInput.isEmpty) {
      setState(() => _seasonError = 'Please enter a season');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a season!'), backgroundColor: Colors.orange),
      );
      return;
    }

    final normalizedSeason = _validateAndNormalizeSeason(seasonInput);
    if (normalizedSeason == null) {
      setState(() => _seasonError = 'Please enter a valid season');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid season!'), backgroundColor: Colors.orange),
      );
      return;
    }

    final hasImage = _selectedImage != null;
    final hasText = _promptController.text.trim().isNotEmpty;

    if (!hasText && !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description or upload an image!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _seasonError = '';
      _enteredSeason = normalizedSeason;
    });

    // محاكاة وقت المعالجة
    await Future.delayed(const Duration(seconds: 2));

    String result;
    bool is3D = hasImage;

    if (hasImage) {
      result = _generate3DResult();
    } else {
      result = _generateTextResult();
    }

    setState(() {
      _generatedResult = result;
      _is3DResult = is3D;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(is3D ? '3D model generated!' : 'Text generated!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ✅ توليد نتيجة 3D
  String _generate3DResult() {
    final season = _enteredSeason;
    final prompt = _promptController.text.trim();
    final promptText = prompt.isNotEmpty ? '\n📝 "${prompt}"' : '';

    return '✅ 3D model generated successfully for $season season!$promptText\n\n'
        '🎨 Suggested colors: ${_getSeasonColors(season)}\n'
        '✨ Trending color palettes available\n'
        '🖼️ Image: ${_selectedImage != null ? "Uploaded" : "None"}';
  }

  // ✅ توليد نتيجة نصية
  String _generateTextResult() {
    final season = _enteredSeason;
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      return '📝 Please enter a description to generate text!\n\n'
          '🌸 Season: $season\n'
          '✨ Trending colors: ${_getSeasonColors(season)}\n'
          '💡 Tip: Try describing what you want to create.';
    }

    return '📝 Design generated for $season season!\n\n'
        '🎨 ${_getSeasonEnhancements(season)}\n'
        '💡 Tip: Add an image to generate a 3D model!';
  }

  // ✅ الحصول على ألوان الموسم
  String _getSeasonColors(String season) {
    final s = season.toLowerCase();
    if (s.contains('spring')) return 'Pink, Green, Yellow, Lavender';
    if (s.contains('summer')) return 'Yellow, Orange, Blue, Coral';
    if (s.contains('autumn') || s.contains('fall')) return 'Brown, Orange, Red, Burgundy';
    if (s.contains('winter')) return 'White, Blue, Silver, Navy';
    return 'Purple, Gold, Silver';
  }

  // ✅ الحصول على تحسينات الموسم
  String _getSeasonEnhancements(String season) {
    final s = season.toLowerCase();
    if (s.contains('spring')) return 'Fresh flowers, Pastel colors, Soft lighting';
    if (s.contains('summer')) return 'Bright colors, Beach vibes, Warm lighting';
    if (s.contains('autumn') || s.contains('fall')) return 'Warm tones, Cozy atmosphere, Golden lighting';
    if (s.contains('winter')) return 'Cool colors, Snow effects, Frosty lighting';
    return 'Add seasonal elements for better results';
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
                  // الهيدر
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
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                            hintText: 'Spring, Summer, Autumn, or Winter',
                            prefixIcon: const Icon(Icons.spa, size: 18, color: Colors.deepPurple),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        color: (_is3DResult ? Colors.purple : Colors.blue).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (_is3DResult ? Colors.purple : Colors.blue).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _is3DResult ? Icons.three_mp : Icons.description,
                                color: _is3DResult ? Colors.purple : Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _is3DResult ? '3D Result!' : 'Text Result',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _is3DResult ? Colors.purple : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(_generatedResult!, style: const TextStyle(fontSize: 13, height: 1.5)),
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