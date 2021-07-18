// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_container/dashed_container.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/pages/Profile/ProfilePage.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:flutter/material.dart';

import 'file:///C:/Users/digan/AndroidStudioProjects/petziee/lib/pages/Feeds/StoryController.dart';

class FeedMostLikedWidget extends StatefulWidget {


  final String postId;
  final String ownerId;
  final String timestamp;
  final int totalViews;
  final String username;
  final String description;
  final String location;
  final String url;
  final bool isPhoto;
  final String thumbUrl;
  final bool isMostLiked;
  final bool isMain;

  FeedMostLikedWidget({
    this.username,
    this.url,
    this.timestamp,
    this.location,
    this.description,
    this.postId,
    this.ownerId,
    this.totalViews,
    this.isPhoto,
    this.thumbUrl,
    this.isMostLiked = false,
    this.isMain = false,
  });

  factory FeedMostLikedWidget.fromDocument(DocumentSnapshot documentSnapshot,{bool isMostLiked = false,bool isMain = false}){
    return FeedMostLikedWidget(
      postId: documentSnapshot.get('postId'),
      ownerId: documentSnapshot.get('ownerId'),
      timestamp: documentSnapshot.get('timestamp').toString(),
      totalViews: documentSnapshot.get('totalViews'),
      username: documentSnapshot.get('username'),
      description: documentSnapshot.get('description'),
      location: documentSnapshot.get('location'),
      url: documentSnapshot.get('url'),
      isPhoto: documentSnapshot.get('isPhoto'),
      isMostLiked: isMostLiked,
      isMain : isMain,
      thumbUrl: documentSnapshot.get('thumbUrl'),
    );
  }


  // int getTotalNumberOfViews(views){
  //   if(views==null){
  //     return 0;
  //   }
  //   int counter = 0;
  //   views.value.forEach((eachValue){
  //     counter = counter + 1;
  //   });
  //
  //   return counter;
  // }


  @override
  _FeedMostLikedWidgetState createState() => _FeedMostLikedWidgetState(
    postId: this.postId,
    ownerId: this.ownerId,
    timestamp: this.timestamp,
    totalViews: this.totalViews,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    thumbUrl:this.thumbUrl,
    isMain: this.isMain,
    isMostLiked: this.isMostLiked,
    // viewCount: getTotalNumberOfViews(this.views),

  );
}

class _FeedMostLikedWidgetState extends State<FeedMostLikedWidget> {


  final String postId;
  final String ownerId;
  final String timestamp;
  final String thumbUrl;
  final int  totalViews;
  final String username;
  final String description;
  final String location;
  final String url;
  final bool isMain;
  final bool isMostLiked;
  // int viewCount;
  bool isViewed;
  bool showBright= false;
  final String currentOnlineUserId = currentUser.id;
  User owner;

  _FeedMostLikedWidgetState({
    this.username,
    this.url,
    this.isMostLiked = false,
    this.thumbUrl,
    this.timestamp,
    this.location,
    this.description,
    this.postId,
    this.isMain,
    this.ownerId,
    this.totalViews,
    // this.viewCount,
  });

  getUserProfile()async{
    DocumentSnapshot docSnap = await usersReference.doc(ownerId).get();
    if(!mounted)return;
    if(docSnap.exists ){
      setState(() {
        owner = User.fromDocument(docSnap);
        print("Owner details in most${owner.humanUrl}steps");
      });
    }

    //TODO WHat if the docSnap does not extis return and send another post implememnt that
  }



  @override
  void initState() {
    getUserProfile();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DashedContainer(
      dashColor:widget.isMostLiked?Colors.transparent :isMain?Colors.yellowAccent:Colors.transparent,
      borderRadius: 15.0,
      dashedLength: 0.8,
      blankLength: 4.0,
      strokeWidth: 1,
      child: GestureDetector(
        onTap: ()=>sendToStoryView(),
        child: Container(
          margin: EdgeInsets.all(4),
          height: 200,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: const Offset(3.0, 3.0),
                color: Theme.of(context).shadowColor,
                blurRadius: 2.0,
                spreadRadius: 0.1,
              ),
            ],
              image: DecorationImage(
                image:thumbUrl!=""? CachedNetworkImageProvider(thumbUrl):Image.asset("assets/pets/dog.png"),
                fit: BoxFit.cover,
              ),
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          // child: ClipRRect(
          //   borderRadius: BorderRadius.all(Radius.circular(12)),
          //   child: Image.asset(imageList[index],fit: BoxFit.cover,),
          // ),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(

                begin: Alignment.bottomRight,
                colors:[
                  Colors.black.withOpacity(.9),
                  Colors.grey[900].withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               isMain? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(totalViews.toString(), style: TextStyle(color: Colors.redAccent),overflow: TextOverflow.ellipsis,),
                    Icon(Icons.remove_red_eye, color: Colors.redAccent,size: 18.0,)
                  ],
                ):Container(),
                GestureDetector(
                  onTap: ()=>sendToProfilePage(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                          image: DecorationImage(
                            image:owner != null && (owner.humanUrl!="" && owner.humanUrl!=" ")? NetworkImage(owner.humanUrl):AssetImage("assets/puppy.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      owner!=null?Text(owner.username, style: TextStyle(color: Colors.white),overflow: TextOverflow.ellipsis,): Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  sendToStoryView(){
    print("Sending to the story view");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>StoryController(
      postId: postId,
      ownerId: ownerId,
      timestamp: timestamp,
      totalViews: totalViews,
      username: username,
      description: description,
      location: location,
      url: url,
    )));
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>CurrentUserStories( ownerId: ownerId)));
  }


  sendToProfilePage(){
    print("Pressed");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: ownerId,allowAutomaticLeadingBack: true,)));
  }
}
