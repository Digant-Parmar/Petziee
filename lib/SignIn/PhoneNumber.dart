// @dart=2.9
import 'package:petziee/SignIn/Verification.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';



class PhoneNumber extends StatefulWidget {
  final void Function(int) button;

  // final void Function(int) onAddButtonTapped;
  PhoneNumber(this.button);
  @override
  _PhoneNumberState createState() => _PhoneNumberState(button);
}

class _PhoneNumberState extends State<PhoneNumber> with TickerProviderStateMixin,AutomaticKeepAliveClientMixin<PhoneNumber>{
  AnimationController _animationController2;

  final void Function(int) button;
  _PhoneNumberState(this.button);

  final _focusNode = FocusNode();

  @override
  void initState() {
    // FocusScope.of(context).requestFocus(FocusNode());
    _animationController2 = AnimationController(vsync: this);
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _animationController2.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  TextEditingController phoneNumberTED = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    return Scaffold(
        extendBodyBehindAppBar: true,
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
                    color: Color(0xFF8291DC),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 50,right: 50),
                    child: Transform.scale(
                      scale: 1.4,
                      child: RotationTransition(
                        turns: new AlwaysStoppedAnimation(-180/ 360),
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
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3,
                    right: MediaQuery.of(context).size.width / 9,
                    child: RotationTransition(
                      turns: new AlwaysStoppedAnimation(12 / 360),
                      child: SizedBox(
                        height: 260,
                        width: 220,
                        child: Container(
                          // color: Colors.blue,
                          alignment: Alignment.center,
                          child: Image.asset("assets/cal1.png",color: Color(0xFF202B65),),

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
                          "Always in our heart",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              // fontWeight: FontWeight.w500,
                              fontSize: 32),
                          textAlign: TextAlign.left,
                        ),
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
                                  controller: phoneNumberTED,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Enter you Phone number",
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintStyle: TextStyle(color: Colors.grey.shade600.withOpacity(0.9),),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIconConstraints: BoxConstraints(
                                      maxWidth: 10,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF8291DC)),
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
                                    if(phoneNumberTED.text.replaceAll("", "").isNotEmpty && phoneNumberTED.text.length == 10){
                                      buttonPressed();
                                    }else{
                                      getSnack();
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
                                    if(phoneNumberTED.text.replaceAll("", "").isNotEmpty && phoneNumberTED.text.length == 10){
                                      buttonPressed();
                                    }else{
                                      getSnack();
                                    }
                                    print("Pressed");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "Petziee community welcomes you.",
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
                    bottom: MediaQuery.of(context).size.height/25,
                    left: 35,
                    child: GestureDetector(
                      onTap: (){button(0);print("Pressed");},
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
                    child: GestureDetector(
                      onTap: (){if(phoneNumberTED.text.replaceAll("", "").isNotEmpty && phoneNumberTED.text.length == 10){
                        buttonPressed();
                      }else{
                        getSnack();
                      }},
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
            //           color: Colors.purple.shade900,
            //         ),
            //       ),
            //       ListView(
            //         children: [
            //           Align(
            //             alignment: Alignment.bottomCenter,
            //             child: Padding(
            //               padding: const EdgeInsets.only(bottom: 200,top: 50),
            //               child: Lottie.network(
            //                 "https://assets4.lottiefiles.com/private_files/lf30_mMEl1Z.json",
            //                 repeat: true,
            //                 controller: _animationController2,
            //                 onLoaded: (animate) {
            //                   _animationController2.duration = animate.duration;
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
            //                   controller: phoneNumberTED,
            //                     // focusNode: _focusNode,
            //                     style: TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 16,
            //                     ),
            //                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            //                     keyboardType: TextInputType.number,
            //                     decoration: InputDecoration(
            //                       hintText: "Enter you Phone number",
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
            //                       //Next page
            //                       if(phoneNumberTED.text.replaceAll("", "").isNotEmpty && phoneNumberTED.text.length == 10){
            //                         buttonPressed();
            //                       }else{
            //                         getSnack();
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

  buttonPressed()async{
    await PhoneDatabase.savePhonenumber(phoneNumberTED.text);
    verifyPhone(context);
    button(2);

  }

  getSnack(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Please enter a valid phone number"),
      backgroundColor: Colors.redAccent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      behavior: SnackBarBehavior.floating,
    ));
    return "";
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
