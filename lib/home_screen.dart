import 'package:flutter/material.dart';
import 'calorie_screen.dart';
import 'chart_screen.dart';
import 'workout_screen.dart';
import 'workout_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_helper.dart';

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // keeping track current page index
  int currentPage = 0;

  // List to store all workouts
  List<WorkoutModel> workouts = [];

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    NotificationHelper.setup();
    loadWorkouts();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // get saved lists
    List<String>? types = prefs.getStringList('workout_types');
    List<String>? names = prefs.getStringList('workout_names');
    List<String>? details = prefs.getStringList('workout_details');
    List<String>? dates = prefs.getStringList('workout_dates');
    
    // to stop crashing from no info
    if (types == null || names == null || details == null || dates == null) {
      return;
    }
    
    // Build workouts from the lists
    List<WorkoutModel> loadedWorkouts = [];
    for (int i = 0; i < types.length; i++) {
      WorkoutModel workout = WorkoutModel(
        type: types[i],
        name: names[i],
        details: details[i],
        date: DateTime.parse(dates[i]),
      );
      loadedWorkouts.add(workout);
    }
    
    setState(() {
      workouts = loadedWorkouts;
    });
  }

  void saveWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String> types = [];
    List<String> names = [];
    List<String> details = [];
    List<String> dates = [];
    
    // Fill the lists with data from workouts
    for (int i = 0; i < workouts.length; i++) {
      types.add(workouts[i].type);
      names.add(workouts[i].name);
      details.add(workouts[i].details);
      dates.add(workouts[i].date.toString());
    }
    
    await prefs.setStringList('workout_types', types);
    await prefs.setStringList('workout_names', names);
    await prefs.setStringList('workout_details', details);
    await prefs.setStringList('workout_dates', dates);
  }

  // Function to add a workout
  void addWorkout(WorkoutModel workout) {
    setState(() {
      workouts.add(workout);
    });
    saveWorkouts();
    NotificationHelper.checkWorkout(workouts);
  }

  @override
  Widget build(BuildContext context) {
    // list of screens - pass workouts to all screens that need it
    final List<Widget> screens = [
      WorkoutScreen(workouts: workouts, onAddWorkout: addWorkout, onDeleteWorkout: saveWorkouts),
      CalorieScreen(),
      ChartScreen(workouts: workouts),
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
          pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.fastEaseInToSlowEaseOut,);
        },
        // Bottom navigation tabs
        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Calories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}