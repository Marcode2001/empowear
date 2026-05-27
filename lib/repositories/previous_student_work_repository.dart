//lib/repositories/previous_student_work_repository.dart
import '../models/previous_student_work_model.dart';
import '../services/api_service.dart';

class PreviousStudentWorkRepository {

  // ✅ جلب المشاريع
  Future<List<PreviousStudentWork>> loadProjects() async {

    final response = await ApiService.get(
      endpoint: 'previous-student-work/',
      requireAuth: true,
    );

    if (response['success']) {

      final List data = response['data'];

      return data
          .map((e) => PreviousStudentWork.fromJson(e))
          .toList();
    }

    return [];
  }
}