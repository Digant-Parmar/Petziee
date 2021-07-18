// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/SearchWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import '../HomePage.dart';

class PawsTails extends StatefulWidget {
  @override
  _PawsTailsState createState() => _PawsTailsState();
}

class _PawsTailsState extends State<PawsTails> {
  bool isLoading = true;
  List<QueryDocumentSnapshot> pawsSnapshot;
  List<QueryDocumentSnapshot> tailsSnapshot;

  final key = new GlobalKey<ScaffoldState>();
  List<UserResult> userPaws = [];
  List<UserResult> userTails = [];

  getUsers() async {
    pawsSnapshot.forEach((element) async {
      DocumentSnapshot tempDoc = await usersReference.doc(element.id).get();
      User user = User.fromDocument(tempDoc);
      UserResult userResult = UserResult(
        eachUser: user,
        isMap: false,
        isPawTail: true,
        type: "removePaw",
      );
      setState(() {
        userPaws.add(userResult);
      });
    });

    tailsSnapshot.forEach((element) async {
      DocumentSnapshot tempDoc = await usersReference.doc(element.id).get();
      User user = User.fromDocument(tempDoc);
      UserResult userResult = UserResult(
        eachUser: user,
        isMap: false,
        isPawTail: true,
        type: "removeTail",
      );
      setState(() {
        userTails.add(userResult);
      });
    });
  }

  getPawsAndTails() async {
    QuerySnapshot tempPaws = await pawsReference
        .doc(currentUser.id)
        .collection("userPaws")
        .where(FieldPath.documentId, isNotEqualTo: currentUser.id)
        .get();
    QuerySnapshot tempTails = await tailsReference
        .doc(currentUser.id)
        .collection("userTails")
        .where(FieldPath.documentId, isNotEqualTo: currentUser.id)
        .get();

    setState(() {
      pawsSnapshot = tempPaws.docs.toList();
      tailsSnapshot = tempTails.docs.toList();
      isLoading = false;
    });
    getUsers();
  }

  @override
  void initState() {
    getPawsAndTails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: key,
        appBar: AppBar(
          title: Text("Paws & Tails"),
          bottom: TabBar(
            tabs: [
              Text(
                "Paws",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Tails",
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    elevation: 10,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    // backgroundColor: Colors.grey[900],
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: Text("Paws"),
                              subtitle: Text(
                                  "Paws are the one who has allowed you to access their location"),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Tails"),
                              subtitle: Text(
                                  "Tails are the one whom you have given access to your location"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          ],
        ),
        body: TabBarView(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: userPaws.length,
                    itemBuilder: (context, index) {
                      return userPaws[index];
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
            // },),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: userTails.length,
                    itemBuilder: (context, index) {
                      return userTails[index];
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
            // },),
          ],
        ),
      ),
    );
  }
}
