
import 'package:petziee/pages/Profile/SideMenuOptions/AboutPage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/EditProfilePage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/HelpPage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/PrivacyPage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/SecurityPage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/ThemePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
   final double heightOfSizeBox = 32;
  @override
  Widget build(BuildContext context) {
    return Container(
      color:  Theme.of(context).primaryColor,
      width: MediaQuery.of(context).size.width*2/3,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 55.0,
              // color: Theme.of(context).primaryColor,
              child: DrawerHeader(
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    SizedBox(width: 10,),
                    Text(
                      "Setting",
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
                //Use this If image is need in the title of the menu bar
                // decoration: BoxDecoration(),
              ),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: (){
                print("Tapped Edit Profile");
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditProfilePage()));
              },
              child: Container(
                height: 50,
                width: double.infinity,
                // color: Colors.black,
                child: Row(
                  children: [
                      SizedBox(width: 10,),
                      Icon(Icons.person_add_alt_1_rounded),
                      SizedBox(width: 10,),
                      Text("Edit Profile", style: style(),),
                  ],
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: (){
            //     print("Tapped Saved");
            //     // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditProfilePage()));
            //
            //   },
            //   child: Container(
            //     height: 50,
            //     width: double.infinity,
            //     color: Colors.black,
            //     child: Row(
            //       children: [
            //         SizedBox(width: 10,),
            //         Icon(Icons.bookmark_border_rounded),
            //         SizedBox(width: 10,),
            //         Text("Saved", style: style(),),
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: (){
                print("Tapped Privacy");
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PrivacyPage()));

              },
              child: Container(
                height: 50,
                width: double.infinity,
                // color: Colors.black,
                child: Row(
                  children: [
                    SizedBox(width: 10,),

                    Icon(Icons.lock_outline_rounded),
                    SizedBox(width: 10,),
                    Text("Privacy", style:style(),),
                  ],
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: (){
            //     print("Tapped LogOut");
            //     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SecurityPage()));
            //
            //   },
            //   child: Container(
            //     height: 50,
            //     width: double.infinity,
            //     color: Colors.black,
            //     child: Row(
            //       children: [
            //         SizedBox(width: 10,),
            //
            //         Icon(Icons.security_outlined),
            //         SizedBox(width: 10,),
            //         Text("Security", style: style(),),
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: (){
                print("Tapped Themes");
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ThemePage()));

              },
              child: Container(
                height: 50,
                width: double.infinity,
                // color: Colors.black,
                child: Row(
                  children: [
                    SizedBox(width: 10,),
                    Icon(Icons.color_lens_outlined),
                    SizedBox(width: 10,),
                    Text("Theme", style: style(),),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                print("Tapped Help");
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HelpPage()));

              },
              child: Container(
                height: 50,
                width: double.infinity,
                // color: Colors.black,
                child: Row(
                  children: [
                    SizedBox(width: 10,),

                    Icon(Icons.help_outline_rounded),
                    SizedBox(width: 10,),
                    Text("Help", style: style(),),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                print("Tapped About");
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AboutPage()));

              },
              child: Container(
                height: 50,
                width: double.infinity,
                // color: Colors.black,
                child: Row(
                  children: [
                    SizedBox(width: 10,),

                    Icon(Icons.info_outline_rounded),
                    SizedBox(width: 10,),
                    Text("About", style:style(),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
style(){
  return TextStyle(
    fontSize: 17,
  );
}
