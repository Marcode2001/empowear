abstract class CertificateEvent {}

class LoadMyCertificatesEvent extends CertificateEvent {}

class GenerateCertificateEvent extends CertificateEvent {
  final int levelNumber;

  GenerateCertificateEvent({
    required this.levelNumber,
  });
}

class GetCertificateByLevelEvent extends CertificateEvent {
  final int levelNumber;

  GetCertificateByLevelEvent(this.levelNumber);
}

class LoadAllCertificatesEvent extends CertificateEvent {}

class SearchCertificatesEvent extends CertificateEvent {
  final String fullName;

  SearchCertificatesEvent(this.fullName);
}