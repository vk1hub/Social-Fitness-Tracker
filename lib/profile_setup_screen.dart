import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userId;

  ProfileSetupScreen({required this.userId});

  @override
  ProfileSetupScreenState createState() => ProfileSetupScreenState();
}

class ProfileSetupScreenState extends State<ProfileSetupScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController currentWeightController = TextEditingController();
  TextEditingController targetWeightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController funFactController = TextEditingController();
  
  String selectedFitnessLevel = 'Beginner';
  String selectedGoal = 'Maintain Weight';
  bool isLoading = false;

  Future<void> saveProfile() async {
    if (firstNameController.text.isEmpty || 
        lastNameController.text.isEmpty ||
        currentWeightController.text.isEmpty ||
        heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // user profile attributes
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'fitnessLevel': selectedFitnessLevel,
        'goal': selectedGoal,
        'currentWeight': double.parse(currentWeightController.text),
        'targetWeight': targetWeightController.text.isEmpty ? 
                       double.parse(currentWeightController.text) : 
                       double.parse(targetWeightController.text),
        'height': double.parse(heightController.text),
        'funFact': funFactController.text,
        'profilePictureUrl': '',
        'blurProfile': false,
        'createdAt': FieldValue.serverTimestamp(),
        'postsCount': 0,
        'challengesCompleted': 0,
        'workoutsCount': 0,
      });
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
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
        title: Text('Setup Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (inches) *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            
            TextField(
              controller: currentWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Weight (lbs) *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            
            TextField(
              controller: targetWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Weight (lbs)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            
            TextField(
              controller: funFactController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Fun Fact',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            Text('Fitness Level', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedFitnessLevel,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['Beginner', 'Intermediate', 'Advanced'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFitnessLevel = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            
            Text('Goal', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedGoal,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['Lose Weight', 'Gain Weight', 'Maintain Weight'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGoal = newValue!;
                });
              },
            ),
            SizedBox(height: 30),
            
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              GestureDetector(
                onTap: saveProfile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      'Complete Setup',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}