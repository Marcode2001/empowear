import '../../models/certificate_model.dart';
import '../../bloc/certificate/certificate_event.dart';
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
  final String message;

  CertificateSuccess(this.message);
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
  final dynamic certificate;

  CertificateGenerated(this.certificate);
}

/*abstract class CertificateState {}

class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificateLoaded extends CertificateState {
  final List<CertificateModel> certificates;

  CertificateLoaded(this.certificates);
}

class CertificateError extends CertificateState {
  final String message;

  CertificateError(this.message);
}

class CertificateSuccess extends CertificateState {
  final String message;

  CertificateSuccess(this.message);
}*/