// 📄 lib/screens/trainee/payment_page.dart
// ============================================================
// 💳 صفحة الدفع (Payment Page) - النسخة النهائية المعدلة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/course_models.dart';
import '../../services/api_service.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';
import '../../bloc/auth/auth_bloc.dart';

class PaymentPage extends StatefulWidget {
  final CourseItem course;
  final VoidCallback onPaymentSuccess;

  const PaymentPage({
    super.key,
    required this.course,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  int? _enrollmentRequestId;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _createOrGetEnrollmentRequest();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // 📝 البحث عن طلب تسجيل موجود أو إنشاء جديد
  // ============================================================
  Future<void> _createOrGetEnrollmentRequest() async {
    try {
      final courseIdInt = int.tryParse(widget.course.id) ?? 0;
      print('🔍 Looking for existing request for course: $courseIdInt');

      // البحث عن طلب موجود
      final existingResponse = await ApiService.get(
        endpoint: 'enrollment-request/trainee-my-requests/',
        requireAuth: true,
      );

      if (existingResponse['success']) {
        final data = existingResponse['data'];
        if (data is List) {
          for (var request in data) {
            if (request['course'] == courseIdInt) {
              _enrollmentRequestId = request['id'];
              print('✅ Found existing request: $_enrollmentRequestId');
              return;
            }
          }
        }
      }

      // إنشاء طلب جديد
      print('📝 Creating new enrollment request for course: ${widget.course.id}');

      final response = await ApiService.post(
        endpoint: 'enrollment-request/trainee-create/',
        data: {'course': courseIdInt},
        requireAuth: true,
      );

      print('📊 Response status: ${response['statusCode']}');
      print('📊 Response data: ${response['data']}');

      if (response['success']) {
        final data = response['data'];
        // ✅ تحسين استخراج ID من الاستجابة
        if (data is Map<String, dynamic>) {
          // محاولة استخراج id من أماكن مختلفة
          if (data['id'] != null) {
            _enrollmentRequestId = data['id'];
          } else if (data['request'] != null && data['request']['id'] != null) {
            _enrollmentRequestId = data['request']['id'];
          }
          print('✅ Created new request: $_enrollmentRequestId');
        } else {
          print('⚠️ Unexpected response format: $data');
        }
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  // ============================================================
  // 💳 معالجة الدفع
  // ============================================================
  Future<void> _processPayment() async {
    if (_enrollmentRequestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing payment...'),
          backgroundColor: Colors.orange,
        ),
      );
      await _createOrGetEnrollmentRequest();
      if (_enrollmentRequestId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to prepare payment'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final paymentData = {
        'enrollment_request': _enrollmentRequestId,
        'payment_method': 'Credit Card',
        'cardholder_name': _cardNameController.text.trim(),
        'card_number': _cardNumberController.text.trim().replaceAll(' ', ''),
        'expiry_date': _expiryController.text.trim(),
        'cvv': _cvvController.text.trim(),
      };

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💳 Sending payment data:');
      print('   enrollment_request: ${paymentData['enrollment_request']}');
      print('   cardholder_name: ${paymentData['cardholder_name']}');
      print('   card_number: ${paymentData['card_number']}');
      print('   expiry_date: ${paymentData['expiry_date']}');
      print('   cvv: ${paymentData['cvv']}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await ApiService.post(
        endpoint: 'payment-transaction/trainee-create/',
        data: paymentData,
        requireAuth: true,
      );

      print('📊 Payment response status: ${response['statusCode']}');
      print('📊 Payment response data: ${response['data']}');

      setState(() => _isProcessing = false);

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Course registered 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ تحديث قائمة الكورسات
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.read<CourseBloc>().add(LoadRegisteredCoursesEvent(userId: authState.user.id));
          context.read<CourseBloc>().add(LoadAvailableCoursesEvent(userId: authState.user.id));
        }

        widget.onPaymentSuccess();

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        String errorMessage = 'Payment failed';
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          if (data['error'] != null) {
            errorMessage = data['error'].toString();
          } else if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_cardNameController.text.trim().isEmpty) return false;
    String cardNumber = _cardNumberController.text.trim().replaceAll(' ', '');
    if (cardNumber.length < 16) return false;
    String expiry = _expiryController.text.trim();
    if (expiry.length < 5) return false;
    String cvv = _cvvController.text.trim();
    if (cvv.length < 3) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final String price = widget.course.price;
    final String formattedPrice = price.contains('.') ? price : '$price.00';

    return WillPopScope(
      onWillPop: () async {
        if (_isProcessing) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
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
                            '\$$formattedPrice',
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

              // Payment method
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.deepPurple),
                    SizedBox(width: 12),
                    Text(
                      'Credit Card',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    Spacer(),
                    Icon(Icons.check_circle, color: Colors.deepPurple),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Card details
              const Text(
                'Card Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _cardNameController,
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 19,
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                onChanged: (value) {
                  String formatted = value.replaceAll(' ', '');
                  if (formatted.length > 16) formatted = formatted.substring(0, 16);
                  String newText = '';
                  for (int i = 0; i < formatted.length; i++) {
                    if (i > 0 && i % 4 == 0) newText += ' ';
                    newText += formatted[i];
                  }
                  if (_cardNumberController.text != newText) {
                    _cardNumberController.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: newText.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      style: TextStyle(color: Colors.grey[800]),
                      maxLength: 5,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                      onChanged: (value) {
                        String formatted = value.replaceAll('/', '');
                        if (formatted.length > 4) formatted = formatted.substring(0, 4);
                        if (formatted.length >= 3) {
                          formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
                        }
                        if (_expiryController.text != formatted) {
                          _expiryController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      style: TextStyle(color: Colors.grey[800]),
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple, Colors.pinkAccent],
                    ),
                    borderRadius: BorderRadius.circular(30),
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
            ],
          ),
        ),
      ),
    );
  }
}