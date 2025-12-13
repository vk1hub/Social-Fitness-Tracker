import 'package:flutter/material.dart';
import 'workout_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AddRunningBikingScreen extends StatefulWidget {
  // Constructor to accept type parameter (running or biking)
  final String type;
  final Function(WorkoutModel)? onAddWorkout;
  final DateTime selectedDate;

  AddRunningBikingScreen({
    required this.type,
    this.onAddWorkout,
    required this.selectedDate,
  });

  @override
  AddRunningBikingState createState() => AddRunningBikingState();
}

class AddRunningBikingState extends State<AddRunningBikingScreen> {
  // manage input fields
  TextEditingController timeController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  File? selectedImage;
  bool isLoading = false;

  // Function to save activity
  Future<void> saveActivity() async {
    if (timeController.text.isEmpty || distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in time and distance')),
      );
      return;
    }

    String details =
        'Time: ${timeController.text} min\nDistance: ${distanceController.text} miles';

    setState(() {
      isLoading = true;
    });

    String? photoUrl = await uploadImage();

    WorkoutModel workout = WorkoutModel(
      type: widget.type,
      name: widget.type,
      details: details,
      date: widget.selectedDate,
      photoUrl: photoUrl,
    );

    if (widget.onAddWorkout != null) {
      widget.onAddWorkout!(workout);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = 'workout_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('workouts')
          .child(userId)
          .child(fileName);

      await storageRef.putFile(selectedImage!);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log ${widget.type}')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.type,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
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

            SizedBox(height: 20),

            if (selectedImage != null)
              Container(
                height: 150,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                child: Image.file(selectedImage!, fit: BoxFit.cover),
              ),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    selectedImage == null
                        ? 'Add Photo (Optional)'
                        : 'Change Photo',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
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
                    onTap: isLoading ? null: saveActivity,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
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
