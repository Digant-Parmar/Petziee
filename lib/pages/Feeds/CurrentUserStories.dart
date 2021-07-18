// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petziee/Notification/HttpsNotification.dart';
import 'package:petziee/models/StoryModel.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/CustomDialogWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:video_player/video_player.dart';

import '../HomePage.dart';
import 'LikedListTile.dart';
import 'helper.dart';

class CurrentUserStories extends StatefulWidget {
  // final QuerySnapshot currentUserStories;
  final User owner;
  final void Function(int) onAddButtonTapped;
  final String postId;
  CurrentUserStories({
    // @required this.currentUserStories ,
    @required this.owner,
    this.postId,
    this.onAddButtonTapped
  });

  @override
  _CurrentUserStoriesState createState() => _CurrentUserStoriesState(
    onAddButtonTapped: onAddButtonTapped,
  );
}

class _CurrentUserStoriesState extends State<CurrentUserStories>with SingleTickerProviderStateMixin
{

  final void Function(int) onAddButtonTapped;

  _CurrentUserStoriesState({this.onAddButtonTapped});



  // currentUserAllPost;
  PageController _pageController;
  AnimationController _animationController;
  VideoPlayerController _videoPlayerController;
  bool isVideoEnable;
  int _currentIndex = 0;
  List<Story>currentUserStoriesList=[];
  bool loading;
  bool loading2;
  List<bool>isLikedList=[];
  List<int>totalLikeList =[];




  getIsLiked(String postId)async{
      try{
        await postReference.doc(widget.owner.id).collection("userPosts").doc(postId).collection("views").doc(currentUser.id).get().then((value){
        if(value.exists){
          print("If value exists true");
          isLikedList.add(value.get("isLiked"));
        }else{
          print("If value exists false");
          isLikedList.add(false);
        }
      });
      }catch(e){
        print("If value exists false with error");
        isLikedList.add(false);
      }
      if(!mounted)return;
      setState(() {
        loading2 = false;
      });
    }


  addTotalLiked(int totalLike){
    totalLikeList.add(totalLike);
  }

  makeTheList(QuerySnapshot qs,{bool isRequired = false, DocumentSnapshot dox})async{
     List<Story>temp = qs.docs.map((e) => Story.fromDocument(e)).toList();
    //     .forEach((element) {
    //   Story tempStory = Story.fromDocument(element);
    //   temp.add(tempStory);
    // });
     if(isRequired){
       temp.add(Story.fromDocument(dox));
     }

     temp.forEach((element)async {
       await getIsLiked(element.postId);
       await addTotalLiked(element.totalLikes);
       // if(tempBool== null){
       //   isLikedList.add(false);
       // }else{
       //   isLikedList.add(tempBool);
       // }
       // print("Element is $tempBool");
     });
     // currentUserStoriesList = temp;
     if(mounted){
       currentUserStoriesList.addAll(temp);
       if(widget.postId!=null){
         currentUserStoriesList.forEach((element){
           if(element.postId==widget.postId){
             currentUserStoriesList.remove(element);
             currentUserStoriesList.insert(0, element);
           }
         });
       }
    setState(() {
      // print("IsLikedList first element ${isLikedList.first}");
      loading = false;
    });}

    print("Currentuserlist length is ${currentUserStoriesList.length}");
    // print("isLikedLol is ${currentUserStoriesList[1].isLiked}");
  }

