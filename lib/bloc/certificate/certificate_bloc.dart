import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/certificate_repository.dart';

import 'certificate_event.dart';
import 'certificate_state.dart';
import 'package:empower/services/api_service.dart';

class CertificateBloc
    extends Bloc<CertificateEvent, CertificateState> {

  final CertificateRepository repository;

  CertificateBloc(this.repository)
      : super(CertificateInitial()) {

    // =======================================================
    // 📥 Load My Certificates
    // =======================================================
    on<LoadMyCertificatesEvent>((event, emit) async {

      emit(CertificateLoading());

      try {

        final certificates =
        await repository.getMyCertificates();

        emit(CertificateLoaded(certificates));

      } catch (e) {

        emit(CertificateError(e.toString()));
      }
    });

    // =======================================================
    // 🏆 Generate Certificate
    // =======================================================
    on<GenerateCertificateEvent>((event, emit) async {
      emit(CertificateLoading());

      try {
        final response =
        await repository.getCertificateByLevel(event.levelNumber);

        final data = response['data'];

        if (response['success'] == true && data != null) {

          final certificate = data['certificate'];

          if (certificate != null) {
            emit(CertificateSuccess(
              response['message'] ?? 'Generated Successfully',
            ));

            final certificates =
            await repository.getAllCertificates();

            emit(CertificateLoaded(certificates));
            return;
          }
        }

        emit(CertificateError(
          data?['error'] ?? response['message'] ?? 'Generation Failed',
        ));
      } catch (e) {
        emit(CertificateError(e.toString()));
      }
    });

    // =======================================================
    // 👨‍💼 Admin Load
    // =======================================================
    on<LoadAllCertificatesEvent>((event, emit) async {

      emit(CertificateLoading());

      try {

        final certificates =
        await repository.getAllCertificates();

        emit(CertificateLoaded(certificates));

      } catch (e) {

        emit(CertificateError(e.toString()));
      }
    });

    on<GetCertificateByLevelEvent>((event, emit) async {
      emit(CertificateLoading());

      try {
        final response =
        await repository.getCertificateByLevel(event.levelNumber);

        final data = response['data'];

        // =========================
        // ❌ فشل من الباك
        // =========================
        if (response['success'] != true) {
          final errorMessage =
              data?['error'] ??
                  response['message'] ??
                  'You are not eligible';

          emit(CertificateError(errorMessage));
          return;
        }

        // =========================
        // ✅ نجاح الطلب
        // =========================
        final certificate = data?['certificate'];

        if (certificate == null) {
          emit(CertificateError('Certificate not found in response'));
          return;
        }

        emit(CertificateGenerated(certificate));
      } catch (e) {
        emit(CertificateError('Unexpected error: ${e.toString()}'));
      }
    });

    // =======================================================
    // 🔍 Search
    // =======================================================
    on<SearchCertificatesEvent>((event, emit) async {

      emit(CertificateLoading());

      try {

        final certificates =
        await repository.searchCertificates(
          event.fullName,
        );

        emit(CertificateLoaded(certificates));

      } catch (e) {

        emit(CertificateError(e.toString()));
      }
    });
  }
}