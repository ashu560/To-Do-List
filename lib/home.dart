// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text editing controllers to capture input from text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Method to save data to Firestore
  Future<void> saveDataToFirestore(String firstName, String lastName) async {
    // Check if the entered first name and last name are not empty
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      try {
        CollectionReference students =
            FirebaseFirestore.instance.collection('students');

        await students.add({
          'firstName': firstName,
          'lastName': lastName,
        });

        // Print success message if data is saved successfully
        print('Data saved to Firestore successfully');

        // Clear the text fields
        _firstNameController.clear();
        _lastNameController.clear();
      } catch (error) {
        // Print error message if there's an error saving data
        print('Error saving data to Firestore: $error');
      }
    }
  }

  // Method to delete a document from Firestore
  Future<void> deleteDocument(String documentId) async {
    try {
      // Reference to the 'Students' collection in Firestore
      CollectionReference students =
          FirebaseFirestore.instance.collection('students');

      // Delete the document with the given documentId
      await students.doc(documentId).delete();

      // Print success message if document is deleted successfully
      print('Document deleted successfully');
    } catch (error) {
      // Print error message if there's an error deleting the document
      print('Error deleting document: $error');
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
            "CRUD - OPERATION",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: const Icon(
            Icons.handshake,
            color: Colors.white,
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Text field for entering the first name
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  hintText: "Ashutosh",
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ),
            // Text field for entering the last name
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  hintText: "Deshmukh",
                  hintStyle: TextStyle(
                    fontSize: 12,
                  ),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ),
            // Button to save the entered data to Firestore
            ElevatedButton(
              onPressed: () {
                // Get the entered first name and last name
                String firstName = _firstNameController.text;
                String lastName = _lastNameController.text;

                // Call the method to save data to Firestore
                saveDataToFirestore(firstName, lastName);
              },
              child: const Text('Save Data'),
            ),
            const SizedBox(height: 20),
            Text(
              'Students:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .orderBy('firstName')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user =
                            users[index].data() as Map<String, dynamic>;
                        final firstName = user['firstName'];
                        final lastName = user['lastName'];
                        final documentId = users[index].id;
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text('$firstName $lastName'),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Call the method to delete the document
                              deleteDocument(documentId);
                            },
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Error loading users');
                  } else {
                    return const CircularProgressIndicator();
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
