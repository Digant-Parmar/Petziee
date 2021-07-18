// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import 'RequestPawsList.dart';

class TailsList extends StatefulWidget {
  const TailsList({Key key}) : super(key: key);

  @override
  _TailsListState createState() => _TailsListState();
}

class _TailsListState extends State<TailsList> {

  Stream<QuerySnapshot>getPawsStream(){
    return tailsReference
        .doc(currentUser.id)
        .collection("userTails")
        .where(FieldPath.documentId, isNotEqualTo: currentUser.id)
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
                return HelperList(id: snapshot.data.docs[index].id,type: "removeTail",);
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
