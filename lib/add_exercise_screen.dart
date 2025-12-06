import 'package:fitness_tracker_application/add_custom_exercise.dart';
import 'package:fitness_tracker_application/add_workout_screen.dart';
import 'package:fitness_tracker_application/running_biking_screen.dart';
import 'package:flutter/material.dart';
import 'workout_model.dart';

class AddExerciseScreen extends StatelessWidget {
  final Function(WorkoutModel) onAddWorkout;
  final DateTime selectedDate;

  AddExerciseScreen({required this.onAddWorkout, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Exercise')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Exercise Type',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            // Workout
            buildExerciseButton(context, 'Workout', Icons.fitness_center, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddWorkoutScreen(onAddWorkout: onAddWorkout, selectedDate: selectedDate)),
              );
            }),
            SizedBox(height: 15),

            // Running
            buildExerciseButton(context, 'Running', Icons.directions_run, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRunningBikingScreen(type: 'Running', onAddWorkout: onAddWorkout, selectedDate: selectedDate)),
              );
            }),
            SizedBox(height: 15),

            // Biking
            buildExerciseButton(context, 'Biking', Icons.directions_bike, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRunningBikingScreen(type: 'Biking', onAddWorkout: onAddWorkout, selectedDate: selectedDate)),
              );
            }),
            SizedBox(height: 15),

            // Custom Exercise
            buildExerciseButton(context, 'Custom Exercise', Icons.control_point, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCustomScreen(onAddWorkout: onAddWorkout, selectedDate: selectedDate)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each exercise button
  Widget buildExerciseButton(
    BuildContext context,
    String title,
    IconData icon,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      // size of buttons
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // icons and text
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 20),
            Text(title, style: TextStyle(fontSize: 18, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}