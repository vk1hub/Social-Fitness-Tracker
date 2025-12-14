import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoJournalScreen extends StatefulWidget {
  @override
  PhotoJournalScreenState createState() => PhotoJournalScreenState();
}

class PhotoJournalScreenState extends State<PhotoJournalScreen> {
  String userId = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      File imageFile = File(image.path);
      String fileName = 'journal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('photo_journal')
          .child(userId)
          .child(fileName);
      await storageRef.putFile(imageFile);
      String downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('photo_journal')
          .add({
        'photoUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error uploading photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading photo')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePhoto(String photoId, String photoUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('photo_journal')
          .doc(photoId)
          .delete();
      await FirebaseStorage.instance.refFromURL(photoUrl).delete();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Journal'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('photo_journal')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No photos yet\nTap + to add your first photo'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var photo = snapshot.data!.docs[index];
              var photoData = photo.data() as Map<String, dynamic>;
              String photoUrl = photoData['photoUrl'] ?? '';
              Timestamp? timestamp = photoData['timestamp'];
              String dateText = '';
              if (timestamp != null) {
                DateTime date = timestamp.toDate();
                dateText = '${date.month}/${date.day}/${date.year}';
              }
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text('Delete Photo'),
                                content: Text('Are you sure you want to delete this photo?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deletePhoto(photo.id, photoUrl);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Icon(Icons.delete, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Image.network(
                      photoUrl,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
              onPressed: addPhoto,
              child: Icon(Icons.add_a_photo),
            ),
    );
  }
}