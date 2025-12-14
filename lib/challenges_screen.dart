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
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('challenges').get();
      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('challenges').doc('run-100-miles').set({
          'title': 'Run 100 Miles',
          'description': 'Run a total of 100 miles',
          'goal': 100,
          'type': 'running',
          'participantsCount': 0,
          'completedCount': 0,
        });
        await FirebaseFirestore.instance.collection('challenges').doc('log-10-workouts').set({
          'title': 'Log 10 Workouts',
          'description': 'Log 10 workouts total',
          'goal': 10,
          'type': 'workouts',
          'participantsCount': 0,
          'completedCount': 0,
        });
        await FirebaseFirestore.instance.collection('challenges').doc('7-day-streak').set({
          'title': '7-Day Streak',
          'description': 'Work out 7 days in a row',
          'goal': 7,
          'type': 'streak',
          'participantsCount': 0,
          'completedCount': 0,
        });
        await FirebaseFirestore.instance.collection('challenges').doc('bike-25-miles').set({
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
          .set({
        'joinedAt': FieldValue.serverTimestamp(),
        'completed': false,
      });
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .update({
        'participantsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error joining challenge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
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
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('challenges')
                    .doc(challenge.id)
                    .collection('participants')
                    .doc(userId)
                    .snapshots(),
                builder: (context, participantSnapshot) {
                  bool hasJoined = participantSnapshot.hasData && participantSnapshot.data!.exists;
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(challengeData['description'] ?? ''),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Participants: ${challengeData['participantsCount'] ?? 0}'),
                            SizedBox(width: 20),
                            Text('Completed: ${challengeData['completedCount'] ?? 0}'),
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
                                child: Text('Join Challenge', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Center(
                              child: Text('Joined', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
      ),
    );
  }
}