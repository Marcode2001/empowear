class CertificateModel {
  final int id;
  final String traineeName;
  final String courseTitle;
  final int levelNumber;
  final String certificateCode;
  final String? certificateFile;
  final String issuedAt;
  final String issuedBy;

  CertificateModel({
    required this.id,
    required this.traineeName,
    required this.courseTitle,
    required this.levelNumber,
    required this.certificateCode,
    required this.certificateFile,
    required this.issuedAt,
    required this.issuedBy,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] ?? 0,
      traineeName: json['trainee_full_name'] ?? '',
      courseTitle: json['course_title'] ?? '',
      levelNumber: json['course_level_number'] ?? 0,
      certificateCode: json['certificate_code'] ?? '',
      certificateFile: json['certificate_file'],
      issuedAt: json['issued_at'] ?? '',
      issuedBy: json['issued_by_admin_name'] ?? '',
    );
  }

  String get fullCertificateUrl {
    if (certificateFile == null || certificateFile!.isEmpty) {
      return '';
    }

    if (certificateFile!.startsWith('http')) {
      return certificateFile!;
    }
    return 'http://192.168.1.22:8000$certificateFile';
  }
}