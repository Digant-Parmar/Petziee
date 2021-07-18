// @dart=2.9
import 'package:petziee/colors/Themes.dart';
import 'file:///C:/Users/digan/AndroidStudioProjects/petziee/lib/SignIn/signupScreen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff050505),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.1),
                ]),
                image: DecorationImage(
                  image: AssetImage("assets/cat.png"),
                  fit: BoxFit.cover,
                ),
              ),
              // child: Container(
              //   padding: EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.bottomRight,
              //       colors: [
              //         Colors.black.withOpacity(.9),
              //         Colors.black.withOpacity(0.1),
              //       ],
              //
              //     ),
              //   ),
              // ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text: "BAKING LESSONS\n",
                        style: Theme.of(context).textTheme.headline4),
                    TextSpan(
                      text: "MASTER THE ART OF BAKING",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ]),
                ),
                FittedBox(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, _createRoute());
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 25),
                      padding:
                      EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: kPrimaryColor,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "START EXPLORING",
                            style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignUp(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }
}

