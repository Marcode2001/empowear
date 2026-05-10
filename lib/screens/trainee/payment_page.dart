// 📄 lib/screens/trainee/payment_page.dart
// ============================================================
// 💳 صفحة الدفع (Payment Page)
// ============================================================
// الوظيفة: معالجة دفع رسوم الكورسات المدفوعة
// - عرض معلومات الكورس (الاسم والسعر)
// - اختيار طريقة الدفع (بطاقة ائتمان، PayPal، Apple Pay)
// - إدخال بيانات البطاقة
// - معالجة الدفع وعرض النتيجة

import 'package:flutter/material.dart';
import '../../models/course_models.dart';

class PaymentPage extends StatefulWidget {
  final CourseItem course;           // الكورس الذي سيتم الدفع له
  final VoidCallback onPaymentSuccess;   // دالة تستدعى بعد نجاح الدفع

  const PaymentPage({
    super.key,
    required this.course,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // ✅ متغيرات الحالة
  bool _isProcessing = false;           // هل عملية الدفع قيد التنفيذ؟
  String _selectedPaymentMethod = 'credit_card';  // طريقة الدفع المختارة
  bool _isDemoMode = true;              // وضع التجربة (بدون تحقق حقيقي)

  // ✅ متحكمات حقول إدخال البطاقة
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();

  @override
  void dispose() {
    // ✅ تنظيف المتحكمات لتجنب تسرب الذاكرة
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  // ✅ التحقق من صحة المدخلات
  bool _validateInputs() {
    if (_selectedPaymentMethod == 'credit_card') {
      if (_cardNameController.text.trim().isEmpty) return false;
      if (_cardNumberController.text.trim().length < 16) return false;
      if (_expiryController.text.trim().length < 5) return false;
      if (_cvvController.text.trim().length < 3) return false;
    }
    return true;
  }

  // ✅ معالجة الدفع
  Future<void> _processPayment() async {
    // التحقق من صحة البيانات (في الوضع الحقيقي فقط)
    if (!_isDemoMode && !_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ إظهار مؤشر التحميل
    setState(() => _isProcessing = true);

    // محاكاة تأخير الاتصال بالبوابة البنكية
    await Future.delayed(const Duration(seconds: 2));

    // ✅ إخفاء مؤشر التحميل
    setState(() => _isProcessing = false);

    if (mounted) {
      // ✅ عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Course registered.'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ استدعاء دالة النجاح
      widget.onPaymentSuccess();

      // ✅ العودة إلى الصفحة السابقة
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ يسمح للـ Scaffold بإعادة ترتيب المحتوى عند ظهور الكيبورد
      resizeToAvoidBottomInset: true,

      // 🎨 شريط التطبيق العلوي
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
      ),

      body: SingleChildScrollView(
        // ✅ padding ثابت في الأسفل (بدون إضافة ارتفاع الكيبورد)
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 📦 معلومات الكورس
            // ============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // أيقونة سلة التسوق
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  // معلومات الكورس
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.course.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ============================================================
            // 💳 طرق الدفع
            // ============================================================
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // بطاقة الائتمان
            _buildPaymentMethod('Credit Card', 'credit_card', Icons.credit_card),
            // PayPal
            _buildPaymentMethod('PayPal', 'paypal', Icons.payments),
            // Apple Pay
            _buildPaymentMethod('Apple Pay', 'apple_pay', Icons.apple),

            const SizedBox(height: 24),

            // ============================================================
            // 📝 نموذج بيانات البطاقة (يظهر فقط عند اختيار Credit Card)
            // ============================================================
            if (_selectedPaymentMethod == 'credit_card') ...[
              const Text(
                'Card Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // اسم صاحب البطاقة
              TextField(
                controller: _cardNameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: _isDemoMode ? 'Test User' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // رقم البطاقة
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: _isDemoMode ? '4242 4242 4242 4242' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // تاريخ الانتهاء و CVV (صف متوازي)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        hintText: _isDemoMode ? '12/28' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: _isDemoMode ? '123' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // ============================================================
            // ✅ زر الدفع (بتدرج لوني بنفسجي - وردي)
            // ============================================================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple, Colors.pinkAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔧 دالة مساعدة: بناء بطاقة طريقة الدفع
  // ============================================================
  /// بناء بطاقة طريقة الدفع (Credit Card, PayPal, Apple Pay)
  /// - title: عنوان طريقة الدفع
  /// - method: معرف الطريقة (للمقارنة)
  /// - icon: أيقونة الطريقة
  Widget _buildPaymentMethod(String title, String method, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.deepPurple : Colors.grey[700],
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}