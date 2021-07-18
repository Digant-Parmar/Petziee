// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/pages/chat/chat_bubble.dart';
import 'package:flutter/material.dart';

import 'UpdateCurrentUser.dart';


class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final String timestamp;
  final int totalViews;
  final String username;
  final String description;
  final String location;
  final String url;
  final String thumbUrl;
  final bool isPhoto;

  Post({
    this.username,
    this.url,
    this.timestamp,
    this.location,
    this.description,
    this.postId,
    this.ownerId,
    this.totalViews,
    this.thumbUrl,
    this.isPhoto,
});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot.get('postId'),
      ownerId: documentSnapshot.get('ownerId'),
      timestamp: documentSnapshot.get('timestamp').toString(),
      totalViews: documentSnapshot.get('totalViews'),
      username: documentSnapshot.get('username'),
      description: documentSnapshot.get('description'),
      location: documentSnapshot.get('location'),
      url: documentSnapshot.get('url'),
      thumbUrl: documentSnapshot.get('thumbUrl'),
      isPhoto: documentSnapshot.get('isPhoto'),
    );
  }




  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    timestamp: this.timestamp,
    totalViews: this.totalViews,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    thumbUrl: this.thumbUrl,
  );
}

class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  final String timestamp;
  final int totalViews;
  final String username;
  final String description;
  final String location;
  final String url;
  final String thumbUrl;
  bool isViewed;
  bool showBright= false;
  final String currentOnlineUserId = currentUser.id;

  _PostState({
    this.username,
    this.url,
    this.thumbUrl,
    this.timestamp,
    this.location,
    this.description,
    this.postId,
    this.ownerId,
    this.totalViews,
});


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostPicture(),
        ],
      ),
    );
  }

  createPostPicture(){
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(thumbUrl),
      ],
    );
  }
}
