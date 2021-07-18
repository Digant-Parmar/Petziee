// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import 'RequestPawsList.dart';

class PawsList extends StatefulWidget {
  const PawsList({Key key}) : super(key: key);

  @override
  _PawsListState createState() => _PawsListState();
}

class _PawsListState extends State<PawsList> {

  Stream<QuerySnapshot>getPawsStream(){
    return pawsReference
        .doc(currentUser.id)
        .collection("userPaws")
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
               return HelperList(id: snapshot.data.docs[index].id,type: "removePaw",);
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