  getCurrentUserInfo()async{
      DateTime ts= DateTime.now();
      print("owner id is ${widget.owner.id}");
      QuerySnapshot qs =await postReference.doc(widget.owner.id)
          .collection("userPosts")
          .where("timestamp",isGreaterThanOrEqualTo: DateTime(ts.year, ts.month, ts.day-2,ts.hour,ts.minute, ts.second)).orderBy("timestamp",descending: true)
          .get();



      if(qs.docs.isEmpty){
        QuerySnapshot dox=  await postReference.doc(widget.owner.id)
            .collection("userPosts")
            .where("postId",isEqualTo: widget.postId)
            .get();

        print("dox element is ${dox.docs.first.id}");
        qs = dox;
        await makeTheList(qs);
      }else{
        bool isRequired = true;
         qs.docs.forEach((element) {
          if(element.id == widget.postId){
            isRequired = false;
          }
        });
        if(isRequired){
          QuerySnapshot dox=  await postReference.doc(widget.owner.id)
              .collection("userPosts")
              .where("postId",isEqualTo: widget.postId)
              .get();

          print("dox element is ${dox.docs.first.id}");
          await makeTheList(qs,isRequired: true, dox: dox.docs.first);

        }else{
          await makeTheList(qs);
        }

      }
    _pageController = PageController();

    _animationController = AnimationController(vsync: this);



    _loadStory(story: currentUserStoriesList.first, animateToPage: false);

    _animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        _animationController.stop();
        _animationController.reset();
        setState(() {
          if(_currentIndex + 1 < currentUserStoriesList.length){
            _currentIndex+=1;
            _loadStory(story: currentUserStoriesList[_currentIndex]);
          }else{
            _currentIndex = 0;
            _loadStory(story: currentUserStoriesList[_currentIndex]);
          }
        });
      }
    });
    // widget.currentUserStories.docs.forEach((element) {
    //   Story tempStory = Story.fromDocument(element);
    //   temp.add(tempStory);
    // });
    // setState(() {
    //   currentUserStoriesList = temp;
    // });
    //
    // _loadStory(story: currentUserStoriesList.first, animateToPage: false);
    //
    // _animationController.addStatusListener((status) {
    //   if(status == AnimationStatus.completed){
    //     _animationController.stop();
    //     _animationController.reset();
    //     setState(() {
    //       if(_currentIndex + 1 < currentUserStoriesList.length){
    //         _currentIndex+=1;
    //         _loadStory(story: currentUserStoriesList[_currentIndex]);
    //       }else{
    //         _currentIndex = 0;
    //         _loadStory(story: currentUserStoriesList[_currentIndex]);
    //       }
    //     });
    //   }
    // });
  }

  @override
  void initState() {
    loading = true;
    loading2=true;
    isVideoEnable = false;
    getCurrentUserInfo();
    super.initState();
  }

  Future<bool>onWillPop()async{
    dispose();
    return true;
  }

  addView(int i)async{

    print("inside of addView");
   try{
     await postReference.doc(widget.owner.id).collection("userPosts").doc(currentUserStoriesList[i].postId).collection("views").doc(currentUser.id).get().then((value){
     if(!value.exists) {
       print("inside of addView if statement");
     postReference.doc(widget.owner.id).collection("userPosts").doc(
         currentUserStoriesList[i].postId).update({
       "totalViews": currentUserStoriesList[i].totalViews + 1,
     });
     timelineReference.doc("today").collection("posts").doc(currentUserStoriesList[i].postId).update(
         {
           "totalViews": currentUserStoriesList[i].totalViews +1 ,
         });
     postReference.doc(widget.owner.id).collection("userPosts").doc(
         currentUserStoriesList[i].postId).collection("views").doc(
         currentUser.id).set({
       "isLiked": false,
     });
   }
  });
   }catch(e){
    print("inside of addView if statement error");
    postReference.doc(widget.owner.id).collection("userPosts").doc(
    currentUserStoriesList[i].postId).update({
    "totalViews": currentUserStoriesList[i].totalViews + 1,
    });
    postReference.doc(widget.owner.id).collection("userPosts").doc(
    currentUserStoriesList[i].postId).collection("views").doc(
    currentUser.id).set({"isLiked":false});
    }

  }

  @override
  Widget build(BuildContext context) {
    Story story;

    if (!loading) {
      story = currentUserStoriesList[_currentIndex];
    }

    return !loading && !loading2? Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) => _onTapUp(details, story),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: currentUserStoriesList.length,
              itemBuilder: (context, i) {
                addView(i);
                final Story story = currentUserStoriesList[i];
                switch (story.isPhoto) {
                  case true:
                    return CachedNetworkImage(
                      imageUrl: story.url,
                      fit: BoxFit.contain,
                    );
                  case false:
                    if (_videoPlayerController != null &&
                        _videoPlayerController.value.isInitialized) {
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoPlayerController.value.size.width,
                          height: _videoPlayerController.value.size.height,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      );
                    }
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: [
                  Row(
                    children: currentUserStoriesList
                        .asMap()
                        .map((key, value) {
                      return MapEntry(key,
                        AnimationBar(
                          animationController: _animationController,
                          position: key,
                          currentIndex: _currentIndex,
                        ),
                      );
                    })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 10.0,
                    ),
                    child: UserBar(owner: widget.owner,),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0, ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: ()=>onLikePressed(
                              isLikedList[_currentIndex], _currentIndex),
                            child: isLikedList[_currentIndex]
                                ? Icon(
                              Icons.favorite_rounded, color: Colors.red.shade700, size: 35,
                            )
                                : Icon(
                              Icons.favorite_outline, color: Colors.white, size: 35,),
                        ),
                        GestureDetector(
                          onTap: (){
                            _animationController.stop(canceled: false);
                            if(isVideoEnable){
                              print("It came insdide");
                              _videoPlayerController.pause();
                            }
                            showLikedBy(_currentIndex);
                            },
                          child: Text(
                            totalLikeList[_currentIndex].toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        widget.owner.id == currentUser.id
                            ?PopupMenuButton(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(-30,0),

                          shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          ),
                          itemBuilder: (context)=><PopupMenuEntry<dynamic>>[
                            PopupMenuItem(
                              height: 40,
                              value: 1,
                              child: Text(
                                "Delete Post",
                              ),
                            ),
                            PopupMenuDivider(height: 3,),
                            PopupMenuItem(
                              value: 2,
                              child: Text(
                                "Liked by",
                              ),
                            ),
                            // PopupMenuItem(
                            //   value: 3,
                            //   child: Text(
                            //     "Clear Chat",
                            //   ),
                            // ),
                            // PopupMenuItem(
                            //   value: 4,
                            //   child: Text(
                            //     "Block",
                            //   ),
                            // ),
                            // PopupMenuItem(
                            //   value: 5,
                            //   child: Text(
                            //     "Report",
                            //   ),
                            // ),
                          ],
                          icon: Icon(Icons.more_vert),
                          elevation: 4,
                          onSelected: (value){
                            print("Value seltected is  : $value");
                            menuItemSelected(value,_currentIndex);
                          },
                        )
                            :Container()
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ) : Container();
    return Container();
  }

  menuItemSelected(int value,int x){
    switch(value){
      case 1:
        deletePost(x);
        break;
      case 2:
        showLikedBy(x);
        break;
    }
  }

  deletePost(int index)async{
    _animationController.stop();
    CustomDialogWidget().showDialog(context, title: "Delete Post", message: "This Post will be deleted from everyone", cancelButtonText: "Cancel", acceptButtonText: "Delete",
    data: {
      "index":index,
      "currentUserStoriesList":currentUserStoriesList,
      "user":widget.owner,
    },
    ).then((value){
      print("Resule is $value");
      if(value!=null && value)currentUserStoriesList.removeAt(index);
      _animationController.forward();
    });
    // print(result);
    // try{
    //   firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.refFromURL(currentUserStoriesList[index].url);
    //   await ref.delete();
    // }catch(e){
    //   print("Failed to delete the post : $e");
    // }
    // postReference.doc(currentUser.id).collection("userPosts").doc(currentUserStoriesList[index].postId).delete();
    // postReference.doc(currentUser.id).collection("userPosts").doc(currentUserStoriesList[index].postId).collection("views").get().then((value){
    //   for(DocumentSnapshot doc in value.docs){
    //     doc.reference.delete();
    //   }
    // });
    // timelineReference.doc("today").collection("posts").doc(currentUserStoriesList[index].postId).delete();
    // currentUserStoriesList.removeAt(index);
  }
  showLikedBy(int index)async{
    print("In like show");
    if(totalLikeList[index]==0){
      return ;
    }
    // List<LikedListTile> list = [];
    // // list.addAll(await );
    // print("Length is ${list.length}");
    // // print("item is ${list.first.username}");
    // showModalBottomSheet(
    //     elevation: 10,
    //     isScrollControlled: true,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //     backgroundColor: Colors.grey[900],
    //     context: context,
    //     builder: (context) {
    //       return ListView.builder(
    //           itemBuilder: (context,index){
    //             return snapshot.data.isEmpty ? Container():snapshot.data[index];
    //           },
    //           shrinkWrap: true,
    //           physics: NeverScrollableScrollPhysics(),
    //         );
    //     }).then((value) {
    //     _animationController.forward();
    //     if(isVideoEnable){
    //       print("It came insdide");
    //       _videoPlayerController.play();
    //     }
    // });
    List <String>userIds =await Helper().getLikedByUserList(postId: currentUserStoriesList[index].postId, ownerId: widget.owner.id);
      showModalBottomSheet(
          elevation: 10,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.grey[900],
          context: context,
          builder: (context) {
            return ListView.builder(
              itemCount: userIds.length,
              itemBuilder: (context,index){
                 return LikedListTile(
                   userId : userIds[index],
                 );
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            );
          }).then((value){
            _animationController.forward();
            if(isVideoEnable){
              print("It came insdide");
              _videoPlayerController.play();
            }
      });

    // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LikedBy())).then((value){
    //   _animationController.forward();
    //   if(isVideoEnable){
    //     print("It came insdide");
    //     _videoPlayerController.play();
    //   }
    // });
  }

  @override
  void dispose() {
    print("disposed is caleed");
    if(_pageController!=null)_pageController.dispose();
    if(_animationController!=null)_animationController.dispose();
    if(isVideoEnable){
      print("It came insdide");
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
    }
    isLikedList = [];
    totalLikeList = [];
    currentUserStoriesList = [];
    _currentIndex = 0;
    super.dispose();
  }


  onLikePressed(bool isLiked, int index)async{
    print("Inside onLikedPressed function");
    setState(() {
      isLikedList[index] = !isLiked;

    });

    print("isLiked is $isLiked}");
    if(!isLiked){
      if(widget.owner.id!=currentUser.id)SendHttpsNotification.sendLikeNotification(currentUserId:currentUser.id,ownerId: widget.owner.id,postId: currentUserStoriesList[index].postId, currentUserImageUrl: currentUser.humanUrl, currentUsername: currentUser.username );

      // final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      //   'onLikeNotification',);
      // dynamic resp = callable.call(<String,dynamic>{
      //   'username': currentUser.username,
      //   'ownerId': widget.ownerId,
      //   'postId':  currentUserStoriesList[index].postId,
      // });
      totalLikeList[index] = totalLikeList[index]+1;
      postReference.doc(widget.owner.id).collection("userPosts").doc(currentUserStoriesList[index].postId).update({
        "totalLikes": totalLikeList[index],
      });
      timelineReference.doc("today").collection("posts").doc(currentUserStoriesList[index].postId).update({
        "totalLikes": totalLikeList[index],
      });
    }else{
      totalLikeList[index] = totalLikeList[index]-1;
      postReference.doc(widget.owner.id).collection("userPosts").doc(currentUserStoriesList[index].postId).update({
        "totalLikes": totalLikeList[index],
      });
      timelineReference.doc("today").collection("posts").doc(currentUserStoriesList[index].postId).update({
        "totalLikes": totalLikeList[index],
      });
    }
    postReference.doc(widget.owner.id).collection("userPosts").doc(currentUserStoriesList[index].postId).collection("views").doc(currentUser.id).set({
      "isLiked": !isLiked,
    });
  }

  _onPageChange(int index){
    //TODO----Edit the changes for the videos....
    _currentIndex = index;
    _loadStory(story: currentUserStoriesList[_currentIndex],animateToPage: false);
  }
  _onTapUp(TapUpDetails details, Story story){
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;

    if(dx<screenWidth /3){
      setState(() {
        if(_currentIndex-1 >=0){
          _currentIndex -=1;
          _loadStory(story: currentUserStoriesList[_currentIndex]);
        }
      });
    }else if(dx> 2*screenWidth/3){
      setState(() {
        if(_currentIndex +1 < currentUserStoriesList.length){
          _currentIndex+=1;
          _loadStory(story: currentUserStoriesList[_currentIndex]);
        }else{
          _currentIndex = 0;
          _loadStory(story: currentUserStoriesList[_currentIndex]);
          // onAddButtonTapped(2);
        }
      });
    }else{
      if(!story.isPhoto){
        if(_videoPlayerController.value.isPlaying){
          _videoPlayerController.pause();
          _animationController.stop();
        }else{
          _videoPlayerController.play();
          _animationController.forward();
        }
      }
    }
  }

 _loadStory({Story story, bool animateToPage = true}){
    _animationController.stop();
    _animationController.reset();

    switch(story.isPhoto){
      case true:
        setState(() {
          isVideoEnable = false;
        });
        _animationController.duration = story.duration;
        _animationController.forward();
        break;
      case false:
        VideoPlayerController _old = _videoPlayerController;
        if(mounted){
          _videoPlayerController?.dispose();
        }
        // _videoPlayerController?.dispose();
        // print("inside video controller ${story.url}");
        _videoPlayerController = VideoPlayerController.network(story.url)
            ..initialize().then((_) {
              setState(() {
                if(_videoPlayerController.value.isInitialized){
                  isVideoEnable = true;
                  _animationController.duration = _videoPlayerController.value.duration;
                  _videoPlayerController.play();
                  _animationController.forward();
                }
                Future.delayed(Duration(milliseconds: 100),(){
                  _old?.dispose();
                });
              });
            });
        break;
    }


    if(animateToPage){
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }

  }

}

class AnimationBar extends StatelessWidget {
  final AnimationController animationController;
  final int position;
  final currentIndex;

  const AnimationBar({
    Key key,
    @required this.animationController,
    @required this.position,
    @required this.currentIndex,
}):super(key: key);


  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints){
            return Stack(
              children: [
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                    ?Colors.white
                      :Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                  ? AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child){
                    return _buildContainer(
                      constraints.maxWidth*animationController.value,
                      Colors.white,
                    );
                  },
                )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }
}

Container _buildContainer(double width, Color color){
  return Container(
    height: 5.0,
    width: width,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(
        color: Colors.black26,
        width: 0.8,
      ),
      borderRadius: BorderRadius.circular(3.0),
    ),
  );
}

class UserBar extends StatelessWidget {
  final User owner;
  const UserBar({
   Key key,
    @required this.owner,
}):super(key: key);



  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[300],
          backgroundImage:
          owner!=null
              ? CachedNetworkImageProvider(
            owner.humanUrl,
          )
              :Image.asset("assets/Profile/humanPaw.png"),
        ),
        const SizedBox(width: 10.0,),
        Expanded(
          child:owner!=null? Text(
            owner.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
            ),
          )
              :Text(
            "Username",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: ()=>Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}