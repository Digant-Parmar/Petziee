// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import 'RequestPawsList.dart';

class BlockedTailsList extends StatefulWidget {
  const BlockedTailsList({Key key}) : super(key: key);

  @override
  _BlockedTailsListState createState() => _BlockedTailsListState();
}

class _BlockedTailsListState extends State<BlockedTailsList> {

  Stream<QuerySnapshot>getPawsStream(){
    return tailsReference
        .doc(currentUser.id)
        .collection("blockedTails")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getPawsStream(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return ListView.separated(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return HelperList(id: snapshot.data.docs[index].id,type: "removeBlockedTails",);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
