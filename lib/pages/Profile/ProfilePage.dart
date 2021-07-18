// @dart=2.9
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/Notification/HttpsNotification.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/pages/Profile/Paws.dart';
import 'package:petziee/pages/chat/ConversationScreen.dart';
import 'package:petziee/widgets/MapTransition.dart';
import 'package:petziee/widgets/PostTileWidget.dart';
import 'package:petziee/widgets/PostWidget.dart';
import 'package:petziee/widgets/SideMenu.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'Tails.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  final bool allowAutomaticLeadingBack;

  ProfilePage({this.userProfileId, this.allowAutomaticLeadingBack = false});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnLineUserId = currentUser.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postList = [];
  String mapButtonName = "Loading";

  // bool _initialScale = true;
  // bool _isZoomedMax = false;

  @override
  void initState() {
    print("Is allowed ${widget.allowAutomaticLeadingBack}");
    getProfilePost();
    _getMapButtonName();
    super.initState();
  }

  getProfilePost() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postReference
        .doc(widget.userProfileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .get();

    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postList = querySnapshot.docs.map((e) => Post.fromDocument(e)).toList();
    });
  }

  createProfileTopView() {
    double _size = (MediaQuery.of(context).size.width - 280) / 2;
    print("Size ${MediaQuery.of(context).size.width} and _Size is $_size");
    return FutureBuilder(
      future: usersReference.doc(widget.userProfileId).get(),
      builder: (context, dataSnapshot) {
        //print("$currentUser is the id");
        if (!dataSnapshot.hasData || dataSnapshot.hasError) {
          return Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(
                      width: _size,
                    ),
                    CircleAvatar(
                      //PET PROFILE IMAGE
                      radius: 55.0,
                      backgroundColor: Colors.black,
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    CircleAvatar(
                      //Human PROFILE IMAGE
                      radius: 55.0,
                      backgroundColor: Colors.black,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                currentUser.id != widget.userProfileId
                    ? Divider()
                    : Container(),
                currentUser.id != widget.userProfileId
                    ? Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              onPressed: sendUserToChatArea,
                              child: Container(
                                width: 130,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Center(
                                  child: Text(
                                    "Loading",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            FlatButton(
                              onPressed: () => sendToMap(),
                              // mapButtonName == "Map"?()=>sendToMap() :onMapButtonPressed,
                              child: Container(
                                width: 130,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Center(
                                  child: Text(
                                    "Loading",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        }
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  SizedBox(
                    width: _size,
                  ),
                  CircleAvatar(
                    //PET PROFILE IMAGE
                    radius: 55.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(user.petUrl),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  CircleAvatar(
                    //Human PROFILE IMAGE
                    radius: 55.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(user.humanUrl),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 14.0,
                    // color: Colors.white,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  user.profileName,
                  style: TextStyle(
                      fontSize: 14.0,
                      // color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 3.0),
                child: Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 16.0,
                    // color: Colors.white70,
                  ),
                ),
              ),
              Divider(),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    currentUser.id != widget.userProfileId
                        ? TextButton(
                            onPressed: sendUserToChatArea,
                            child: Container(
                              width: 130,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Center(
                                child: Text(
                                  "Message",
                                  style: TextStyle(
                                    fontSize: 16,
                                    // color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () => sendToPaws(),
                            child: Container(
                              width: 130,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: Theme.of(context).highlightColor),
                              ),
                              child: Center(
                                child: Text(
                                  "Paws",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).highlightColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    currentUser.id != widget.userProfileId
                        ? TextButton(
                            onPressed: () => onMapButtonPressed(),
                            // mapButtonName == "Map"?()=>sendToMap() :onMapButtonPressed,
                            child: Container(
                              width: 130,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: mapButtonName == "Map"
                                          ? Colors.white
                                          : Colors.blueAccent),
                                  color: mapButtonName == "Map"
                                      ? Colors.transparent
                                      : Colors.blueAccent),
                              child: Center(
                                child: Text(
                                  mapButtonName,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () => sendToTails(),
                            // mapButtonName == "Map"?()=>sendToMap() :onMapButtonPressed,
                            child: Container(
                              width: 130,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: Theme.of(context).highlightColor),
                              ),
                              child: Center(
                                child: Text(
                                  "Tails",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).highlightColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  sendToTails() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => TailsPage()));
  }

  sendToPaws() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PawsPage()));
  }

  sendToMap() async {
    if (currentUser.id != widget.userProfileId) {
      DocumentSnapshot documentSnapshot =
          await usersReference.doc(widget.userProfileId).get();
      if (!documentSnapshot.exists) {
        documentSnapshot = await usersReference.doc(widget.userProfileId).get();
      }
      bool otherIsOpen = User.fromDocument(documentSnapshot).isOpen;

      updateMapUser(userId: widget.userProfileId, checkOpen: otherIsOpen);
      int count = 0;

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(
                    initPage: 0,
                  )), (route) {
        return count++ == 2;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  onMapButtonPressed() async {
    if (mapButtonName == "Requested") {
      print("Here");
      tailsReference
          .doc(widget.userProfileId)
          .collection("requestedTails")
          .doc(currentUser.id)
          .delete();
      setState(() {
        mapButtonName = "Add Paw";
      });
    } else if (mapButtonName == "Add Paw") {
      SendHttpsNotification.sendAddPawNotification(
          currentUsername: currentUser.username,
          currentUserId: currentUser.id,
          currentUserImageUrl: currentUser.humanUrl,
          otherUserId: widget.userProfileId);
      tailsReference
          .doc(widget.userProfileId)
          .collection("requestedTails")
          .doc(currentUser.id)
          .set({});
      setState(() {
        mapButtonName = "Requested";
      });
    } else if (mapButtonName == "Map") {
      sendToMap();
    }
  }

  _getMapButtonName() async {
    if (currentUser.id == widget.userProfileId) {
      setState(() {
        mapButtonName = "Map";
      });
    } else {
      DocumentSnapshot snap = await tailsReference
          .doc(widget.userProfileId)
          .collection("userTails")
          .doc(currentUser.id)
          .get();
      DocumentSnapshot requested = await tailsReference
          .doc(widget.userProfileId)
          .collection("requestedTails")
          .doc(currentUser.id)
          .get();
      DocumentSnapshot blocked = await tailsReference
          .doc(widget.userProfileId)
          .collection("blockedTails")
          .doc(currentUser.id)
          .get();
      if (snap.exists) {
        setState(() {
          mapButtonName = "Map";
        });
      } else if (requested.exists) {
        setState(() {
          mapButtonName = "Requested";
        });
      } else if (blocked.exists) {
        setState(() {
          mapButtonName = "Blocked";
        });
      } else {
        setState(() {
          mapButtonName = "Add Paw";
        });
      }
    }
  }

  Future<void> _pullRefresh() async {
    setState(() {
      loading = true;
    });
    _getMapButtonName();
    QuerySnapshot newQuerySnapshot = await postReference
        .doc(widget.userProfileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .get();

    setState(() {
      loading = false;
      countPost = newQuerySnapshot.docs.length;
      postList =
          newQuerySnapshot.docs.map((e) => Post.fromDocument(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      endDrawerEnableOpenDragGesture: true,
      drawerEnableOpenDragGesture: true,
      endDrawer: SafeArea(
        child: NavDrawer(),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: widget.allowAutomaticLeadingBack
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(context);
                },
              )
            : Container(),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView(
          children: [
            createProfileTopView(),
            Divider(),
            // GestureDetector(
            //   onScaleStart: (count) {
            //     print("Scale start $count}");
            //   },
            //   onScaleUpdate: (count) {
            //     print("Scale t update $count");
            //
            //     if (count.scale > 1 && _initialScale) {
            //       setState(() {
            //         _initialScale = false;
            //         _isZoomedMax = true;
            //       });
            //       print("Scale update $count");
            //     }
            //     if (count.scale < 1 && _initialScale) {
            //       setState(() {
            //         _initialScale = false;
            //         _isZoomedMax = false;
            //       });
            //     }
            //   },
            //   onScaleEnd: (count) {
            //     print("Scale End $count");
            //     setState(() {
            //       _initialScale = true;
            //
            //     });
            //     },
            //   child:_initialScale?:Center(child: CircularProgressIndicator(),) ,
            // ),
            displayProfilePost(),
          ],
        ),
      ),
    );
  }

  _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  displayProfilePost() {
    if (loading) {
      return Center(
          child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
      ));
    } else if (postList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: Colors.grey,
                size: 100.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No Post",
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      return StaggeredGridView.countBuilder(
        crossAxisCount: 3,
        crossAxisSpacing: 3.5,
        mainAxisSpacing: 3.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: postList.length,
        itemBuilder: (context, index) {
          print("Index is $index");
          return PostTile(postList[index]);
        },
        staggeredTileBuilder: (index) {
          return new StaggeredTile.count(
              (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1);
        },
      );
    }
  }

  sendUserToChatArea() async {
    List<dynamic> chatRoomId =
        await getChatRoomId(currentUser.id, widget.userProfileId);
    print("${chatRoomId[0]}");
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(widget.userProfileId).get();
    if (!documentSnapshot.exists) {
      documentSnapshot = await usersReference.doc(widget.userProfileId).get();
    }

    User otherUser = User.fromDocument(documentSnapshot);

    if (chatRoomId[0]) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                    chatRoomId: chatRoomId[1],
                    otherUser: otherUser,
                    isVisible: false,
                    profile: false,
                  )));
    } else {
      List<String> users = [otherUser.id, currentUser.id];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomId[1],
        "lastMessage": null,
        "sendBy": currentUser.username,
        "time": DateTime.now().millisecondsSinceEpoch,
        "${currentUser.id}": true,
        "${otherUser.id}": true,
        "seenBy${currentUser.id}": true,
        "seenBy${otherUser.id}": false,
      };
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId[1])
          .set(chatRoomMap)
          .catchError((e) {
        print(e);
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                    chatRoomId: chatRoomId[1],
                    otherUser: otherUser,
                    isVisible: false,
                    profile: true,
                  )));
    }
  }

  Future<List<dynamic>> getChatRoomId(String a, String b) async {
    final _ref = FirebaseFirestore.instance.collection("chatRoom");
    print("$a is the a and $b is the b");
    if (a.substring(0, 1).codeUnitAt(0) >= b.substring(0, 1).codeUnitAt(0)) {
      DocumentSnapshot doc = await _ref.doc("$b\_$a").get();
      if (doc.exists) {
        return [true, doc.id];
      } else {
        return [false, "$b\_$a"];
      }
    } else {
      DocumentSnapshot doc = await _ref.doc("$a\_$b").get();
      if (doc.exists) {
        return [true, doc.id];
      } else {
        return [false, "$a\_$b"];
      }
    }
  }
}
