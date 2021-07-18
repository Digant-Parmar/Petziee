// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import 'ChatItem.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {


  Icon searchIcon = new Icon(Icons.search_rounded, color: Colors.white,);
  Widget appBarTitle = new Text(
    "Chat Area", style: TextStyle(color: Colors.white),);

  // bool setSeen = false;
  Stream chatRoomStream;
  Map<String, dynamic>otherUser;


  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
  }

  Stream<QuerySnapshot> getFormDatabase() {
    // print("CU: ${currentUser.username}");
    Stream<QuerySnapshot>queryUsers = FirebaseFirestore.instance.collection(
        "chatRoom")
        .where("users",arrayContains: currentUser.id)
        .orderBy('time', descending: true)
        .snapshots();
    // queryUsers.forEach((element) {
    //   print("Others is ${element.docs.length}");
    // });

    return queryUsers;
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: getFormDatabase(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (BuildContext context, int index) {
              String otherUserId =  snapshot.data.docs[index].get("chatRoomId").toString()
                  .replaceAll("_", "") .replaceAll(currentUser.id, "");
              return snapshot.data.docs[index].get(currentUser.id) && snapshot.data.docs[index].get("lastMessage")!=null? ChatItem
                (
                time: snapshot.data.docs[index].get("time"),
                message: snapshot.data.docs[index].get("lastMessage"),
                sentBy:snapshot.data.docs[index].get("sendBy"),
                isVisible: snapshot.data.docs[index].get(otherUserId),
                // isOnline: _user.isOnline,
                counter: 0,
                setSeen: snapshot.data.docs[index].get("seenBy${currentUser.id}"),
                chatRoomId:snapshot.data.docs[index].get("chatRoomId").toString(),
                // seen: seen,
              ):Container();
            },
            separatorBuilder: (BuildContext context, int index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 0.5,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 1.3,
                  child: Divider(),
                ),
              );
            },
            itemCount: snapshot.data.docs.length,
          );
        }
        return Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50), child: buildAppBar(context)),
      body: chatRoomList(),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      // backgroundColor: Colors.grey[800].withOpacity(0.3),
      automaticallyImplyLeading: false,
      title: appBarTitle,
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.more_vert),
      //     //TODO: Implememt Search in chat screen onPressed Methods
      //     onPressed: () {
      //       setState(() {
      //         setSeen = !setSeen;
      //       });
      //     },
      //   ),
      // ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
