import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:students_data/Login/loginPage.dart';
import 'package:students_data/UI/addTodos.dart';
import 'package:students_data/UI/completedToDo.dart';
import 'package:students_data/UI/important.dart';
import 'package:students_data/constants/colors.dart';
import 'package:students_data/constants/toDoListTile.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> with SingleTickerProviderStateMixin {
  // Declare user variable here
  late User? user;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize user variable in initState
    user = FirebaseAuth.instance.currentUser;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    // Dispose of the TabController to avoid memory leaks
    _tabController.dispose();
    super.dispose();
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
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "To Do List",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => completedToDo(),
                ),
              );
            },
            icon: Icon(
              Icons.checklist_sharp,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: SignUserOut,
              icon: Icon(Icons.logout),
              color: Colors.black,
            ),
          ],
          elevation: 0,
          bottom: TabBar(
            dividerColor: Colors.deepPurpleAccent,
            dividerHeight: 0.3,
            indicatorColor: Colors.deepPurpleAccent,
            enableFeedback: true,
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(Icons.star, color: AppColors.starred),
              ),
              Tab(
                child: Text(
                  'Home',
                  style: TextStyle(
                      color: AppColors.starred, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          // starredToDo(),
          important(),
          toDoListTile(),
        ]),
        floatingActionButton: AddToDoBtn(),
      ),
    );
  }
}
