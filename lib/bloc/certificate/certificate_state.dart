import '../../models/certificate_model.dart';
abstract class CertificateState {}

// =====================
// حالات أساسية
// =====================
class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificateError extends CertificateState {
  final String message;

  CertificateError(this.message);
}

// =====================
// نجاح عام
// =====================
class CertificateSuccess extends CertificateState {
  final String certificateUrl;

  CertificateSuccess(this.certificateUrl);
}



// =====================
// تحميل الشهادات
// =====================
class CertificateLoaded extends CertificateState {
  final List certificates;

  CertificateLoaded(this.certificates);
}

// =====================
// 🔥 الحالة الناقصة عندك
// =====================
class CertificateGenerated extends CertificateState {
  final Map<String, dynamic> certificate;
  CertificateGenerated(this.certificate);
}

