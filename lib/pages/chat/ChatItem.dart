// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/CustomDialogWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import '../HomePage.dart';
import 'ConversationScreen.dart';



class ChatItem extends StatefulWidget {

  // final String dp;
  // final String id;
  // final String name;
  final int time;
  final String sentBy;
  final String message;
  final bool isVisible;
  // final bool isOnline;
  final int counter;
  final String chatRoomId;
  final bool setSeen;


  ChatItem({
   Key key,
    // @required this.dp,
    // @required this.id,
    // @required this.name,
    // @required this.isOnline,
    // @required this.seen,
    @required this.time,
    @required this.isVisible,
    @required this.message,
    @required this.counter,
    @required this.sentBy,
    this.setSeen,
    this.chatRoomId,
}):super(key:key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {

  User _otherUser;
  bool isLoading =  true;
  bool seen;

  @override
  void initState() {
    getOtherUserInfo();
    super.initState();
  }

  getOtherUserInfo() async {
    String userId = widget.chatRoomId.replaceAll("_", "").replaceAll(currentUser.id, "");
    DocumentSnapshot documentSnapshot = await usersReference.doc(userId).get();
    if (!documentSnapshot.exists) {
      documentSnapshot = await usersReference.doc(userId).get();
    }
    User _user = User.fromDocument(documentSnapshot);
    // bool _isSeen = false;
    // if(_user.lastOnline< widget.time && widget.sentBy==_user.username){
    //   _isSeen = true;
    // }else{
    //   _isSeen = false;
    // }
    print("Other ser is ${_user.username}");
    setState(() {
      // seen = _isSeen;
      _otherUser = _user;
      isLoading = false;
    });
    //
    //  int count = 1;
    //
    //  String username =  user.username;
    //
    //  String profileImage = user.humanUrl;
    //  bool isOnline = user.isOnline;
    //  int lastOnline = user.lastOnline;
    //
    // // int count = getMessagesCount(chatRoomId);
    //  DocumentSnapshot dox = await FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).get();
    //  String message = dox.get("lastMessage");
    //  int time = dox.get("time");
    //  bool seen = false;
    //
    //  if(lastOnline< time && dox.get("sendBy").toString()==username){
    //    seen = true;
    //  }else{
    //    seen = false;
    //  }

    // otherUser = {
    //   "dp": profileImage,
    //   "id":userId,
    //   "name" : username,
    //   "counter" : count,
    //   "message" : message,
    //   "time" : (DateFormat.jm().format( DateTime.fromMillisecondsSinceEpoch(int.parse(time.toString())))).toString(),
    //   "isOnline": isOnline,
    //   "seen" : seen
    // };
    // print("other user ${otherUser['name']}");

  }

  // getTime(int time){
  //   int hour = DateTime.fromMillisecondsSinceEpoch(time).hour;
  //   int min = DateTime.fromMillisecondsSinceEpoch(time).minute;
  //
  //   if(hour > 12){
  //     return "${hour-12}:$min PM";
  //   }else if(hour ==12){
  //     return "$hour:$min PM";
  //   }else{
  //     return "$hour:$min AM";
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return !isLoading?ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage:CachedNetworkImageProvider(
              _otherUser.humanUrl,
            ),
            radius: 25,
          ),
          // Positioned(
          //   bottom: 0.0,
          //   left: 6.0,
          //   child: Container(
          //     height: 11,
          //     width: 11,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(6),
          //     ),
          //     child: Center(
          //       child: Container(
          //         height: 7,
          //         width: 7,
          //         decoration: BoxDecoration(
          //           color: widget.isOnline?Colors.greenAccent:Colors.grey,
          //           borderRadius: BorderRadius.circular(6),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      title: Text(
        _otherUser.username,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        "${widget.message}",
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10,),
          Text(
            (DateFormat.jm().format( DateTime.fromMillisecondsSinceEpoch(widget.time))).toString(),
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 5,),
          //For The number of messages unseen
          !widget.setSeen?
          // Container(
          //   padding: EdgeInsets.all(1),
          //   decoration: BoxDecoration(
          //     color: Colors.redAccent,
          //     borderRadius: BorderRadius.circular(6),
          //   ),
          //   constraints: BoxConstraints(
          //     minWidth: 11,
          //     minHeight: 11,
          //   ),
          //   child: Padding(
          //     padding: EdgeInsets.only(top: 1, left: 5, right: 5),
          //     child: Text(
          //       "${widget.counter}",
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 10,
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
          // ),
          Container(
            margin: EdgeInsets.only(right: 15),
              height: 7,
              width: 7,
              decoration: BoxDecoration(
                color: _otherUser.isOnline?Colors.greenAccent:Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
            ):SizedBox(),
        ],
      ),
      onTap: (){
        showGeneralDialog(
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return  ConversationScreen(chatRoomId: widget.chatRoomId,otherUser: _otherUser,profile: false,
                isVisible: widget.isVisible,
              );
            },
            barrierLabel: "Label",
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 300),
            transitionBuilder: (context, anim1, anim2, child) {
              return SlideTransition(
                position:
                Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(anim1),
                child: child,
              );
            });
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (BuildContext context){
        //       return ConversationScreen(chatRoomId: widget.chatRoomId,otherUserId:_otherUser.id, otherUsername: _otherUser.username,profile: false,isVisible: widget.isVisible,);
        //     }
        //   ),
        // );
      },
      onLongPress: (){
        showModalBottomSheet(
            elevation: 10,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: Colors.grey[900],
            context: context,
            builder: (context) {
              return ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    title: Text("Delete chat"),
                    onTap: (){
                      deleteChat();
                    },
                  ),
                ],
              );
            });
      },
    ):Container();
  }

  deleteChat()async{
    await CustomDialogWidget().showDialog(
        context,
      title: "Delete Chat",
      acceptButtonText: "Delete",
      cancelButtonText: "Cancel",
      message: "This chat will be deleted from you.",
      data: {
          "chatRoomId": widget.chatRoomId,
        "time": widget.time,
      },
    );
  }

}
