// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/models/VideoInfo.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

class FirebaseProvider {
  static saveVideo(VideoInfo video) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(currentUser.id)
        .collection("userPosts")
        .doc(video.videoName)
        .set({
      'thumbUrl': video.thumbUrl,
      'aspectRatio': video.aspectRatio,
      'timestamp': video.uploadedAt,
      // 'postId': video.videoName,
      'finishedProcessing': true,
      'duration':video.duration,
    }, SetOptions(merge: true,));
    await FirebaseFirestore.instance
        .collection('timeline')
        .doc("today")
        .collection("posts")
        .doc(video.videoName)
        .set({
      'thumbUrl': video.thumbUrl,
      'aspectRatio': video.aspectRatio,
      'timestamp': video.uploadedAt,
      'duration':video.duration,
      // 'postId': video.videoName,
      'finishedProcessing': true,
    }, SetOptions(merge: true,));
  }

  static saveDownloadUrl(String videoName, String downloadUrl, String ownerId) async {
    await FirebaseFirestore.instance.collection('posts')
        .doc(ownerId)
        .collection("userPosts")
        .doc(videoName).set({
      'url': downloadUrl,
      'uploadComplete': true,

    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection('timeline')
        .doc("today")
        .collection("posts")
        .doc(videoName)
        .set({
      'url': downloadUrl,
      'uploadComplete': true,

    }, SetOptions(merge: true,));
  }

  static createNewVideo(String videoName, String rawPath, String ownerId) async {
    await FirebaseFirestore.instance.collection('posts')
        .doc(ownerId)
        .collection("userPosts")
        .doc(videoName).set({
      'uploadComplete': false,
      'finishedProcessing': false,
      'postId': videoName,
      'rawPath': rawPath,
      'description': "",
      'isPhoto': false,
      'location': "",
      'ownerId': ownerId,
      'username': "",
      "totalViews": 0 ,
      "totalLikes":0,
      "url":null,
    });
  }

  static deleteVideo(String videoName,String ownerId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(ownerId)
        .collection("userPosts")
        .doc(videoName)
        .delete();
  }
  //
  // static setUploadComplete(String videoName)async{
  //   await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
  //     'uploadComplete': true,
  //   });
  // }
  //
  // static listenToVideos(callback, ownerId) async {
  //    FirebaseFirestore.instance.collection('posts').doc(ownerId).collection("userPosts").where("finishedProcessing",isEqualTo: false).snapshots().listen((qs) {
  //     final videos = mapQueryToVideoInfo(qs);
  //     callback(videos);
  //   });
  // }
  //
  // static mapQueryToVideoInfo(QuerySnapshot qs) {
  //   return qs.docs.map((DocumentSnapshot ds) {
  //     final data = ds;
  //     return VideoInfo(
  //       videoName: data['postId'],
  //       finishedProcessing: data['finishedProcessing'] == true,
  //       uploadComplete: data['uploadComplete'] == true,
  //       url: data['url'],
  //       rawPath: data['rawPath'],
  //       ownerId: data['ownerId'],
  //       isPhoto: data['isPhoto'],
  //     );
  //   }).toList();
  // }
}