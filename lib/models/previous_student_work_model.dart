///models/previous_student_work_model.dart
class PreviousStudentWork {
  final int id;
  final String designerName;
  final String imageUrl;

  PreviousStudentWork({
    required this.id,
    required this.designerName,
    required this.imageUrl,
  });

  factory PreviousStudentWork.fromJson(Map<String, dynamic> json) {
    return PreviousStudentWork(
      id: json['id'],
      designerName: json['designer_name'] ?? '',

      imageUrl:
      'http://192.168.1.22:8000/api${json['image_url']}',
    );
  }
}