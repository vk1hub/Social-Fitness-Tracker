import 'package:flutter/material.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  ChallengesScreenState createState() => ChallengesScreenState();
}

class ChallengesScreenState extends State<ChallengesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildChallengeCard(
            title: 'Run 100 Miles',
            description: 'Run a total of 100 miles',
          ),
          SizedBox(height: 12),
          buildChallengeCard(
            title: 'Log 10 Workouts',
            description: 'Log 10 workouts total',
          ),
          SizedBox(height: 12),
          buildChallengeCard(
            title: '7-Day Streak',
            description: 'Work out 7 days in a row',
          ),
          SizedBox(height: 12),
          buildChallengeCard(
            title: 'Bike 25 Miles',
            description: 'Bike a total of 25 miles',
          ),
        ],
      ),
    );
  }

  Widget buildChallengeCard({
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(description),
          SizedBox(height: 12),
          Container(
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
        ],
      ),
    );
  }
}