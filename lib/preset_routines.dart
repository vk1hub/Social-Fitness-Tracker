import 'package:flutter/material.dart';

class PresetRoutinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Preset Routines'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Beginner'),
              Tab(text: 'Intermediate'),
              Tab(text: 'Advanced'),
            ],
          ),
        ),
        body: TabBarView(
          children: [

            // Beginner Routine tab
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Push (Chest, Shoulders, Triceps)'),
                    subtitle: Text(
                      '- Push ups \n- Shoulder press \n- Tricep dips',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Pull (Back, Biceps)'),
                    subtitle: Text('- Pull ups \n- Bicep curls \n- Seated row'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Legs'),
                    subtitle: Text('- Squat \n- Calf raises \n- Lunges'),
                  ),
                ),
              ],
            ),

            // Intermediate Routine tab
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Push (Chest, Shoulders, Triceps)'),
                    subtitle: Text(
                      '- Bench Press \n- Shoulder press \n- Tricep Extensions \n- Lateral Raises',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Pull (Back, Biceps)'),
                    subtitle: Text(
                      '- Pull ups \n- Bicep curls \n- Hammer Curls \n- Seated row',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Legs'),
                    subtitle: Text(
                      '- Squat \n- Calf raises \n- Lunges \n- Leg Extensions',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Abs'),
                    subtitle: Text(
                      '- Plank \n- Russian Twists',
                    ),
                  ),
                ),
              ],
            ),

            // Advanced routine tab
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Push (Chest, Shoulders, Triceps)'),
                    subtitle: Text(
                      '- Bench Press \n- Shoulder press \n- Tricep Extensions \n- Lateral Raises \n- Incline Dumbbell Press \n- Tricep Pushdowns',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Pull (Back, Biceps)'),
                    subtitle: Text(
                      '- Pull ups \n- Bicep curls \n- Hammer Curls \n- Seated row \n- Seated Dumbbell Curls \n- Face Pulls',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Legs'),
                    subtitle: Text(
                      '- Squat \n- Calf raises \n- Lunges \n- Leg Extensions \n- Hamstring Curls \n- Hip Thrusts',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Abs'),
                    subtitle: Text(
                      '- Plank \n- Russian Twists \n- Leg Raises',
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
