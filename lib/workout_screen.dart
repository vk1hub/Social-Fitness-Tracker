import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'preset_routines.dart';
import 'add_exercise_screen.dart';
import 'workout_model.dart';

class WorkoutScreen extends StatefulWidget {
  final List<WorkoutModel> workouts;
  final Function(WorkoutModel) onAddWorkout;
  final Function onDeleteWorkout;

  WorkoutScreen({
    required this.workouts, 
    required this.onAddWorkout,
    required this.onDeleteWorkout,
  });

  @override
  WorkoutScreenState createState() => WorkoutScreenState();
}

class WorkoutScreenState extends State<WorkoutScreen> {
  // calendar state
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();

  // Get workouts for selected date
  List<WorkoutModel> getWorkoutsForSelectedDate() {
    List<WorkoutModel> todaysWorkouts = [];
    for (int i = 0; i < widget.workouts.length; i++) {
      WorkoutModel workout = widget.workouts[i];
      if (workout.date.year == selectedDate.year &&
          workout.date.month == selectedDate.month &&
          workout.date.day == selectedDate.day) {
        todaysWorkouts.add(workout);
      }
    }
    return todaysWorkouts;
  }

  void deleteWorkout(WorkoutModel workout) {
    setState(() {
      widget.workouts.remove(workout);
    });
    widget.onDeleteWorkout();
  }

  @override
  Widget build(BuildContext context) {
    List<WorkoutModel> todaysWorkouts = getWorkoutsForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Log'),
        actions: [
          // INFO BUTTON
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => PresetRoutinesScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // calendar widget
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: focusedDate,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
                focusedDate = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          // Workout list
          Expanded(
            child: todaysWorkouts.isEmpty
                ? Center(
                    child: Text(
                      'No workouts yet!\nTap + to add your first workout',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: todaysWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = todaysWorkouts[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  workout.type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${workout.date.month}/${workout.date.day}/${workout.date.year}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => deleteWorkout(workout),
                                      child: Icon(
                                        Icons.delete,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              workout.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(workout.details),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // ADD WORKOUT BUTTON - pass callback
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExerciseScreen(
                onAddWorkout: widget.onAddWorkout,
                selectedDate: selectedDate,
              ),
            ),
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}