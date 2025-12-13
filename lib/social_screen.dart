import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'share_workout_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialScreen extends StatefulWidget {
  @override
  SocialScreenState createState() => SocialScreenState();
}

class SocialScreenState extends State<SocialScreen> {
  Future<void> deletePost(String postId, String postUserId) async {
    // confirm / delete
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(postUserId)
          .update({'postsCount': FieldValue.increment(-1)});
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Social Feed')),

      // listing the posts
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts yet'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              var postData = post.data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              child: Text(
                                postData['userName'] != null &&
                                        postData['userName'].isNotEmpty
                                    ? postData['userName'][0]
                                    : '?',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              postData['userName'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (postData['userId'] ==
                            FirebaseAuth.instance.currentUser!.uid)
                          GestureDetector(
                            onTap: () =>
                                deletePost(post.id, postData['userId']),
                            child: Icon(Icons.delete, size: 20),
                          ),
                      ],
                    ),

                    SizedBox(height: 4),
                    Text(
                      postData['timestamp'] != null
                          ? '${(postData['timestamp'] as Timestamp).toDate().month}/${(postData['timestamp'] as Timestamp).toDate().day}/${(postData['timestamp'] as Timestamp).toDate().year}'
                          : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    SizedBox(height: 12),

                    // Workout type
                    Text(
                      postData['workoutType'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Workout name
                    Text(
                      postData['workoutName'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Workout details
                    Text(postData['workoutDetails'] ?? ''),

                    // checking for photo
                    if (postData['photoUrl'] != null &&
                        postData['photoUrl'].isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Image.network(
                          postData['photoUrl'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShareWorkoutScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
