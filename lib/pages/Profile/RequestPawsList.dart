// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/SearchWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';

class RequestPawsList extends StatefulWidget {
  const RequestPawsList({Key key}) : super(key: key);

  @override
  _RequestPawsListState createState() => _RequestPawsListState();
}

class _RequestPawsListState extends State<RequestPawsList> {

  Stream<QuerySnapshot>getRequestPawsStream(){
    return tailsReference
        .doc(currentUser.id)
        .collection("requestedTails")
        .snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getRequestPawsStream(),
        builder: (context,snapshot){
          if(snapshot.hasData){
           return ListView.separated(
             itemCount: snapshot.data.docs.length,
             itemBuilder: (context, index) {
               return HelperList(id: snapshot.data.docs[index].id,type: "acceptPaws",isRemove: false,);
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


class HelperList extends StatefulWidget {
  final String id;
  final String type;
  final bool isRemove;

  const HelperList({Key key,this.id,this.type,this.isRemove = true}) : super(key: key);

  @override
  _HelperListState createState() => _HelperListState();
}

class _HelperListState extends State<HelperList> {

  bool _isLoading = true;
  UserResult _result;


  getInfo()async{
    await usersReference.doc(widget.id).get().then((value){
      setState(() {
        _result =  UserResult(
          eachUser: User.fromDocument(value),
          isMap: false,
          isPawTail: true,
          isRemove: widget.isRemove,
          type: widget.type,
        );
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading?Container():_result;
  }
}
