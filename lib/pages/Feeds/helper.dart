
// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/pages/Feeds/LikedListTile.dart';

import '../HomePage.dart';


class Helper{
  Future<List<String>>getLikedByUserList({String postId,String ownerId})async{
    List<String>userId= [];
    List<LikedListTile> users=[];
    QuerySnapshot _snapshot = await postReference.doc(ownerId).collection("userPosts").doc(postId).collection("views").where("isLiked",isEqualTo: true).get();
      _snapshot.docs.forEach((element)async {
        userId.add(element.id);
     });
    // print("Elemnts are ${users.first.username}");
    return userId;
  }
}