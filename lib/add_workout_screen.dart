import 'package:flutter/material.dart';
import 'workout_model.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Function(WorkoutModel)? onAddWorkout;
  final DateTime selectedDate;

  AddWorkoutScreen({this.onAddWorkout, required this.selectedDate});

  @override
  AddWorkoutScreenState createState() => AddWorkoutScreenState();
}

class AddWorkoutScreenState extends State<AddWorkoutScreen> {
  // Controllers for text input fields
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  // List to store all sets
  List<Map<String, String>> sets = [];

  // Function to add a set
  void addSet() {
    if (exerciseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter exercise name')),
      );
      return;
    }
    
    if (weightController.text.isEmpty || repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Weight and reps cannot be empty')),
      );
      return;
    }

    setState(() {
      sets.add({
        'name': exerciseNameController.text,
        'weight': weightController.text,
        'reps': repsController.text,
      });
      
      // Clear the weight and reps fields for next set
      weightController.clear();
      repsController.clear();
    });
  }

  // Function to remove a set
  void removeSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  // function to save a workout
  void saveWorkout() {
    if (sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one set')),
      );
      return;
    }

    // find the different exercise names
    List<String> uniqueExercises = [];
    for (int i = 0; i < sets.length; i++) {
      String exerciseName = sets[i]['name']!;
      if (!uniqueExercises.contains(exerciseName)) {
        uniqueExercises.add(exerciseName);
      }
    }

    // create workout name by joining the workout names
    String workoutName = '';
    for (int i = 0; i < uniqueExercises.length; i++) {
      workoutName += uniqueExercises[i];
      if (i < uniqueExercises.length - 1) {
        workoutName += ', ';
      }
    }

    // Build the details string with grouped exercises
    String details = '';
    for (int i = 0; i < uniqueExercises.length; i++) {
      String currentExercise = uniqueExercises[i];
      details += '$currentExercise\n';
      
      // Add all sets for this exercise
      int setNumber = 1;
      for (int j = 0; j < sets.length; j++) {
        if (sets[j]['name'] == currentExercise) {
          details += '  Set $setNumber: ${sets[j]['weight']} lbs x ${sets[j]['reps']} reps\n';
          setNumber++;
        }
      }
      details += '\n';
    }

    // Add time if provided
    if (timeController.text.isNotEmpty) {
      details += 'Total Time: ${timeController.text} minutes';
    }

    // Create workout model
    WorkoutModel workout = WorkoutModel(
      type: 'Weight Training',
      name: workoutName,
      details: details.trim(),
      date: widget.selectedDate,
    );

    // Call the callback to add workout if it exists
    if (widget.onAddWorkout != null) {
      widget.onAddWorkout!(workout);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Workout'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight Training',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Exercise Name field
            TextField(
              controller: exerciseNameController,
              decoration: InputDecoration(
                labelText: 'Exercise Name (e.g., Bicep Curl)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // Weight and Reps fields
            Row(
              children: [
                // Weight field
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (lbs)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Reps field
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // Add Set button
            GestureDetector(
              onTap: addSet,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    'Add Set',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Display added sets
            Expanded(
              child: buildGroupedSetsList(),
            ),
            
            // Time field 
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Time (minutes)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                // Discard button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ), 
                      child: Center(
                        child: Text(
                          'Discard',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Add Workout button
                Expanded(
                  child: GestureDetector(
                    onTap: saveWorkout,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          'Add Workout',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // build grouped sets list
  Widget buildGroupedSetsList() {
    if (sets.isEmpty) {
      return Center(
        child: Text(
          'No sets added yet',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // checking if exercise names are unique
    List<String> uniqueExercises = [];
    for (int i = 0; i < sets.length; i++) {
      String exerciseName = sets[i]['name']!;
      // add exercise if its not in the list for grouped display
      if (!uniqueExercises.contains(exerciseName)) {
        uniqueExercises.add(exerciseName);
      }
    }

    List<Widget> exerciseCards = [];

    for (int i = 0; i < uniqueExercises.length; i++) {
      String currentExercise = uniqueExercises[i];
      
      // getting all sets
      List<Widget> setWidgets = [];
      int setNumber = 1;
      
      // loop through sets to find matching exercise names
      for (int j = 0; j < sets.length; j++) {
        if (sets[j]['name'] == currentExercise) {
          setWidgets.add(
            Padding(
              padding: EdgeInsets.symmetric(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Set $setNumber: ${sets[j]['weight']} lbs x ${sets[j]['reps']} reps',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20),
                    onPressed: () => removeSet(j),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
          setNumber++;
        }
      }

      // Create the card for this exercise
      exerciseCards.add(
        Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME OF EXERCISE
              Text(
                currentExercise,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Column(children: setWidgets),
            ],
          ),
        ),
      );
    }

    // return list of exercise cards
    return ListView(
      children: exerciseCards,
    );
  }
}