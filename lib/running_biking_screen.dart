import 'package:flutter/material.dart';
import 'workout_model.dart';

class AddRunningBikingScreen extends StatefulWidget {
  // Constructor to accept type parameter (running or biking)
  final String type;
  final Function(WorkoutModel)? onAddWorkout;
  final DateTime selectedDate;

  AddRunningBikingScreen({required this.type, this.onAddWorkout, required this.selectedDate});

  @override
  AddRunningBikingState createState() => AddRunningBikingState();
}

class AddRunningBikingState extends State<AddRunningBikingScreen> {
  // manage input fields
  TextEditingController timeController = TextEditingController();
  TextEditingController distanceController = TextEditingController();

  // Function to save activity
  void saveActivity() {
    if (timeController.text.isEmpty || distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in time and distance')),
      );
      return;
    }

    String details = 'Time: ${timeController.text} min\nDistance: ${distanceController.text} miles';

    WorkoutModel workout = WorkoutModel(
      type: widget.type,
      name: widget.type,
      details: details,
      date: widget.selectedDate,
    );

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
        title: Text('Log ${widget.type}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.type, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            
            // time input field
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Time (minutes)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // distance input field
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Distance (miles)',
                border: OutlineInputBorder(),
              ),
            ),
            
            Spacer(),
            
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

                // Add Running/Biking button
                Expanded(
                  child: GestureDetector(
                    onTap: saveActivity,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          'Add ${widget.type}',
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
}