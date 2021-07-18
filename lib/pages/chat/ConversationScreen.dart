
// @dart=2.9
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:petziee/Notification/CurrentPage.dart';
import 'package:petziee/UploadingWidget/ImageUpload.dart';
import 'package:petziee/UploadingWidget/VideoUpload.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/Profile/ProfilePage.dart';
import 'package:petziee/widgets/CustomDialogWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/pickMedia.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipeable/swipeable.dart';

import '../HomePage.dart';
import 'chat_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final User otherUser;
  final bool profile;
  final bool isVisible;

  //Is visible is for the deleted chat

  ConversationScreen(
      {this.chatRoomId,
      this.otherUser,
      this.profile,
      @required this.isVisible
      });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  // User otherUser;

  final ItemScrollController itemScrollCrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // ScrollController _controller = new ScrollController();

  TextEditingController messageController = new TextEditingController();

  // Stream chatMessageStream;

  bool isFirst;
  bool isLoading = true;

  bool reply = false;
  Map<String, dynamic> ifDeleted = {
    "isDeleted": false,
    "timestamp": null,
  };

  bool isText = true;

  String replyText = "";
  String replyName = "";
  String replyType = "text";

  updateSeen(bool value){
    FirebaseFirestore.instance.collection("chatRoom").doc(widget.chatRoomId).update(
        {
          "seenBy${currentUser.id}":value,
        });
  }

  @override
  void initState() {
    print("in building");
    currentPage = {
      "page": "conversation",
      "chatRoomId": widget.chatRoomId,
    };
    // PhoneDatabase.saveCurrentPage(["conversation","${widget.chatRoomId}"]);
    updateSeen(true);
    reply = false;
    isLoading = true;
    replyText = " ";
    isFirst = true;
    getIfDeleted();
    super.initState();
  }

  initScrollDirection() {
    return itemPositionsListener.itemPositions.value.last.index;
  }

  // Future<int> maxIndex;

  getIfDeleted() async {
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(widget.chatRoomId)
        .collection("deleted")
        .doc(currentUser.id)
        .get()
        .then((value) {
      if (value.exists) {
        print("It exist");
        setState(() {
          ifDeleted["isDeleted"] = true;
          ifDeleted["timestamp"] = value.get('timestamp');
          isLoading = false;
        });
      } else {
        print("It doesnot exist");
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Stream<QuerySnapshot> getMessages() {
    Stream<QuerySnapshot> messages = FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(widget.chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();

    return messages;
  }

  Stream<QuerySnapshot> getMessagesWithDelete() {
    Stream<QuerySnapshot> messages = FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(widget.chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .endAt([ifDeleted["timestamp"]]).snapshots();
    return messages;

  }


  Widget chatMessageList(function) {
    return StreamBuilder(
      stream: function,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //For the reply index scrolling
          return ScrollablePositionedList.builder(
            addAutomaticKeepAlives: true,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            // shrinkWrap: true,
            initialScrollIndex: 0,
            itemScrollController: itemScrollCrollController,
            itemPositionsListener: itemPositionsListener,
            // controller: _controller,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int index) {
             if(index < 0){
               return Swipeable(
                 threshold: 60.0,
                 onSwipeRight: () {
                   setState(() {
                     reply = true;
                     replyName = snapshot.data.docs[snapshot.data.docs.length-1].get("sendBy");
                     if (snapshot.data.docs[snapshot.data.docs.length-1].get("type") != "text") {
                       isText = false;
                       if (snapshot.data.docs[snapshot.data.docs.length-1].get("type") == "video") {
                         replyType = "Video";
                       } else {
                         replyType = "Photo";
                       }
                     } else {
                       replyType = "text";
                     }
                     replyText = snapshot.data.docs[snapshot.data.docs.length-1].get("message");
                   });
                 },
                 onSwipeLeft: () {
                   setState(() {
                     reply = true;
                     replyName = snapshot.data.docs[snapshot.data.docs.length-1].get("sendBy");
                     if (snapshot.data.docs[snapshot.data.docs.length-1].get("type") != "text") {
                       isText = false;
                       if (snapshot.data.docs[snapshot.data.docs.length-1].get("type") == "video") {
                         replyType = "Video";
                       } else {
                         replyType = "Photo";
                       }
                     } else {
                       replyType = "text";
                     }
                     replyText = snapshot.data.docs[snapshot.data.docs.length-1].get("message");
                   });
                 },
                 background: Container(),
                 child: GestureDetector(
                   onTap: snapshot.data.docs[snapshot.data.docs.length-1].get("isReply") == "True"
                       ? () {
                     int i = 0;
                     while (i >= 0) {
                       if (snapshot.data.docs[snapshot.data.docs.length-1].get("replyText") ==
                           snapshot.data.docs[i].get("message")) {
                         print("i is $i");
                         print(
                             "Reply Text :${snapshot.data.docs[snapshot.data.docs.length-1].get("replyText")}");
                         print(
                             "Message : ${snapshot.data.docs[i].get("message")}");
                         break;
                       }
                       i = i + 1;
                     }
                     print("i is $i");

                     // _controller.animateTo(i,
                     //     duration: Duration(milliseconds: 500),
                     //     curve: Curves.easeOut);
                     itemScrollCrollController.scrollTo(
                       index: i,
                       duration: Duration(milliseconds: 700),
                     );
                   }
                       : () {},
                   onLongPress: () {
                     if (snapshot.data.docs[snapshot.data.docs.length-1].get("userId") ==
                         currentUser.id) {
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
                                   title: Text("Unsend"),
                                   onTap: () {
                                     unsendMessage(
                                         snapshot.data.docs[snapshot.data.docs.length-1].id,
                                         snapshot.data.docs[snapshot.data.docs.length-1].get("type"),
                                         snapshot.data.docs[snapshot.data.docs.length-1]
                                             .get("message"));
                                   },
                                 ),
                               ],
                             );
                           });
                     }
                   },
                   child: ChatBubble(
                     message: snapshot.data.docs[snapshot.data.docs.length-1].get("message"),
                     username: snapshot.data.docs[snapshot.data.docs.length-1].get("sendBy")==currentUser.id?currentUser.username:widget.otherUser.username,
                     time: snapshot.data.docs[snapshot.data.docs.length-1].get("time").toString(),
                     type: snapshot.data.docs[snapshot.data.docs.length-1].get("type"),
                     replyText: snapshot.data.docs[snapshot.data.docs.length-1].get("replyText"),
                     isMe: snapshot.data.docs[snapshot.data.docs.length-1].get("userId") ==
                         currentUser.id,
                     isGroup: snapshot.data.docs[snapshot.data.docs.length-1].get("isGroup") == "True",
                     isReply: snapshot.data.docs[snapshot.data.docs.length-1].get("isReply") == "True",
                     replyName: snapshot.data.docs[snapshot.data.docs.length-1].get("sendBy") ==
                         currentUser.username
                         ? currentUser.username
                         : widget.otherUser.username,
                     chatId: snapshot.data.docs[snapshot.data.docs.length-1].id,
                     userId: snapshot.data.docs[snapshot.data.docs.length-1].get("userId"),
                     chatRoomId: widget.chatRoomId,
                     isUploading:
                     snapshot.data.docs[snapshot.data.docs.length-1].get("type") == "video"
                         ? snapshot.data.docs[snapshot.data.docs.length-1].get("isUploading")
                         : false,
                   ),
                 ),
               );
             }
              // Timer( Duration(milliseconds: 100), () =>
              //     scrollController.jumpTo(scrollController.position.maxScrollExtent));
                return Swipeable(
                  threshold: 60.0,
                  onSwipeRight: () {
                    setState(() {
                      reply = true;
                      replyName = snapshot.data.docs[index].get("sendBy");
                      if (snapshot.data.docs[index].get("type") != "text") {
                        isText = false;
                        if (snapshot.data.docs[index].get("type") == "video") {
                          replyType = "Video";
                        } else {
                          replyType = "Photo";
                        }
                      } else {
                        replyType = "text";
                      }
                      replyText = snapshot.data.docs[index].get("message");
                    });
                  },
                  onSwipeLeft: () {
                    setState(() {
                      reply = true;
                      replyName = snapshot.data.docs[index].get("sendBy");
                      if (snapshot.data.docs[index].get("type") != "text") {
                        isText = false;
                        if (snapshot.data.docs[index].get("type") == "video") {
                          replyType = "Video";
                        } else {
                          replyType = "Photo";
                        }
                      } else {
                        replyType = "text";
                      }
                      replyText = snapshot.data.docs[index].get("message");
                    });
                  },
                  background: Container(),
                  child: GestureDetector(
                    onTap: snapshot.data.docs[index].get("isReply") == "True"
                        ? () {
                      int i = 0;
                      while (i >= 0) {
                        if (snapshot.data.docs[index].get("replyText") ==
                            snapshot.data.docs[i].get("message")) {
                          print("i is $i");
                          print(
                              "Reply Text :${snapshot.data.docs[index].get("replyText")}");
                          print(
                              "Message : ${snapshot.data.docs[i].get("message")}");
                          break;
                        }
                        i = i + 1;
                      }
                      print("i is $i");

                      // _controller.animateTo(i,
                      //     duration: Duration(milliseconds: 500),
                      //     curve: Curves.easeOut);
                      itemScrollCrollController.scrollTo(
                        index: i,
                        duration: Duration(milliseconds: 700),
                      );
                    }
                        : () {},
                    onLongPress: () {
                      if (snapshot.data.docs[index].get("userId") ==
                          currentUser.id) {
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
                                    title: Text("Unsend"),
                                    onTap: () {
                                      unsendMessage(
                                          snapshot.data.docs[index].id,
                                          snapshot.data.docs[index].get("type"),
                                          snapshot.data.docs[index]
                                              .get("message")
                                      );
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: ChatBubble(
                      message: snapshot.data.docs[index].get("message"),
                      username: snapshot.data.docs[index].get("sendBy")==currentUser.id?currentUser.username:widget.otherUser.username,
                      time: snapshot.data.docs[index].get("time").toString(),
                      type: snapshot.data.docs[index].get("type"),
                      replyText: snapshot.data.docs[index].get("replyText"),
                      isMe: snapshot.data.docs[index].get("userId") ==
                          currentUser.id,
                      isGroup: snapshot.data.docs[index].get("isGroup") == "True",
                      isReply: snapshot.data.docs[index].get("isReply") == "True",
                      replyName: snapshot.data.docs[index].get("sendBy") ==
                          currentUser.username
                          ? currentUser.username
                          : widget.otherUser.username,
                      chatId: snapshot.data.docs[index].id,
                      userId: snapshot.data.docs[index].get("userId"),
                      chatRoomId: widget.chatRoomId,
                      isUploading:
                      snapshot.data.docs[index].get("type") == "video"
                          ? snapshot.data.docs[index].get("isUploading")
                          : false,
                    ),
                  ),
                );

            },
          );
        }
        return Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
          ),
        );
      },
    );
  }


  unsendMessage(String chatId, String type, String message) async {
    await CustomDialogWidget().showDialog(
      context,
      title: "Message Unsend",
      acceptButtonText: "Unsend",
      cancelButtonText: "Cancel",
      message:
          "Unsend this message.By doing these the message will be deleted from all the users.Do you want to unsend this message?",
      data: {
        "chatId": chatId,
        "chatRoomId": widget.chatRoomId,
        "type": type,
        "message": message
      },
    );
    Navigator.of(context).pop();
  }

  // deleteChat() async {
  //   print("Long Pressed");
  // }

  // scrollToIndex(int index,{String rT, String m}){
  //   int i = index;
  //   while(i>=0){
  //     if(snapshot.data.documents[index].get("replyText") == snapshot.data.documents[i].get("message")){
  //       print("i is $i");
  //       print("Reply Text :${snapshot.data.documents[index].get("replyText")}");
  //       print("Message : ${snapshot.data.documents[i].get("message")}");
  //       break;
  //     }
  //     i = i+1;
  //   }
  //   print("i is $i");
  //
  //   itemScrollCrollController.scrollTo(index: i, duration: Duration(milliseconds: 500),);
  //
  // }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        // "username": currentUser.username,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": reply ? replyType : "text",
        "replyText": reply ? replyText : "",
        "sendBy": currentUser.username,
        "isGroup": "False",
        "isReply": reply ? "True" : "False",
        "replyName": reply ? replyName : "",
        "userId": currentUser.id,
      };

      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(widget.chatRoomId)
          .collection("chats")
          .add(messageMap)
          .catchError((e) {
        print(e.toString());
      });
      if (!widget.isVisible) {
        FirebaseFirestore.instance
            .collection("chatRoom")
            .doc(widget.chatRoomId)
            .update({
          "${widget.otherUser.id}": true,
          "${currentUser.id}": true,
        });
      }
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(widget.chatRoomId)
          .update({
        "lastMessage": messageController.text,
        "sendBy": currentUser.id,
        "time": DateTime.now().millisecondsSinceEpoch,
        "seenBy${widget.otherUser.id}":false,
      });
      messageController.clear();
      if (reply) {
        setState(() {
          reply = false;
          replyText = "";
          isText = true;
          replyName = "";
        });
      }
      // print("Length is ${itemPositionsListener.itemPositions.value.last.index}");
      // maxIndex.then((value) =>print("Max index is $value"));
      if (itemScrollCrollController.isAttached) {
        itemScrollCrollController.scrollTo(
            index: 0,
            // itemPositionsListener.itemPositions.value.last.index,
            duration: Duration(milliseconds: 300));
      }
      // if (_controller != null) {
      //   _controller.animateTo(0.0,
      //       duration: Duration(milliseconds: 500), curve: Curves.easeOut);
      // }
    }
  }

  sendMedia(FileType type) async {
    List<PlatformFile> result =
        await openFileExplorer(multiPick: false, pickingType: type);
    if (result != null) {
      String mimeStr = lookupMimeType(result[0].path);
      var fileType = mimeStr.split('/')[0];
      if (fileType == 'image') {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageUpload(
                      filePath: result[0].path,
                      isChat: true,
                      chatRoomId: widget.chatRoomId,
                      gCurrentUser: currentUser,
                    )));
      } else {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoUpload(
                      filePath: result[0].path,
                      isChat: true,
                      chatRoomId: widget.chatRoomId,
                    ))).then((value) {
          print("Returned to chat screen");
        });
      }
    } else {
      print("Send Cancel");
    }
    Navigator.of(context).pop();
  }

  // getOtherUserInfo() async {
  //   DocumentSnapshot documentSnapshot =
  //       await usersReference.doc(widget.otherUser.id).get();
  //   setState(() {
  //     otherUser = User.fromDocument(documentSnapshot);
  //   });
  // }

  // getConversationMessages() async {
  //
  //
  //   FirebaseFirestore.instance
  //       .collection("chatRoom")
  //       .doc(widget.chatRoomId)
  //       .collection("delete").doc(currentUser.id).get().then((value) {
  //         if(value.exists){
  //           print("It exists");
  //
  //         }else{
  //           print("It doesnot exists");
  //           return FirebaseFirestore.instance
  //               .collection("chatRoom")
  //               .doc(widget.chatRoomId)
  //               .collection("chats")
  //               .orderBy("time", descending: true)
  //               .snapshots();
  //         }
  //   });
  //   return await FirebaseFirestore.instance
  //       .collection("chatRoom")
  //       .doc(widget.chatRoomId)
  //       .collection("chats")
  //       .orderBy("time", descending: true)
  //       .snapshots();
  // }

  Widget replyContainer() {
    return reply
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800].withOpacity(0.3),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              constraints: BoxConstraints(
                maxHeight: 100,
                minHeight: 55,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            "Reply",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              reply = false;
                              replyText = "";
                              replyType = "text";
                              replyName = "";
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Container(
                    // margin: EdgeInsets.symmetric(horizontal: 5),
                    constraints: BoxConstraints.expand(height: 48),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,top: 5,bottom: 5),
                          child: Text(
                            replyType == "text" ? replyText : replyType,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        replyType != "text"
                            ? Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 62,
                              height: 45,
                              child: Image(
                            image: NetworkImage(replyText),fit: BoxFit.cover,)
                          ),
                        )
                            : Container(),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  menuItemSelected(int value) {
    if (value == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(
                    userProfileId: widget.otherUser.id,
                    allowAutomaticLeadingBack: true,
                  )));
    } else if (value == 2) {
      //TODO Move To Map
    } else if (value == 3) {
      //TODO Add block user
    } else if (value == 4) {
      //TODO Add Report user
    }
  }

  // onDismiss(){
  //   // FocusScopeNode currentFocus = FocusScope.of(context);
  //   // if(!currentFocus.hasPrimaryFocus){
  //   //   currentFocus.unfocus();
  //   //   dispose();
  //   //
  //   // }
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          // backgroundColor: Colors.grey[900],
          elevation: 3,
          //For going back button
          leading: IconButton(
            icon: Icon(Icons.keyboard_backspace),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: InkWell(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0.0, right: 10.0),
                  //DP
                  child: CircleAvatar(
                    backgroundImage:
                       CachedNetworkImageProvider(
                                widget.otherUser.humanUrl,
                              )
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.otherUser.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      StreamBuilder(
                        stream: lastSeenStream(),
                          builder: (context,snapshot){
                          if(snapshot.hasData){
                            return Text(
                              snapshot.data.get("isOnline")
                                  ? "Online"
                                  : getLastSeen(snapshot.data.get("lastOnline")),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 11),
                            );
                          }else{
                            return Text(
                              widget.otherUser.isOnline
                                  ? "Online"
                                  : getLastSeen(widget.otherUser.lastOnline),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 11),
                            );
                          }
                      })
                    ],
                  ),
                ),
              ],
            ),
            //Send user to the profile page when clicked on the user image as well as appbar
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          userProfileId: widget.otherUser.id,
                          allowAutomaticLeadingBack: true,
                        ))),
          ),
          actions: [
            PopupMenuButton(
              color: Colors.grey.shade900,
              offset: Offset(-30, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              itemBuilder: (context) => <PopupMenuEntry<Object>>[
                PopupMenuItem(
                  value: 1,
                  child: Text(
                    "View Profile",
                  ),
                ),
                PopupMenuDivider(
                  height: 1,
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text(
                    "View On Map",
                  ),
                ),
                PopupMenuDivider(
                  height: 1,
                ),
                // PopupMenuItem(
                //   value: 3,
                //   child: Text(
                //     "Clear Chat",
                //   ),
                // ),
                // PopupMenuDivider(
                //   height: 1,
                // ),
                PopupMenuItem(
                  value: 3,
                  child: Text(
                    "Block",
                  ),
                ),
                PopupMenuDivider(
                  height: 1,
                ),
                PopupMenuItem(
                  value: 4,
                  child: Text(
                    "Report",
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert),
              elevation: 4,
              onSelected: (value) {
                print("Value seltected is  : $value");
                menuItemSelected(value);
              },
            ),
            // IconButton(
            //   icon: Icon(
            //     Icons.more_horiz,
            //   ),
            //   onPressed: (){},
            // ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          // color: Theme.of(context).hoverColor,
          child: !isLoading
              ? Column(
                  children: [
                    Flexible(
                        child: chatMessageList(ifDeleted["isDeleted"]
                            ? getMessagesWithDelete()
                            : getMessages())),
                    replyContainer(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: BottomAppBar(
                        elevation: 10,
                        color:Theme.of(context).hoverColor,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 100,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  // sendMedia();
                                  showModalBottomSheet(
                                      elevation: 10,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor: Colors.grey[900],
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          constraints: BoxConstraints(
                                            maxHeight: 250,
                                            // minHeight: 100
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(7),
                                            child: GridView.count(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                crossAxisCount: 3,
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight: 125,
                                                        minHeight: 100,
                                                        maxWidth: 125,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.attach_file,
                                                            color: Colors.white,
                                                            size: 35,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Text(
                                                                "All",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () => sendMedia(
                                                        FileType.media),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight: 125,
                                                        minHeight: 100,
                                                        maxWidth: 125,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .photo_outlined,
                                                            color: Colors.white,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Text(
                                                                "Photos",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () => sendMedia(
                                                        FileType.image),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight: 125,
                                                        minHeight: 100,
                                                        maxWidth: 125,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .video_call_outlined,
                                                            color: Colors.white,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Text(
                                                                "Videos",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () => sendMedia(
                                                        FileType.video),
                                                  ),
                                                ]),
                                          ),
                                        );
                                      });
                                },
                              ),
                              Flexible(
                                // child:
                                // ExtendedTextField(
                                //   controller: messageController,
                                //
                                //   decoration: InputDecoration(
                                //           contentPadding: EdgeInsets.all(10.0),
                                //           border: InputBorder.none,
                                //           enabledBorder: InputBorder.none,
                                //           hintText: "Write your message....",
                                //           hintStyle: TextStyle(
                                //             fontSize: 15.0,
                                //             color: Theme.of(context)
                                //                 .textTheme
                                //                 .headline6
                                //                 .color,
                                //           ),
                                //         ),
                                //
                                // ),
                                child: TextField(
                                  controller: messageController,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10.0),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: "Write your message....",
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .color,
                                    ),
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  sendMessage();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                  ),
                ),
        ),
      ),
    );
  }

  Stream <DocumentSnapshot>lastSeenStream(){
    return usersReference.doc(widget.otherUser.id).snapshots();
  }

  getLastSeen(int time) {
    DateTime lastSeen =
        DateTime.fromMillisecondsSinceEpoch(time);
    DateTime currentDateTime = DateTime.now();
    Duration differenceDuration = currentDateTime.difference(lastSeen);
    String durationString = differenceDuration.inSeconds > 59
        ? differenceDuration.inMinutes > 59
            ? differenceDuration.inHours > 23
                ? '${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : 'days'}'
                : '${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? 'hour' : 'hours'}'
            : '${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? 'minute' : 'minutes'}'
        : 'few moments';

    return '$durationString ago';
  }

  getLastMessage() async {
    if (widget.profile) {
      DocumentSnapshot dox = await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(widget.chatRoomId)
          .get();
      String message = dox.get("lastMessage");
      if (message == null) {
        //print("DELETINGGGGGG");
        FirebaseFirestore.instance
            .collection("chatRoom")
            .doc(widget.chatRoomId)
            .delete();
      }
    }
  }

  @override
  void dispose() {
    getLastMessage();
    // chatMessageStream = null;
    // itemPositionsListener.itemPositions.removeListener(() {});
    updateSeen(true);
    print("In dispose");
    currentPage = null;
    // PhoneDatabase.saveCurrentPage(null);
    // _controller.dispose();
    super.dispose();
  }
}
