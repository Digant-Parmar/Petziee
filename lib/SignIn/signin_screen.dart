import 'package:petziee/colors/Themes.dart';
import 'package:flutter/material.dart';


class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/cat.png"),
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
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
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SIGN IN",
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(
                              "SIGN UP",
                              style: Theme.of(context).textTheme.button,
                            ),
                          ],
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.alternate_email,
                                  color: kPrimaryColor,
                                ),
                              ),
                              Expanded(child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Email Address",
                                ),
                              ),)
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.lock,
                                color: kPrimaryColor,
                              ),
                            ),
                            Expanded(child: TextField(
                              decoration: InputDecoration(
                                hintText: "Password",
                              ),
                            ),)
                          ],
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children:<Widget> [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.5),
                                  ),
                                ),
                                child: Icon(
                                    Icons.android,
                                  color: Colors.white.withOpacity(.5),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.5),
                                  ),
                                ),
                                child: Icon(
                                  Icons.chat,
                                  color: Colors.white.withOpacity(.5),
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kPrimaryColor,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
