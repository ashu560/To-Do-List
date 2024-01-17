import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "Title",
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Description",
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String description = _descriptionController.text;
                saveDataToFirestore(title, description);
              },
              child: const Text('Save Data'),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Todo\'s:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
                        final title = user['title'];
                        final description = user['description'];
                        final documentId = users[index].id;

                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text('$title'),
                          subtitle: Text('$description'),
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
      ),
    );
  }
}
