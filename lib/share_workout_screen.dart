import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_model.dart';

class ShareWorkoutScreen extends StatefulWidget {
  @override
  ShareWorkoutScreenState createState() => ShareWorkoutScreenState();
}

class ShareWorkoutScreenState extends State<ShareWorkoutScreen> {
  List<WorkoutModel> workouts = [];
  WorkoutModel? selectedWorkout;
  bool isLoading = false;
  String userId = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    loadUserData();
    loadWorkouts();
  }

  void loadUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = '${userData['firstName']} ${userData['lastName']}';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void loadWorkouts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('date', descending: true)
          .limit(20)
          .get();

      List<WorkoutModel> loadedWorkouts = [];
      for (var doc in snapshot.docs) {
        loadedWorkouts.add(WorkoutModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        ));
      }

      setState(() {
        workouts = loadedWorkouts;
      });
    } catch (e) {
      print('Error loading workouts: $e');
    }
  }

  Future<void> shareWorkout() async {
    if (selectedWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a workout to share')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': userId,
        'userName': userName,
        'workoutType': selectedWorkout!.type,
        'workoutName': selectedWorkout!.name,
        'workoutDetails': selectedWorkout!.details,
        'photoUrl': selectedWorkout!.photoUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'postsCount': FieldValue.increment(1),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout shared!')),
      );
    } catch (e) {
      print('Error sharing workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing workout')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Workout'),
      ),
      body: workouts.isEmpty
          ? Center(child: Text('No workouts to share'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final isSelected = selectedWorkout == workout;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWorkout = workout;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.black,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                workout.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(workout.details),
                              
                              if (workout.photoUrl != null && workout.photoUrl!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Image.network(
                                    workout.photoUrl!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: isLoading ? null : shareWorkout,
                    child: Container(
                      width: double.infinity,
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
                                'Post',
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}