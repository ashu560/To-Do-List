// ignore_for_file: override_on_non_overriding_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RationCard extends StatefulWidget {
  const RationCard({Key? key}) : super(key: key);

  @override
  State<RationCard> createState() => _RationCardState();
}

class _RationCardState extends State<RationCard> {
  List searchResult = [];

  List _allResults = [];

  // @override
  // void initstate() {
  //   getClientStream();
  //   super.initState();
  // }

  // getClientStream() async {
  //   var data = await FirebaseFirestore.instance.collection('users').get();

  //   setState(() {
  //     _allResults = data.docs;
  //   });
  // }

  void searchFromFirebase(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('ration')
        .where('sr', arrayContains: query)
        .get();

    print('Query: $query');
    print('Result: ${result.docs.length} documents');

    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search Here",
              ),
              onChanged: (query) {
                searchFromFirebase(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _allResults[index]['todos'],
                  ),
                  subtitle: Text(
                    _allResults[index]['cardno'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
