// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import '../HomePage.dart';
import 'CurrentUserStories.dart';

class StoryController extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String timestamp;
  final int totalViews;
  final String username;
  final String description;
  final String location;
  final String url;

  StoryController({
    this.username,
    this.url,
    this.timestamp,
    this.location,
    this.description,
    this.postId,
    this.ownerId,
    this.totalViews,
  });

  @override
  _StoryControllerState createState() => _StoryControllerState(
    postId: this.postId,
    ownerId: this.ownerId,
    timestamp: this.timestamp,
    totalViews: this.totalViews,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
  );
}



class _StoryControllerState extends State<StoryController> {


  final String postId;
  final String ownerId;
  final String timestamp;
  final int totalViews;
  final String username;
  final String description;
  final String location;
  final String url;
  bool isViewed;
  bool showBright= false;

  _StoryControllerState({
    this.username,
    this.url,
    this.timestamp,
    this.location,
    this.description,
    this.postId,
    this.ownerId,
    this.totalViews,
  });

  PageController pageController;

  QuerySnapshot currentUserAllPost;
  bool loading;
  bool isReturned;
  static String initialOwnerId;
  List<User>_usersList=[];
  int _lowerCount = 0;
  int _upperCount = 0;
  //
  // getCurrentUserAllPost(String id)async{
  //   DateTime ts= DateTime.now();
  //   QuerySnapshot qs =await postReference.doc(id).collection("userPosts").where("timestamp",isGreaterThanOrEqualTo: DateTime(ts.year, ts.month, ts.day,ts.hour,ts.minute, ts.second)).get();
  //   // setState(() {
  //   //   print("$qs is query snapshot");
  //   //   currentUserAllPost = qs;
  //   //   loading = false;
  //   // });
  // }

  List<CurrentUserStories>_pages = [];

  @override
  void initState() {
    loading= true;
    isReturned= false;
    // getCurrentUserAllPost(ownerId);
    setState(() {
      initialOwnerId = ownerId;
    });
    print("initial user is $initialOwnerId");
    getOwner().then((user){_pages.insert(0, CurrentUserStories(owner: user,postId: postId,));
    setState(() {});
    getListOfAllUsers();
    pageController = PageController(initialPage: 0);
    });
    super.initState();
  }

  Future<User>getOwner()async{
    DocumentSnapshot doc =await usersReference.doc(widget.ownerId).get();
    return User.fromDocument(doc);
  }

  getListOfAllUsers()async{
    //TODo remove the stories viewed by the current user
    QuerySnapshot qs =await usersReference.where("id",isNotEqualTo: currentUser.id).get();
    List<User>_temp= qs.docs.map((e) =>User.fromDocument(e)).toList();
    print("User list length  = ${_temp.length}");
    setState(() {
      _usersList = _temp;
    });

    print("LOLLLLLLLLLLLLLLLLLLLLLLLL");
    //     .forEach((element) {
    //   Story tempStory = Story.fromDocument(element);
    //   temp.add(tempStory);
    // });
    makeCurrentUserStories(0);
  }

  @override
  void dispose() {
    _pages = null;
    _usersList = null;
    pageController.dispose();
    _upperCount = 0;
    super.dispose();
  }



  makeCurrentUserStories(int pageIndex)async{
    print("LOLLLLLLLLLLLLLLLLLLLLLLLL");

    if(pageIndex == _pages.length - 2){

      print("Last second Page $pageIndex");
      _upperCount = _pages.length-1;
      print("Uppercount is $_upperCount");

      if(_upperCount < _usersList.length) {
        _pages.insert(_upperCount,
            CurrentUserStories(owner: _usersList[_upperCount]));
        setState(() {print("Setstate triggered");});

      }

    }else if(pageIndex == 0 && _pages.length == 1){
      print("Page index is hellooo  $pageIndex");
      _upperCount = _pages.length-1;
      print("First user is ${_usersList[_upperCount].id}");
      print("_upperCount  is  $_upperCount");

      if(_upperCount < _usersList.length) {
        print("First if");
        DocumentSnapshot dox = await postReference.doc(_usersList[_upperCount].id).get();
        if(dox.exists){
          _pages.add( CurrentUserStories(owner: _usersList[_upperCount]));
        }
        setState(() {print("Setstate triggered");});

      }

      // _upperCount = _pages.length-1;

      // if(_upperCount < _usersList.length) {
      //   _pages.add(CurrentUserStories(ownerId: _usersList[_upperCount].id));
      //   setState(() {print("Set state triggered");});
      // }
    }

    print("At the end pages list length is ${_pages.length}");
  }

  void onAddButtonTapped(int index){
    pageController.animateToPage(index, duration: null, curve: null);

  }


  @override
  Widget build(BuildContext context) {
    return  PageView.builder(
        onPageChanged: (pageIndex)=>makeCurrentUserStories(pageIndex),
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: _pages.length,
        itemBuilder: (BuildContext context, int position){
            return _pages[position];

        },
      );
  }
}