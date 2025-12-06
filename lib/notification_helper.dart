import 'workout_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> setup() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: android);
    
    await notifications.initialize(settings);
    await notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'workout_channel',
      'Workout Notifications',
    );
    
    await notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> show(String title, String message) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'workout_channel',
      'Workout Notifications',
    );
    
    const NotificationDetails details = NotificationDetails(android: android);
    await notifications.show(0, title, message, details);
  }

  // Calculate total workout time for a specific day
  static void checkWorkout(List<WorkoutModel> workouts) {
    DateTime today = DateTime.now();
    double totalTime = 0;

    for (int i = 0; i < workouts.length; i++) {
      if (workouts[i].date.year == today.year &&
          workouts[i].date.month == today.month &&
          workouts[i].date.day == today.day) {
        String details = workouts[i].details;


        // get time from workout details
        if (details.contains('Time:')) {
          String timeStr = details.split('Time:')[1].split('\n')[0].trim();
          totalTime += double.tryParse(timeStr.split(' ')[0]) ?? 0;
        }

        // get total time from weight training details
        else if (details.contains('Total Time:')) {
          String timeStr = details.split('Total Time:')[1].trim();
          totalTime += double.tryParse(timeStr.split(' ')[0]) ?? 0;
        }
      }
    }

    if (totalTime >= 45) {
      show('Daily Goal Achieved!', 'Great job today, you hit the 45-min daily goal. Keep grinding!!');
      checkStreak(workouts);
    } else {
      int remaining = (45 - totalTime).toInt();
      show('Keep Going!', 'You have $remaining minutes left to hit todays workout goal, you got this!');
    }
  }

  static void checkStreak(List<WorkoutModel> workouts) {
    DateTime today = DateTime.now();

    // checking if worked out 7 days in a row
    for (int day = 0; day < 7; day++) {
      DateTime checkDate = today.subtract(Duration(days: day));
      bool found = false;

      for (int i = 0; i < workouts.length; i++) {
        if (workouts[i].date.year == checkDate.year &&
            workouts[i].date.month == checkDate.month &&
            workouts[i].date.day == checkDate.day) {
          found = true;
          break;
        }
      }

      if (!found) return;
    }

    show('INCREDIBLE STREAK!', 'U crushed it this week! 7 days in a row? Consistency like that will pay off!');
  }
}