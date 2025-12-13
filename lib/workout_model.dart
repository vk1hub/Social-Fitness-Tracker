class WorkoutModel {
  final String type;
  final String name;
  final String details;
  final DateTime date;
  final String? photoUrl;
  final String? workoutId;

  WorkoutModel({
    required this.type,
    required this.name,
    required this.details,
    required this.date,
    this.photoUrl,
    this.workoutId,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'details': details,
      'date': date.toIso8601String(),
      'photoUrl': photoUrl ?? '',
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutModel(
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      details: map['details'] ?? '',
      date: DateTime.parse(map['date']),
      photoUrl: map['photoUrl'],
      workoutId: id,
    );
  }
}