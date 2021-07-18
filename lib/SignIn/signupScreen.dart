// @dart=2.9
import 'package:petziee/SignIn/Username.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'file:///C:/Users/digan/AndroidStudioProjects/petziee/lib/SignIn/PhoneNumber.dart';

import 'Verification.dart';

// //
// TextEditingController smsCodeTextEditingController = new TextEditingController();
// TextEditingController userNameTextEditingController = new TextEditingController();
// // TextEditingController phoneNumberTextEditingController = new TextEditingController();
//
//
// String _username;
// String _otp;
//



class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin{


  static final PageController controller = PageController();
  AnimationController _animationController;
  List<Widget>_list = [
    Username(onAddButtonTapped),
    PhoneNumber(onAddButtonTapped),
    Verification(onAddButtonTapped),
  ];

  bool isLoading = false;
  int currentIndex = 0;
  bool isCodeSent = false;
  final formKey = GlobalKey<FormState>();

  TextEditingController phoneNumberEditingController = new TextEditingController();
  // TextEditingController passwordTextEditingController = new TextEditingController();
  TextEditingController smsCodeTextEditingController = new TextEditingController();


  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      // body: SingleChildScrollView(
      //   child: Stack(
      //     children: [
      //       Container(
      //         height: size.height,
      //         alignment: Alignment.bottomCenter,
      //         child: Container(
      //           padding: EdgeInsets.symmetric(horizontal: 24),
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Form(
      //                 key: formKey,
      //                 child: Column(
      //                   children: [
      //                     TextFormField(
      //                       validator: (val) {
      //                         return val.isEmpty || val.length < 2
      //                             ? "Please provide proper Username"
      //                             : null;
      //                       },
      //                       controller: _userNameTextEditingController,
      //
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 16,
      //                       ),
      //                       decoration: textFieldInputDecoration("Username"),
      //                     ),
      //                     TextFormField(
      //                       keyboardType: TextInputType.number,
      //                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      //
      //                       validator: (val) {
      //                         //TODO -- Provide Proper validator for the phone number
      //                         return val.isEmpty || val.length != 10
      //                             ? "Please provide proper phone Number"
      //                             : null;
      //                       },
      //                       controller: phoneNumberEditingController,
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 16,
      //                       ),
      //                       decoration: textFieldInputDecoration(
      //                           "Phone Number",
      //                       ),
      //                     ),
      //                     TextFormField(
      //                       keyboardType: TextInputType.visiblePassword,
      //                       obscureText: true,
      //                       validator: (val) {
      //                         return val.length > 5
      //                             ? null
      //                             : "Please provide password of at least 6 letters";
      //                       },
      //                       controller: passwordTextEditingController,
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 16,
      //                       ),
      //                       decoration: textFieldInputDecoration("Password"),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               SizedBox(height: 8,),
      //               GestureDetector(
      //                 onTap: () {
      //                   print("Tapped");
      //                 },
      //                 child: Container(
      //                   alignment: Alignment.centerRight,
      //                   child: Container(
      //                     padding: EdgeInsets.symmetric(horizontal: 16,
      //                         vertical: 8),
      //                     child: Text("Forgot Password ?", style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 12,
      //                     ),),
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(height: 8,),
      //               GestureDetector(
      //                 onTap: verifyPhone,
      //                 child: Container(
      //                   alignment: Alignment.center,
      //                   width: size.width,
      //                   padding: EdgeInsets.symmetric(vertical: 20),
      //                   decoration: BoxDecoration(
      //                     color: Colors.deepOrangeAccent,
      //                     borderRadius: BorderRadius.circular(30),
      //                   ),
      //                   child: Text("Sign Up", style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 17,
      //                   ),),
      //                 ),
      //               ),
      //               SizedBox(height: 16,),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Text("Already have an account? ", style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 17,
      //                   ),),
      //                   GestureDetector(
      //                     //TODO -- Implement the already have account tap
      //                     onTap: () {
      //                       print("Tapped");
      //                     },
      //                     child: Container(
      //                       padding: EdgeInsets.symmetric(vertical: 8),
      //                       child: Text("Sign In", style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 17,
      //                         decoration: TextDecoration.underline,
      //                       ),),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               SizedBox(height: 60,),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: controller,
            children: _list,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index){
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                currentIndex = index;
              });
              print("Page index : $index");
              pageChange(index);
            },
          ),
          // SafeArea(
          //   child: Align(
          //     alignment: Alignment.bottomLeft,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: Colors.grey.withOpacity(0.2),
          //       ),
          //       // child: IconButton(
          //       //   icon: Icon(Icons.arrow_back_rounded,color: Colors.white,),
          //       //   //Previous page
          //       //   onPressed: ()=>controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeOut),
          //       // ),
          //     ),
          //   ),
          // ),
      //   getButtonLayout(),
      //   Container(
      //   color: Colors.lightBlueAccent,
      //   child: Row(
      //     mainAxisSize: MainAxisSize.max,
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: <Widget>[
      //       FlatButton(
      //         child: Text('Prev'),
      //         onPressed: () {
      //           controller.previousPage(
      //               duration: Duration(milliseconds: 500), curve: Curves.easeOut);
      //         },
      //       ),
      //       FlatButton(
      //         child: Text('Next'),
      //         onPressed: () {
      //           controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeOut);
      //         },
      //       )
      //     ],
      //   ),
      // ),
        ],
      ),
    );
  }

  pageChange(int index)async{
    switch(index){
      case 1:
        // String x = await PhoneDatabase.getUserNameSharedPreference();
        // print("Username is $x");
        break;
      case 2:
        String y = await PhoneDatabase.getPhoneNumber();
        print("Phone number is $y");
        break;
    }
  }
  static void onAddButtonTapped(int index){
    if(index<3)controller.animateToPage(index, duration: Duration(milliseconds: 600), curve: Curves.easeOut);
    // switch(index){
    //   case 1:
    //     print("Username is ${userNameTextEditingController.text}");
    //     break;
    //   case 2:
    //     print("Phone number is ${phoneNumberTextEditingController.text}");
    //     break;
    //   case 3:
    //     print("otp is ${smsCodeTextEditingController.text}");
    //     break;
    // }
  }
  //
  // setUsername(String username){
  //   setState(() {
  //     _username = username;
  //   });
  // }

  getBackButton(){
    controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }
  bool isButtonTapped = true;
  getButtonLayout(){
    switch(currentIndex){
      case 0:
        return Lottie.network(
            "https://assets5.lottiefiles.com/packages/lf20_51hxjnkl.json",
          repeat: false,
        );
        break;
      case 1:
        return Lottie.network(
            "https://assets9.lottiefiles.com/packages/lf20_avt7utpz.json"
        );
        break;
      case 2:
        _animationController.reset();
        print("this is 3 case");
        return isButtonTapped?GestureDetector(
          child:Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 20,
              width: 200,
              color: Colors.redAccent,
              child: Text(
                "Send Message",
              ),
            ),
          ),
          onTap: (){
            setState(() {
              isButtonTapped = false;
            });
            // _animationController.forward();
          },
        ): Lottie.network(
    "https://assets6.lottiefiles.com/temp/lf20_taipbM.json",
    controller: _animationController,
    // animate: false,
    onLoaded: (animation){
    _animationController
    ..duration = animation.duration..repeat(reverse: false);
    },
    repeat: false,
    );
        break;

    }
  }

  // Future<void> verifyPhone() async{
  //   final auth.PhoneCodeAutoRetrievalTimeout autoRetrieve =(String varId){
  //     verificationId = varId;
  //   };
  //
  //
  //
  //   final auth.PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResent]) {
  //     verificationId = verId;
  //     print(verId);
  //   };
  //
  //   SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
  //     Navigator.push(context, MaterialPageRoute(builder: (context)=>smsCodeDialoge()));
  //   });
  //
  //
  //   final auth.PhoneVerificationCompleted verificationSuccess = (auth.AuthCredential auth0){};
  //   final auth.PhoneVerificationFailed verificationFailed = (auth.FirebaseAuthException e){
  //     print('${e.message}');
  //   };
  //   await auth.FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: "+91"+phoneNumberEditingController.text, timeout: const Duration(seconds: 60),
  //       verificationCompleted: verificationSuccess,
  //       verificationFailed: verificationFailed,
  //       codeSent: smsCodeSent,
  //       codeAutoRetrievalTimeout: autoRetrieve
  //   );
  //
  // }

}
// signMeUp(BuildContext context) async {
//   int count = 0;
//   final auth.AuthCredential credential = auth.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCodeTextEditingController.text);
//   await auth.FirebaseAuth.instance.signInWithCredential(credential).then((value){
//     saveUserInfoToFireStore();
//     Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>HomePage(initPage: 2,)),(route){
//       return count++ == 2;
//     });
//   }).catchError((e){
//     print(e);
//   });
// }
//
//
// saveUserInfoToFireStore()async{
// final auth.User user = auth.FirebaseAuth.instance.currentUser;
// DocumentSnapshot documentSnapshot = await usersReference.doc(user.uid).get();
//
// if(!documentSnapshot.exists){
//   usersReference.doc(user.uid).set({
//     "id": user.uid,
//     "profileName": "",
//     "username" : userNameTextEditingController.text,
//     "petUrl" : " ",
//     "humanUrl" : " ",
//     "email" : " ",
//     "bio": " ",
//     "timestamp" : timestamp,
//     "isOnline" : true,
//     "lastOnline": DateTime.now(),
//     "isOpen" : true,
//   });
//
//   await tailsReference.doc(user.uid).collection("userTails").doc(user.uid).set({});
//   await pawsReference.doc(user.uid).collection("userPaws").doc(user.uid).set({});
//
//   documentSnapshot = await usersReference.doc(user.uid).get();
//   }
//   signUpCurrentUser =  User.fromDocument(documentSnapshot);
//
//
//   PhoneDatabase.saveUserLoggedInSharedPreference(false);
//
//
// }
//
//
//
//
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
//               decoration: textFieldInputDecoration("Enter Verification Code"),
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
