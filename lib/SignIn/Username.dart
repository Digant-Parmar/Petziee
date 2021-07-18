import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';


class Username extends StatefulWidget {
  final void Function(int) button;
  Username(this.button);
  @override
  _UsernameState createState() => _UsernameState(button);
}

class _UsernameState extends State<Username>with TickerProviderStateMixin ,AutomaticKeepAliveClientMixin<Username> {

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  final void Function(int)button;
  _UsernameState(this.button);

  // AnimationController _animationController1;
  // AnimationController _animationController2;
  // // AnimationController _textAnimationController;
  // Animation _animation;
  // // ScrollController _scrollController;
  // // final pageKey = PageStorageKey<PageStorageKey>();
  TextEditingController usernameTED = new TextEditingController();


  final _focusNode = FocusNode();

  @override
  void initState() {
    // _animationController1 = AnimationController(vsync: this);
    // _animationController2 = AnimationController(vsync: this);
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    // _textAnimationController.dispose();
    // _animationController1.dispose();
    // _animationController2.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
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
                  color: Color(0xFFFFCFC4),
                ),
                Positioned(
                  // button(1);

                  child: GestureDetector(
                    onTap: ()=>button(1),
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

                Transform.scale(
                  scale: 1.4,
                  child: RotationTransition(
                    turns: new AlwaysStoppedAnimation(-8 / 360),
                    child: SizedBox(
                      height: 260,
                      width: MediaQuery.of(context).size.width * 1.9,
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/line 2.png",
                          width: MediaQuery.of(context).size.width * 1.9,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 3.5,
                  left: MediaQuery.of(context).size.width / 9,
                  child: RotationTransition(
                    turns: new AlwaysStoppedAnimation(-2 / 360),
                    child: SizedBox(
                      height: 260,
                      width: 200,
                      child: Container(
                        // color: Colors.blue,
                        alignment: Alignment.center,
                        child: Image.asset("assets/home4.png",),

                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height -
                      (MediaQuery.of(context).size.height / 3.4),
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
                        "indicated woof",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            // fontWeight: FontWeight.w500,
                            fontSize: 32),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Move your tail with the correct one.",
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,

                          letterSpacing: 1.3,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 41,
                  left: 35,
                  child: Container(
                    width: 35,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                  ),
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
          //           color: Colors.grey.shade600,
          //         ),
          //       ),
          //       Align(
          //         alignment: Alignment.bottomCenter,
          //         child: Padding(
          //           padding: const EdgeInsets.only(bottom: 200),
          //           child: Container(
          //             height: 260,
          //             width: 400,
          //             alignment: Alignment.center,
          //             child: Lottie.network(
          //               "https://assets2.lottiefiles.com/packages/lf20_syqnfe7c.json",
          //               fit: BoxFit.cover,
          //               repeat: true,
          //               controller: _animationController2,
          //               onLoaded: (animate) {
          //                 _animationController2.duration = animate.duration;
          //                 print('${_animationController2.lowerBound}is lowerbound');
          //                 print('${_animationController2.upperBound}is upper');
          //                 _animationController2.forward().whenComplete(() {_animationController2.animateBack(0.5);_animationController2.repeat(reverse: true,min: 0.5,max: 0.9,period: Duration(microseconds: (animate.duration.inMicroseconds~/2)));});
          //                 // _animationController.forward();
          //               },
          //             ),
          //           ),
          //         ),
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
          //                     controller: usernameTED,
          //                     // focusNode: _focusNode,
          //                     style: TextStyle(
          //                       color: Colors.black,
          //                       fontSize: 16,
          //                     ),
          //                     decoration: InputDecoration(
          //                       hintText: "Username",
          //                       errorStyle: TextStyle(
          //                         color: Colors.lightBlueAccent
          //                       ),
          //                       errorBorder: OutlineInputBorder(
          //                           borderSide: BorderSide(color: Colors.white54),
          //                           borderRadius:
          //                           BorderRadius.all(Radius.circular(50)),
          //                       ),
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
          //                       // if(usernameTED.text.length>=2){
          //                         PhoneDatabase.saveUserNameSharedPreference(usernameTED.text);
          //                       // }else{
          //                       //   getSnack();
          //                       // }
          //                       print("Pressed");
          //                     },
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       SafeArea(
          //         child: Align(
          //           alignment: Alignment.topCenter,
          //           child: Padding(
          //             padding: const EdgeInsets.only(top: 20),
          //             child: Column(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 Stack(
          //                   children: [
          //                     Container(
          //                       child: Lottie.asset(
          //                         // "https://assets10.lottiefiles.com/private_files/lf30_FPH6Ci.json",
          //                         "json_files/welcome.json",
          //                         repeat: true,
          //                         controller: _animationController1,
          //                         onLoaded: (animate) {
          //                           _animationController1.duration =
          //                               animate.duration;
          //                           _animationController1.repeat(
          //                             reverse: false,
          //                           );
          //                           // _animationController.forward();
          //                         },
          //                       ),
          //                     ),
          //                     Container(
          //                       // color: Colors.green.withOpacity(0.3),
          //                       height: 125,
          //                       child: Align(
          //                         alignment: Alignment.bottomCenter,
          //                         child: Text("to",
          //                             style: GoogleFonts.getFont(
          //                               'Dancing Script',
          //                               fontSize: 40,
          //                               color: Colors.white,
          //                             )),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 Padding(
          //                   padding: const EdgeInsets.only(left: 8, top: 4),
          //                   child: Text(
          //                     "Petziee",
          //                     style: GoogleFonts.getFont(
          //                         'Shadows Into Light',
          //                         fontSize: 60,
          //                         color: Colors.white,
          //                         fontWeight: FontWeight.w400,
          //                         letterSpacing: 3),
          //                   ),
          //                 ),
          //               ],
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
  getSnack(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please provide proper Username"),
      backgroundColor: Colors.redAccent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      behavior: SnackBarBehavior.floating,
    ));
    return "";
  }
}
