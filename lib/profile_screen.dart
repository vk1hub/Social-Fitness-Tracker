import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';
          double height = (userData['height'] ?? 0).toDouble();
          double currentWeight = (userData['currentWeight'] ?? 0).toDouble();
          String funFact = userData['funFact'] ?? '';
          String fitnessLevel = userData['fitnessLevel'] ?? '';
          String goal = userData['goal'] ?? '';
          int postsCount = userData['postsCount'] ?? 0;
          int challengesCompleted = userData['challengesCompleted'] ?? 0;
          int workoutsCount = userData['workoutsCount'] ?? 0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Text(
                      firstName.isNotEmpty ? firstName[0] : '',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                Center(
                  child: Text(
                    '$firstName $lastName',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$postsCount',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Posts'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$challengesCompleted',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Challenges'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$workoutsCount',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Workouts'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      
                      Text('Height: ${height.toInt()} inches'),
                      SizedBox(height: 8),
                      
                      Text('Weight: ${currentWeight.toInt()} lbs'),
                      SizedBox(height: 8),
                      
                      Text('Fitness Level: $fitnessLevel'),
                      SizedBox(height: 8),
                      
                      Text('Goal: $goal'),
                      
                      if (funFact.isNotEmpty) ...[
                        SizedBox(height: 15),
                        Text(
                          'Fun Fact:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(funFact),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 30),
              
              Text(
                'Recent Workouts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('workouts')
                    .orderBy('date', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, workoutSnapshot) {
                  if (workoutSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!workoutSnapshot.hasData || workoutSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No workouts yet'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: workoutSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var workout = workoutSnapshot.data!.docs[index];
                      var workoutData = workout.data() as Map<String, dynamic>;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workoutData['type'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              workoutData['name'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(workoutData['details'] ?? ''),
                            
                            if (workoutData['photoUrl'] != null && workoutData['photoUrl'].isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Image.network(
                                  workoutData['photoUrl'],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}