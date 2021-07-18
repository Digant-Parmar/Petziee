// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/widgets/CustomMapIconWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}

class CustomDialogWidget {
  showDialog(BuildContext context,
      {@required String title,
      @required String message,
      @required String cancelButtonText,
      @required String acceptButtonText,
      Map<String, dynamic> data}) async {
    var result = await showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "Barrier",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        context: context,
        pageBuilder: (_, __, ___) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        left: Constants.padding,
                        top: Constants.avatarRadius + Constants.padding,
                        right: Constants.padding,
                        bottom: Constants.padding),
                    margin: EdgeInsets.only(top: Constants.avatarRadius),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(Constants.padding),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 10),
                              blurRadius: 10),
                        ]),
                    child: Material(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            message,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(
                                      cancelButtonText,
                                      style: TextStyle(fontSize: 18),
                                    )),
                              ),
                              Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                    onPressed: () {
                                      switch (title) {
                                        case "Message Unsend":
                                          unsendMessage(data, context);
                                          break;
                                        case "Delete Post":
                                          deletePost(data, context);
                                          // return deletePost(data,context);
                                          break;
                                        case "Delete Chat":
                                          deleteChat(data, context);
                                          break;
                                      }
                                    },
                                    child: Text(acceptButtonText,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.redAccent))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: Constants.padding,
                    right: Constants.padding,
                    child: getImage(data, title),
                  ),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (_, anim1, __, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        });
    return result;
  }

  getImage(Map<String, dynamic> data, String title) {
    switch (title) {
      case "Message Unsend":
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: Constants.avatarRadius,
          child: ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(Constants.avatarRadius)),
            child: Image.asset("assets/pets/dog.png"),
          ),
        );
        break;
      case "Delete Post":
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 45.0,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(45)),
            child: Image.asset("assets/pets/dog.png"),
            // Image.network(data["user"].humanUrl),
          ),
        );
        break;
      case "Delete Chat":
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: Constants.avatarRadius,
          child: ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(Constants.avatarRadius)),
            child: Image.asset("assets/cm0.jpeg"),
          ),
        );
        break;
    }
  }

  deleteChat(Map<String, dynamic> data, BuildContext context) async {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(data["chatRoomId"])
        .collection("deleted")
        .doc(currentUser.id)
        .set({
      "timestamp": data["time"],
    });
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(data["chatRoomId"])
        .update({
      "${currentUser.id}": false,
    });
    Navigator.of(context).pop();
  }

  unsendMessage(Map<String, dynamic> data, BuildContext context) async {
    // print("ChatId is ${data["chatId"]}");

    if (data["type"] != "text") {
      try {
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .refFromURL(data["message"]);
        await ref.delete();
      } catch (e) {
        print("Failed to delete the post : $e");
      }
    }
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(data["chatRoomId"])
        .collection("chats")
        .doc(data["chatId"])
        .delete();

    QuerySnapshot qs= await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(data["chatRoomId"])
        .collection("chats").orderBy("time",descending: true).limit(1).get();
    Map update = {
      "lastMessage": qs.docs.first.get("message"),
      "type":qs.docs.first.get("type"),
      "time":qs.docs.first.get("time"),
      "sendBy":qs.docs.first.get("userId"),
    };
    if(update["type"]!="text"){
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(data["chatRoomId"])
          .update({
        "lastMessage":update["type"],
        "time":update["time"],
        "sendBy":update["sendBy"],
      });
    }else{
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(data["chatRoomId"])
          .update({
        "lastMessage":update["lastMessage"],
        "time":update["time"],
        "sendBy":update["sendBy"],
      });
    }
    Navigator.of(context).pop();
  }

  deletePost(Map<String, dynamic> data, BuildContext context) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .refFromURL(data["currentUserStoriesList"][data["index"]].url);
      await ref.delete();
    } catch (e) {
      print("Failed to delete the post : $e");
    }
    postReference
        .doc(currentUser.id)
        .collection("userPosts")
        .doc(data["currentUserStoriesList"][data["index"]].postId)
        .delete();
    postReference
        .doc(currentUser.id)
        .collection("userPosts")
        .doc(data["currentUserStoriesList"][data["index"]].postId)
        .collection("views")
        .get()
        .then((value) {
      for (DocumentSnapshot doc in value.docs) {
        doc.reference.delete();
      }
    });
    timelineReference
        .doc("today")
        .collection("posts")
        .doc(data["currentUserStoriesList"][data["index"]].postId)
        .delete();
    Navigator.of(context).pop(true);
    //   return"This is the result";
  }
}

class MapIconsDialog {
  showDialog(BuildContext context,
      {@required String currentIconId,

      }) async {

    var result = await showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "Barrier",
        // barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        context: context,
        pageBuilder: (_, __, ___) {
          return CustomMapIconList(iconId: currentIconId);
        },
        transitionBuilder: (_, anim1, __, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        });
    return result;
  }
}
