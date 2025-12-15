import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  ChallengesScreenState createState() => ChallengesScreenState();
}

class ChallengesScreenState extends State<ChallengesScreen> {
  String userId = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    initializeChallenges();
  }

  Future<void> initializeChallenges() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('challenges')
          .get();
      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('challenges')
            .doc('run-100-miles')
            .set({
              'title': 'Run 100 Miles',
              'description': 'Run a total of 100 miles',
              'goal': 100,
              'type': 'running',
              'participantsCount': 0,
              'completedCount': 0,
            });
        await FirebaseFirestore.instance
            .collection('challenges')
            .doc('log-10-workouts')
            .set({
              'title': 'Log 10 Workouts',
              'description': 'Log 10 workouts total',
              'goal': 10,
              'type': 'workouts',
              'participantsCount': 0,
              'completedCount': 0,
            });
        await FirebaseFirestore.instance
            .collection('challenges')
            .doc('7-day-streak')
            .set({
              'title': '7-Day Streak',
              'description': 'Work out 7 days in a row',
              'goal': 7,
              'type': 'streak',
              'participantsCount': 0,
              'completedCount': 0,
            });
        await FirebaseFirestore.instance
            .collection('challenges')
            .doc('bike-25-miles')
            .set({
              'title': 'Bike 25 Miles',
              'description': 'Bike a total of 25 miles',
              'goal': 25,
              'type': 'biking',
              'participantsCount': 0,
              'completedCount': 0,
            });
      }
    } catch (e) {
      print('Error initializing challenges: $e');
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .collection('participants')
          .doc(userId)
          .set({'joinedAt': FieldValue.serverTimestamp(), 'completed': false});
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .update({'participantsCount': FieldValue.increment(1)});
    } catch (e) {
      print('Error joining challenge: $e');
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .collection('participants')
          .doc(userId)
          .update({
            'completed': true,
            'completedAt': FieldValue.serverTimestamp(),
          });
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .update({'completedCount': FieldValue.increment(1)});
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'challengesCompleted': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error completing challenge: $e');
    }
  }

  Future<double> calculateProgress(String challengeType) async {
    double progress = 0;
    try {
      QuerySnapshot workouts = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .get();
      if (challengeType == 'running') {
        for (var workout in workouts.docs) {
          var data = workout.data() as Map<String, dynamic>;
          if (data['type'] == 'Running') {
            String details = data['details'] ?? '';
            if (details.contains('Distance:')) {
              String distanceStr = details
                  .split('Distance:')[1]
                  .split('miles')[0]
                  .trim();
              progress += double.tryParse(distanceStr) ?? 0;
            }
          }
        }
      } else if (challengeType == 'biking') {
        for (var workout in workouts.docs) {
          var data = workout.data() as Map<String, dynamic>;
          if (data['type'] == 'Biking') {
            String details = data['details'] ?? '';
            if (details.contains('Distance:')) {
              String distanceStr = details
                  .split('Distance:')[1]
                  .split('miles')[0]
                  .trim();
              progress += double.tryParse(distanceStr) ?? 0;
            }
          }
        }
      } else if (challengeType == 'workouts') {
        progress = workouts.docs.length.toDouble();
      } else if (challengeType == 'streak') {
        if (workouts.docs.isEmpty) return 0;
        List<DateTime> workoutDates = [];
        for (var workout in workouts.docs) {
          var data = workout.data() as Map<String, dynamic>;
          DateTime workoutDate = DateTime.parse(data['date']);
          DateTime workoutDay = DateTime(
            workoutDate.year,
            workoutDate.month,
            workoutDate.day,
          );
          bool alreadyAdded = false;
          for (var date in workoutDates) {
            if (date.year == workoutDay.year &&
                date.month == workoutDay.month &&
                date.day == workoutDay.day) {
              alreadyAdded = true;
              break;
            }
          }
          if (!alreadyAdded) {
            workoutDates.add(workoutDay);
          }
        }
        workoutDates.sort((a, b) => b.compareTo(a));

        if (workoutDates.isEmpty) return 0;

        int streak = 1;
        DateTime currentDate = workoutDates[0];

        for (int i = 1; i < workoutDates.length; i++) {
          DateTime previousDate = workoutDates[i];
          int daysBetween = currentDate.difference(previousDate).inDays;

          if (daysBetween == 1) {
            streak++;
            currentDate = previousDate;
          } else {
            break;
          }
        }

        progress = streak.toDouble();
      }
    } catch (e) {
      print('Error calculating progress: $e');
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenges')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No challenges available'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var challenge = snapshot.data!.docs[index];
              var challengeData = challenge.data() as Map<String, dynamic>;
              String challengeType = challengeData['type'] ?? '';
              double goal = (challengeData['goal'] ?? 0).toDouble();
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('challenges')
                    .doc(challenge.id)
                    .collection('participants')
                    .doc(userId)
                    .snapshots(),
                builder: (context, participantSnapshot) {
                  bool hasJoined =
                      participantSnapshot.hasData &&
                      participantSnapshot.data!.exists;
                  bool hasCompleted = false;
                  if (hasJoined) {
                    var participantData =
                        participantSnapshot.data!.data()
                            as Map<String, dynamic>?;
                    hasCompleted = participantData?['completed'] ?? false;
                  }
                  return FutureBuilder<double>(
                    future: hasJoined
                        ? calculateProgress(challengeType)
                        : Future.value(0),
                    builder: (context, progressSnapshot) {
                      double progress = progressSnapshot.data ?? 0;
                      bool canComplete =
                          hasJoined && progress >= goal && !hasCompleted;
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
                            Text(
                              challengeData['title'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(challengeData['description'] ?? ''),
                            SizedBox(height: 12),
                            if (hasJoined)
                              Text(
                                'Progress: ${progress.toInt()} / ${goal.toInt()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Participants: ${challengeData['participantsCount'] ?? 0}',
                                ),
                                SizedBox(width: 20),
                                Text(
                                  'Completed: ${challengeData['completedCount'] ?? 0}',
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (!hasJoined)
                              GestureDetector(
                                onTap: () => joinChallenge(challenge.id),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Join Challenge',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              )
                            else if (!hasCompleted && canComplete)
                              GestureDetector(
                                onTap: () => completeChallenge(challenge.id),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    color: Colors.green.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Mark as Complete',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else if (!hasCompleted)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: Text(
                                    'Keep Going!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
