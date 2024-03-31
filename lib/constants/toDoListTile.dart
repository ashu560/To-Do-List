import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:students_data/constants/colors.dart';

class toDoListTile extends StatefulWidget {
  const toDoListTile({super.key});

  @override
  State<toDoListTile> createState() => _toDoListTileState();
}

class _toDoListTileState extends State<toDoListTile> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> saveDataToFirestore(String title, String description) async {
    if (title.isNotEmpty && description.isNotEmpty) {
      try {
        // Use the null-aware operator to check if user is not null
        if (user != null) {
          CollectionReference todos = FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid) // Use the current user's UID as the document ID
              .collection('todos');

          await todos.add({
            'title': title,
            'description': description,
            'completed':
                false, // Add the 'completed' field with a default value
            'star': false,
          });

          print('Data saved to Firestore successfully');

          _titleController.clear();
          _descriptionController.clear();
        } else {
          print('User is not signed in.');
        }
      } catch (error) {
        print('Error saving data to Firestore: $error');
      }
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      CollectionReference todos = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('todos');

      await todos.doc(documentId).delete();
      await Future.delayed(
        Duration(milliseconds: 15),
      );

      print('Document deleted successfully');
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  // Future<void> starDocument(String documentId) async {
  //   try {
  //     CollectionReference todos = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user!.uid)
  //         .collection('todos');

  //     await todos.doc(documentId).delete();

  //     print('Document starred successfully');
  //   } catch (error) {
  //     print('Error star document: $error');
  //   }
  // }

  Future<void> MarkAsCompleted(String documentID, bool completed) async {
    try {
      CollectionReference todos = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('todos');

      await Future.delayed(
        Duration(milliseconds: 15),
      );

      await todos.doc(documentID).update({'completed': !completed});
      // print('Task marked as completed successfully.');
    } catch (e) {
      print('Error marking task completed : $e');
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('todos')
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
                        enableFeedback: true,
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
                      trailing: Wrap(
                        children: [
                          IconButton(
                            onPressed: () {
                              MarkAsStar(documentId, starred);
                            },
                            icon: Icon(
                              starred ? Icons.star : Icons.star_border,
                              color: AppColors.starred,
                            ),
                            enableFeedback: true,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteDocument(documentId);
                            },
                            enableFeedback: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error loading users: ${snapshot.error}');
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }
}
