import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:students_data/addTodos.dart';
import 'package:students_data/loginPage.dart';

class ToDo extends StatefulWidget {
  const ToDo({Key? key}) : super(key: key);

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Declare user variable here
  late User? user;

  @override
  void initState() {
    super.initState();

    // Initialize user variable in initState
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

      print('Document deleted successfully');
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  void SignUserOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "To Do List",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: const Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              onPressed: SignUserOut,
              icon: Icon(Icons.logout),
              color: Colors.white,
            ),
          ],
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('todos') // Access the 'todos' sub-collection
                    .orderBy('title')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user =
                            users[index].data() as Map<String, dynamic>;
                        final completed = user['completed'] ?? false;
                        final title = user['title'];
                        final description = user['description'];
                        final documentId = users[index].id;

                        return ListTile(
                          leading: IconButton(
                            onPressed: () => {MarkAsCompleted(documentId,completed)},
                            // icon: Icon(Icons.circle_outlined),
                            icon: Icon(
                              completed
                                  ? Icons.check_circle_outline
                                  : Icons.circle_outlined,
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
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteDocument(documentId);
                            },
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error loading users: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: AddToDoBtn(),
      ),
    );
  }
}
