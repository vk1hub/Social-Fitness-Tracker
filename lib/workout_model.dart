class WorkoutModel {
  final String type; // the type of exercise (workout, running, biking, custom)
  final String name; // name of exercise
  final String details; // details of the exercise
  final DateTime date; // date of the exercise

  WorkoutModel({
    required this.type,
    required this.name,
    required this.details,
    required this.date,
  });
}