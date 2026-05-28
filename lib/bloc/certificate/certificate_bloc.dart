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

        final response = await repository.getCertificateByLevel(event.levelNumber);

        if (response['success']) {

          emit(CertificateSuccess(
            response['message'] ?? 'Generated Successfully',
          ));

          final certificates =
          await repository.getMyCertificates();

          emit(CertificateLoaded(certificates));

        } else {

          emit(CertificateError(
            response['message'] ??
                response['error'] ??
                'Generation Failed',
          ));
        }

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
        final response = await ApiService.post(
          endpoint: 'certificate/trainee-get-or-generate-by-course-level/${event.levelNumber}/',
          data: {},
          requireAuth: true,
        );

        print("STATUS: ${response['statusCode']}");
        print("DATA: ${response['data']}");

        if (response['success']) {
          emit(CertificateGenerated(response['data']));
        } else {
          emit(CertificateError(
            response['message'] ?? 'Not eligible',
          ));
        }
      } catch (e) {
        emit(CertificateError(e.toString()));
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