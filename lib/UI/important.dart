import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:students_data/constants/colors.dart';

class important extends StatefulWidget {
  const important({super.key});

  @override
  State<important> createState() => _importantState();
}

class _importantState extends State<important> {
  // Declare user variable here
  late User? user;

  @override
  void initState() {
    super.initState();

    // Initialize user variable in initState
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> starDocument(String documentId) async {
    try {
      CollectionReference todos = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('todos');

      await todos.doc(documentId).delete();

      print('Document starred successfully');
    } catch (error) {
      print('Error star document: $error');
    }
  }

  Future<void> MarkAsStar(String documentID, bool star) async {
    try {
      CollectionReference todos = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('todos');

      await todos.doc(documentID).update({'starred': !star});
      // print('Task marked as starred successfully.');
    } catch (e) {
      print('Error marking task starred : $e');
    }
  }

  Future<void> MarkAsCompleted(String documentID, bool completed) async {
    try {
      CollectionReference todos = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('todos');

      await todos.doc(documentID).update({'completed': !completed});
      // print('Task marked as completed successfully.');
    } catch (e) {
      print('Error marking task completed : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('todos')
              .where('starred', isEqualTo: true)
              .where('completed', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final users = snapshot.data!.docs;
              return Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final completed = user['completed'] ?? false;
                    final starred = user['starred'] ?? false;
                    final title = user['title'];
                    final description = user['description'];
                    final documentId = users[index].id;

                    return ListTile(
                      leading: IconButton(
                        onPressed: () => {
                          MarkAsCompleted(documentId, completed),
                        },
                        icon: Icon(
                          completed
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: AppColors.completed,
                        ),
                      ),
                      title: Text(
                        '$title',
                        style: TextStyle(
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        '$description',
                        style: TextStyle(
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Wrap(children: [
                        IconButton(
                          onPressed: () {
                            MarkAsStar(documentId, starred);
                          },
                          icon: Icon(
                            starred ? Icons.star : Icons.star_border,
                            color: AppColors.starred,
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error loading users: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }
}
