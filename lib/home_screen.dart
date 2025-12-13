import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'workout_screen.dart';
import 'workout_model.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // keeping track current page index
  int currentPage = 0;

  // List to store all workouts
  List<WorkoutModel> workouts = [];
  String userId = '';

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    loadWorkouts();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void loadWorkouts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('date', descending: true)
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

  Future<void> addWorkout(WorkoutModel workout) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .add(workout.toMap());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'workoutsCount': FieldValue.increment(1),
      });

      setState(() {
        workouts.insert(0, WorkoutModel(
          type: workout.type,
          name: workout.name,
          details: workout.details,
          date: workout.date,
          photoUrl: workout.photoUrl,
          workoutId: docRef.id,
        ));
      });

    } catch (e) {
      print('Error adding workout: $e');
    }
  }

  Future<void> deleteWorkout(WorkoutModel workout) async {
    try {
      if (workout.workoutId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('workouts')
            .doc(workout.workoutId)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'workoutsCount': FieldValue.increment(-1),
        });
      }

      setState(() {
        workouts.remove(workout);
      });
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // list of screens - pass workouts to all screens that need it
    final List<Widget> screens = [
      WorkoutScreen(
        workouts: workouts,
        onAddWorkout: addWorkout,
        onDeleteWorkout: deleteWorkout,
      ),
      ChartScreen(workouts: workouts),
      ProfileScreen(userId: userId),
    ];

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        children: screens,
      ),

      // Bottom navigation bar for switching between screens
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
          pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.fastEaseInToSlowEaseOut,
          );
        },
        // Bottom navigation tabs
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}