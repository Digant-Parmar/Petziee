// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/EditProfilePage.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Verification extends StatefulWidget  {
  // final void Function(int) onAddButtonTapped;
  final void Function(int) button;
  Verification(this.button);
  @override
  _VerificationState createState() => _VerificationState(button);
}

TextEditingController otpTED = new TextEditingController();


class _VerificationState extends State<Verification> with TickerProviderStateMixin ,AutomaticKeepAliveClientMixin<Verification>{



  AnimationController _animationController2;
  final void Function(int) button;
  _VerificationState(this.button);

  final _focusNode = FocusNode();

  @override
  void initState() {
    _animationController2 = AnimationController(vsync: this);
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    // FocusScope.of(context).requestFocus(FocusNode());
    _animationController2.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // print(MediaQuery.of(context).size.height);
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey.shade900,
        body: SingleChildScrollView(
          // controller: _scrollController,
          child: GestureDetector(
            onTap: (){
              FocusScopeNode currentFocus = FocusScope.of(context);
              if(!currentFocus.hasPrimaryFocus){
                currentFocus.unfocus();
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  // bottom: MediaQuery.of(context).size.height / 4.693 + 30),
                  Container(
                    alignment: Alignment.topCenter,
                    // color: Colors.black,
                    // 0xFFFFD8CF
                    // FFCFC4
                    // 0xFFFFd2cb
                    // f6dc85
                    color: Color(0xFFF6DC85),
                  ),
                  RotatedBox(
                      quarterTurns: 1,
                      child: Image.asset(
                        "assets/Map.png",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.height/1.8,
                      )),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height/25,
                    left: 35,
                    child: GestureDetector(
                      onTap: ()=>button(1),
                      child: Text(
                        "BACK",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height -
                        (MediaQuery.of(context).size.height / 2.8),
                    left: 27,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Find your",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "Pawmate",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              // fontWeight: FontWeight.w500,
                              fontSize: 32),
                          textAlign: TextAlign.left,
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 10,top: 10),
                          child: Container(
                            width: 275,
                            height: 50,
                            // padding: EdgeInsets.symmetric(vertical: 30),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                TextField(
                                  controller: otpTED,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter OTP sent to you",
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintStyle: TextStyle(color: Colors.grey.shade600.withOpacity(0.9),),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIconConstraints: BoxConstraints(
                                      maxWidth: 10,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.amber),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white54),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (text){
                                    print("Preesed $text");
                                    if(text.replaceAll("", "").isNotEmpty){
                                      signMeUp(context);
                                      button(3);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_outlined,
                                    color: Colors.lightBlueAccent,
                                  ),
                                  splashRadius: 5,
                                  onPressed: () {
                                    if(otpTED.text.replaceAll("", "").isNotEmpty){
                                      signMeUp(context);
                                      button(3);
                                    }
                                    print("Pressed");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "Get intouch with new pawmates around you.",
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: GestureDetector(
                      onTap: (){
                        if(otpTED.text.replaceAll("", "").isNotEmpty){
                          signMeUp(context);
                        }
                      },
                      child: Text(
                        "NEXT",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    bottom: MediaQuery.of(context).size.height/25,
                    right: 35,
                  ),
                ],
              ),
            ),
            // Container(
            //   height: MediaQuery.of(context).size.height,
            //   width:  MediaQuery.of(context).size.width,
            //   child: Stack(
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.only(
            //             bottom: MediaQuery.of(context).size.height / 4.693 + 30),
            //         child: Container(
            //           alignment: Alignment.topCenter,
            //           color: Colors.black,
            //         ),
            //       ),
            //       ListView(
            //         children: [
            //           Align(
            //             alignment: Alignment.bottomCenter,
            //             child: Padding(
            //               padding: const EdgeInsets.only(bottom: 200,top: 50),
            //               child: Lottie.network(
            //                 "https://assets6.lottiefiles.com/packages/lf20_k86wxpgr.json",
            //                 repeat: true,
            //                 // width: MediaQuery.of(context).size.width*10,
            //                 // height: MediaQuery.of(context).size.height,
            //                 controller: _animationController2,
            //                 onLoaded: (animate) {
            //
            //                   _animationController2.duration = Duration(seconds: 5);
            //                   // print('${_animationController2.lowerBound}is lowerbound');
            //                   // print('${_animationController2.upperBound}is upper');
            //                   // _animationController2.forward().whenComplete(() {_animationController2.animateBack(0.5);_animationController2.repeat(reverse: true,min: 0.5,max: 0.9,period: Duration(microseconds: (animate.duration.inMicroseconds~/2)));});
            //                   _animationController2.repeat(reverse: false);
            //                 },
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //       Align(
            //         alignment: Alignment.bottomCenter,
            //         child: Padding(
            //           padding: EdgeInsets.only(
            //               bottom: MediaQuery.of(context).size.height / 4.693),
            //           child: SizedBox(
            //             width: 275,
            //             height: 60,
            //             child: Container(
            //               child: Stack(
            //                 alignment: Alignment.centerRight,
            //                 children: [
            //                   TextField(
            //                     controller: otpTED,
            //                     // focusNode: _focusNode,
            //                     style: TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 16,
            //                     ),
            //                     decoration: InputDecoration(
            //                       hintText: "Enter OTP sent to you",
            //                       hintStyle: TextStyle(color: Colors.grey.shade700),
            //                       filled: true,
            //                       fillColor: Colors.white,
            //                       suffixIconConstraints: BoxConstraints(
            //                         maxWidth: 10,
            //                       ),
            //                       focusedBorder: OutlineInputBorder(
            //                           borderSide: BorderSide(color: Colors.amber),
            //                           borderRadius:
            //                           BorderRadius.all(Radius.circular(50))),
            //                       enabledBorder: OutlineInputBorder(
            //                           borderSide: BorderSide(color: Colors.white54),
            //                           borderRadius:
            //                           BorderRadius.all(Radius.circular(50))),
            //                     ),
            //                   ),
            //                   IconButton(
            //                     icon: Icon(
            //                       Icons.arrow_forward_outlined,
            //                       color: Colors.lightBlueAccent,
            //                     ),
            //                     splashRadius: 5,
            //                     onPressed: () {
            //                       // _focusNode.unfocus();
            //                       // _focusNode.canRequestFocus = false;
            //                       if(otpTED.text.replaceAll("", "").isNotEmpty){
            //                         signMeUp(context);
            //                         button(3);
            //                       }
            //                       print("Pressed");
            //                     },
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),
        ),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}
 auth.PhoneCodeSent smsCodeSent;
 auth.PhoneCodeAutoRetrievalTimeout autoRetrieve;

getSnack(BuildContext context,String text){
  ScaffoldMessenger.maybeOf(context).showSnackBar(SnackBar(
    content: Text(text),
    backgroundColor: Colors.redAccent,
    elevation: 5.0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    behavior: SnackBarBehavior.floating,
  ));
}


Future<void> verifyPhone(BuildContext context) async{
  print("inside verfyphone");
  autoRetrieve =(String varId){
    PhoneDatabase.saveVID(varId);
  };

  smsCodeSent = (String verId, [int forceCodeResent]) {
    PhoneDatabase.saveVID(verId);
    print(verId);
  };

  // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
  //   Navigator.push(context, MaterialPageRoute(builder: (context)=>smsCodeDialoge()));
  // });

  print("Inside verify otp");
  final auth.PhoneVerificationCompleted verificationSuccess = (auth.AuthCredential auth0){};
  final auth.PhoneVerificationFailed verificationFailed = (auth.FirebaseAuthException e){
    print('Message:  ${e.message}');
    getSnack(context,e.message.split(".").first);
  };

  String _phoneNumber = await PhoneDatabase.getPhoneNumber();


  await auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$_phoneNumber", timeout: const Duration(seconds: 60),
      verificationCompleted: verificationSuccess,
      verificationFailed: verificationFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve
  );


}



signMeUp(BuildContext context) async {
  String varID = await PhoneDatabase.getVID();
  print("inside sign Me Up");
  int count = 0;

  final auth.AuthCredential credential = auth.PhoneAuthProvider.credential(verificationId: varID, smsCode: otpTED.text);
  await auth.FirebaseAuth.instance.signInWithCredential(credential).then((value)async{
    await saveUserInfoToFireStore();
    await updateCurrentUser();
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>EditProfilePage(isSignUp: true,)),(route){
      return count++ == 2;
    });
    // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditProfilePage(isSignUp: true,)));
  }).catchError((e){
    print(e);
    getSnack(context,e.toString().split(".").first);
  });
}

User signUpCurrentUser;

saveUserInfoToFireStore()async{
  print("inside save user");
  // String _username =await PhoneDatabase.getUserNameSharedPreference();
  final auth.User user = auth.FirebaseAuth.instance.currentUser;
  DocumentSnapshot documentSnapshot = await usersReference.doc(user.uid).get();

  Map<String,bool>_temp = {
    "Pet Trainer":false,
    "Pet Shop":false,
    "Vet":false,
  };
  if(!documentSnapshot.exists){
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    var token = await _firebaseMessaging.getToken();
    usersReference.doc(user.uid).set({
      "id": user.uid,
      "profileName": "",
      "username" : null,
      "petUrl" : "https://firebasestorage.googleapis.com/v0/b/petezzie.appspot.com/o/defaults%2Fdog.png?alt=media&token=265b5b75-82fe-4d93-988d-0d0db10d1a54",
      "humanUrl" : "https://firebasestorage.googleapis.com/v0/b/petezzie.appspot.com/o/defaults%2Fhuman.png?alt=media&token=d474de0f-68b0-4fb3-aa66-ff5082b245fd",
      "email" : null,
      "bio": "",
      "timestamp" : timestamp,
      "isOnline" : true,
      "lastOnline": DateTime.now().millisecondsSinceEpoch,
      "isOpen" : true,
      'usernameInLowerCase': null,
      "accountType":_temp,
      "notificationToken":token,
    });
    //     .then((value)async {
    //   await FirebaseDatabase.instance.reference().child(user.uid).set({
    //     "isOnline":true,
    //     "lastOnline":DateTime.now().microsecondsSinceEpoch,
    //   });
    // });

    await tailsReference.doc(user.uid).collection("userTails").doc(user.uid).set({});
    await pawsReference.doc(user.uid).collection("userPaws").doc(user.uid).set({});

    documentSnapshot = await usersReference.doc(user.uid).get();
  }
  signUpCurrentUser =  User.fromDocument(documentSnapshot);
  PhoneDatabase.saveUserLoggedInSharedPreference(false);
}


// class smsCodeDialoge extends StatefulWidget {
//   @override
//   _smsCodeDialogeState createState() => _smsCodeDialogeState();
// }
//
// class _smsCodeDialogeState extends State<smsCodeDialoge> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             alignment: Alignment.center,
//             child: Form(
//               child: TextFormField(
//                 controller: smsCodeTextEditingController,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//                 decoration: textFieldInputDecoration("Enter Verification Code"),
//               ),
//             ),
//           ),
//           SizedBox(height: 40.0,),
//           GestureDetector(
//             onTap: (){print("hello");signMeUp(context);},
//             child: Container(
//               alignment: Alignment.center,
//               padding: EdgeInsets.symmetric(vertical: 20),
//               decoration: BoxDecoration(
//                 color: Colors.deepOrangeAccent,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Text("Sign Up", style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 17,
//               ),),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }
//
//
