import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_project/model.dart';
import 'package:document_project/view_tickets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'drawer.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final userEmail = FirebaseAuth.instance.currentUser!;
  List<String> docIds = [];

  // get document and add to docList
  Future getDocId() async {
    // docIds.clear();
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              // looping through documents
              docIds.add(document.reference.id); //adding document to the list
              // print(docIds.length);
            },
          ),
        );
  }

  //get the data from the database and map
  Stream<List<UserDetail>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => UserDetail.fromJson(doc.data())).toList());

  //build the list
  Widget buildUser(UserDetail user) {
    var index = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(child: Text('D')),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // user.id = FirebaseFirestore.instance
              //     .collection('users')
              //     .doc()
              //     .id;
              // print(user.id);
              getDocId();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docIds[index])
                  .delete();
              docIds.removeAt(index);
              index++;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('You have successfully deleted a product')));
            },
          ),
          title: Text(
              "Document[${user.documentNumber}] found at ${user.placeFound}."),
          subtitle: Text(user.fullName),
          tileColor: Colors.grey[300],
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ListViewClick()));
          },
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Home'),
    ),
    drawer: MyDrawer(),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                userEmail.email!,
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 28,
                    fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 15),
              Text(
                "We are glad that you have come here to help. We really appreciate your effort. Please proceed by opening the drawer on the left side of your screen.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20), // Add some space between the two views
        Expanded(
          child: Center(
            child: StreamBuilder<List<UserDetail>>(
              stream: readUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong... ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final users = snapshot.data!;
                  return ListView(
                    children: users.map<Widget>(buildUser).toList(),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}
}
