// @dart=2.9


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';


final usersReferenceStart = FirebaseFirestore.instance.collection("users");

class OnStartScreen extends StatefulWidget {
  @override
  _OnStartScreenState createState() => _OnStartScreenState();
}

class _OnStartScreenState extends State<OnStartScreen> {
  bool isSignedIn= false;

  // @override
  // Widget build(BuildContext context) {
  //   if(!isSignedIn){
  //     return SignUp();
  //   }else{
  //     return HomePage(initPage: 2,);
  //   }
  // }
  getSignUp(){
    Navigator.of(context).pushReplacementNamed("/signUp");
  }
  getHomePage(int index){
    Navigator.of(context).pushReplacementNamed("/home");
  }
  @override
  Widget build(BuildContext context) {
    if(!isSignedIn){
      return getSignUp();
    }else{
      return getHomePage(2);
    }
  }
  @override
  void initState() {
    auth.User user =  auth.FirebaseAuth.instance.currentUser;
    controlSignIn(user);
    super.initState();

  }
  controlSignIn(auth.User user)async{
    print(user);
    if(user==null){
      print("true");
      setState(() {
        isSignedIn = false;
      });
    }else{
      setState(() {
        isSignedIn = true;
      });
    }
  }

}
class Buffer{
  bool isSignedIn;
  Future<bool>controlSignIn(auth.User user)async{
    print(user);
    if(user==null){
      print("true");
       return false;
    }else{
        return true;
    }
  }
  Future<bool> onStartScreen()async{
    bool temp;
    auth.User user =  auth.FirebaseAuth.instance.currentUser;
    temp = await controlSignIn(user);
    print("Temp value is $temp");
    return temp;
  }

}