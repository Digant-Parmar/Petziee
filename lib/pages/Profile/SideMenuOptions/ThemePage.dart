// @dart=2.9
import 'package:petziee/colors/Themes.dart';
import 'package:petziee/widgets/ThemeButton.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({Key key}) : super(key: key);

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  List<Widget> _themeList = [
    ThemeButton(buttonThemeData: blueTheme,themeName: "blueTheme",),
    ThemeButton(buttonThemeData: blackTheme,themeName: "blackTheme",),
    ThemeButton(buttonThemeData: greenTheme,themeName: "greenTheme",),
    ThemeButton(buttonThemeData: pinkTheme,themeName:"pinkTheme",),
    ThemeButton(buttonThemeData: whiteTheme,themeName:"whiteTheme",),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Theme",
          style: TextStyle(
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Align(
        child: GridView.builder(
          padding: EdgeInsets.only(top: 30,left: 7,right: 7),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 15
          ),
          itemBuilder: (BuildContext context, index){
            return _themeList[index];
          },
          itemCount: _themeList.length,
        ),
      ),
    );
  }
}

