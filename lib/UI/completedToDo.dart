import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:students_data/constants/colors.dart';

class completedToDo extends StatefulWidget {
  const completedToDo({super.key});

  @override
  State<completedToDo> createState() => _completedToDoState();
}

class _completedToDoState extends State<completedToDo> {
  // final TextEditingController _titleController = TextEditingController();
  // final TextEditingController _descriptionController = TextEditingController();

  // Declare user variable here
  late User? user;

  @override
  void initState() {
    super.initState();

    // Initialize user variable in initState
    user = FirebaseAuth.instance.currentUser;
  }

  // Future<void> saveDataToFirestore(String title, String description) async {
  //   if (title.isNotEmpty && description.isNotEmpty) {
  //     try {
  //       // Use the null-aware operator to check if user is not null
  //       if (user != null) {
  //         CollectionReference todos = FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user!.uid) // Use the current user's UID as the document ID
  //             .collection('todos');

  //         await todos.add({
  //           'title': title,
  //           'description': description,
  //           'completed':
  //               false, // Add the 'completed' field with a default value
  //           'star': false,
  //         });

  //         print('Data saved to Firestore successfully');

  //         _titleController.clear();
  //         _descriptionController.clear();
  //       } else {
  //         print('User is not signed in.');
  //       }
  //     } catch (error) {
  //       print('Error saving data to Firestore: $error');
  //     }
  //   }
  // }

  // Future<void> deleteDocument(String documentId) async {
  //   try {
  //     CollectionReference todos = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user!.uid)
  //         .collection('todos');

  //     await todos.doc(documentId).delete();

  //     print('Document deleted successfully');
  //   } catch (error) {
  //     print('Error deleting document: $error');
  //   }
  // }

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: Text(
          'Completed Task',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => home(),
            //   ),
            // );
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('todos') // Access the 'todos' sub-collection
                  .where('completed', isEqualTo: true)
                  .orderBy('title')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final users = snapshot.data!.docs;
                  return ListView.builder(
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
                          // icon: Icon(Icons.circle_outlined),
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
          ),
        ],
      ),
    );
  }
}
