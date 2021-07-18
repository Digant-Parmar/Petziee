// @dart=2.9
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petziee/models/ScheduleModel.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import 'EditSchedulePage.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isLoading = false;

  Stream <QuerySnapshot>getTheSchedule(){
   return FirebaseFirestore.instance.collection("schedule").doc("userSchedules").collection(currentUser.id).snapshots();
  }

  var rng = Random();
  @override
  void initState() {
    getTheSchedule();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2F41),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2F41),
        title: Text(
          "Schedule",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8,left: 8,right: 8,),
        child: StreamBuilder<QuerySnapshot>(
          stream: getTheSchedule(),
          builder: (context, snapshot) {
           if(snapshot.hasData && snapshot.data.docs.isNotEmpty){
             return ListView.builder(
               physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
               itemBuilder: (context,index){
                 ScheduleModel temp= ScheduleModel.fromDocument(snapshot.data.docs[index],rng.nextInt(5));
                 return temp;
               },
               itemCount: snapshot.data.docs.length,
             );
           }else{
             return Container();
           }
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){goToScheduleCreatePage();},

        child: Icon(Icons.add),
      ),
    );
  }
  goToScheduleCreatePage()async{
    setState(() {
      _isLoading = true;
    });
    print(_isLoading);
   await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditSchedulePage(isEdit: false,))).then((value){
     getTheSchedule();
   });
  }
}
