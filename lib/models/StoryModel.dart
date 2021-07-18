// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';

class Story{
  final String url;
  final bool isPhoto;
  final Duration duration;
  final String postId;
  final int totalViews;
  // final bool isLiked;
  final int totalLikes;

  const Story({
    this.url,
    this.duration,
    this.isPhoto,
    this.postId,
    this.totalViews,
    // this.isLiked,
    this.totalLikes,
  });

  factory Story.fromDocument(DocumentSnapshot doc){

    return Story(
        url: doc.get("url"),
        duration: getDuration(doc.get("duration")),
        postId: doc.get('postId'),
        totalViews: doc.get("totalViews"),
        // doc.get("isPhoto")?
        // Duration(seconds: 7),
            // :Duration(seconds: 0),
        isPhoto: doc.get('isPhoto'),
        // isLiked:  getIsLiked(doc.get("postId"),doc.get("ownerId")),
        totalLikes: doc.get("totalLikes")
    );
  }
  //
  // static  getIsLiked(String postId, String ownerId){
  //   try{
  //     postReference.doc(ownerId).collection("userPosts").doc(postId).collection("views").doc(currentUser.id).get().then((value){
  //     if(value.exists){
  //       print("If value exists true");
  //       return value.get("isLiked");
  //     }else{
  //       print("If value exists false");
  //       return false;
  //     }
  //   });
  //   }catch(e){
  //     print("If value exists false with error");
  //     return false;
  //   }
  // }
  //
  static Duration getDuration(String x){
    int seconds= 0;
    int micros = 0;
    List<String> parts = x.split(".");
    seconds = int.parse(parts[parts.length-2]);
    micros = (double.parse(parts[parts.length-1])*1000000).round();
    // print("Duration is $seconds");
    return Duration(seconds: seconds, microseconds: micros);
  }


}