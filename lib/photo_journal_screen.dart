import 'package:flutter/material.dart';

class PhotoJournalScreen extends StatefulWidget {
  @override
  PhotoJournalScreenState createState() => PhotoJournalScreenState();
}

class PhotoJournalScreenState extends State<PhotoJournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Journal'),
      ),
      body: Center(
        child: Text('No photos yet'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}