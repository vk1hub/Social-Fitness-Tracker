class WorkoutModel {
  final String type; // type of exercise (biking, running, etc)
  final String name; // name of workout
  final String details; // details of workout
  final DateTime date; // date of workout
  final String? photoUrl; // optional photo
  final String? workoutId; // firestore ID

  WorkoutModel({
    required this.type,
    required this.name,
    required this.details,
    required this.date,
    this.photoUrl,
    this.workoutId,
  });

  // sending data to firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'details': details,
      'date': date.toIso8601String(),
      'photoUrl': photoUrl ?? '',
    };
  }

  // turning firestore data back to workoutmodel
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