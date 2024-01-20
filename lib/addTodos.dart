import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddToDoBtn extends StatefulWidget {
  const AddToDoBtn({super.key});

  @override
  State<AddToDoBtn> createState() => _AddToDoBtnState();
}

class _AddToDoBtnState extends State<AddToDoBtn> {
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

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add Item'),
              scrollable: true,
              content: Column(
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
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Save Data'),
                  onPressed: () {
                    String title = _titleController.text;
                    String description = _descriptionController.text;
                    saveDataToFirestore(title, description);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
          
        )
      },
      tooltip: 'Add your To Do Item',
      child: const Icon(Icons.add),
    );
  }
}
