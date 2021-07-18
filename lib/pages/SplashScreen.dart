// @dart=2.9
import 'package:petziee/pages/HomePage.dart';
import 'file:///C:/Users/digan/AndroidStudioProjects/petziee/lib/SignIn/signupScreen.dart';
import 'package:flutter/material.dart';

import 'OnStartScreen.dart';

class SplashScree extends StatefulWidget {
  @override
  _SplashScreeState createState() => _SplashScreeState();
}

class _SplashScreeState extends State<SplashScree> {
  bool isSignedIn;
  bool isLoading;
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    Buffer().onStartScreen().then((value){
      print("Returned value is $value");
      setState(() {
        isSignedIn = value;
        isLoading = false;
        print("Reinitiated value is $isSignedIn");
      });
    });

    print("isSignedzIn in the end is $isSignedIn");
    print("ISSIGNED VALUE SIS $isSignedIn");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print("IsLOdaing in build $isLoading");
    print("IsSignedIn in build $isSignedIn");
    print("Inside of Splash Screen");

    if(isLoading){
      return Container(
        color: Colors.red,
        width: 400,
        height: 400,
      );
    }else{
      getChecked();
      return Container();
    }

    return isLoading?Container(
      color: Colors.red,
      width: 400,
      height: 400,
    )
        :isSignedIn
        ?getHomePage(context)
        :getSignUp(context);
  }

  getChecked(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(isSignedIn){
        getHomePage(context);
      }else{
        getSignUp(context);
      }
    });
  }
  getSignUp(BuildContext context){
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUp()));
  }
  getHomePage(BuildContext context){
    new Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(initPage: 2,)));
  }
}
