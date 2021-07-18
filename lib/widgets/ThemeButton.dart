// @dart=2.9
import 'package:petziee/colors/Themes.dart';
import 'package:petziee/icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget {
  final ThemeData buttonThemeData;
  final String themeName;

  ThemeButton({this.buttonThemeData,this.themeName});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool selected = (themeNotifier.getTheme() == buttonThemeData);

    return GestureDetector(
      onTap: (){
        themeNotifier.setTheme(buttonThemeData,themeName);
      },
      child: NeuCard(
        key: Key((selected) ? "ON" : "OFF"),
        color: Colors.white,
        curveType: CurveType.emboss,
        bevel: 30,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                CustomIcons.paw,
                color: buttonThemeData.primaryColor,
                size: 45,
              ),
              (selected)?Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: Colors.black),
                  ),
                  padding: EdgeInsets.all(1),
                  child: Icon(
                    Icons.circle,
                    color: buttonThemeData.accentColor,
                    size: 15,
                  ),
                ),
              ):Container(),
            ],
          ),
        ),
      ),
    );
  }
}
