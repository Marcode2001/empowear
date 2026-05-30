import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/certificate_repository.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final CertificateRepository repository;

  CertificateBloc(this.repository) : super(CertificateInitial()) {

    on<LoadMyCertificatesEvent>((event, emit) async {
      emit(CertificateLoading());
      try {
        final certificates = await repository.getMyCertificates();
        emit(CertificateLoaded(certificates));
      } catch (e) {
        emit(CertificateError(e.toString()));
      }
    });

    on<GenerateCertificateEvent>((event, emit) async {
      emit(CertificateLoading());

      try {
        final response =
        await repository.getCertificateByLevel(event.levelNumber);

        final certificate = response['data'];

        if (certificate == null) {
          emit(CertificateError('Certificate not found'));
          return;
        }

        final url = certificate['certificate_file'];

        if (url == null) {
          emit(CertificateError('No certificate file'));
          return;
        }

        emit(CertificateSuccess(url));
      } catch (e) {
        emit(CertificateError(e.toString()));
      }
    });


    on<LoadAllCertificatesEvent>((event, emit) async {
      emit(CertificateLoading());
      try {
        final certificates = await repository.getAllCertificates();
        emit(CertificateLoaded(certificates));
      } catch (e) {
        emit(CertificateError(e.toString()));
      }
    });

    on<SearchCertificatesEvent>((event, emit) async {
      emit(CertificateLoading());
      try {
        final certificates = await repository.searchCertificates(event.fullName);
        emit(CertificateLoaded(certificates));
      } catch (e) {
        emit(CertificateError(e.toString()));
      }
    });
  }
}