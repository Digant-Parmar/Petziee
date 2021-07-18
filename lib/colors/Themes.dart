
// @dart=2.9

import 'package:flutter/material.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

const kBackgroundColor = Color(0xFF202020);
const kPrimaryColor = Color(0xFFFFBD73);
const NInactive = Colors.white;
const NActive = Color(0xFFFFBD73);


class ThemeNotifier with ChangeNotifier {

  ThemeData _themeData;
  String _themeName;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;
  getThemeName()=>_themeName;
  setTheme(ThemeData themeData,String themeName) async {
    _themeData = themeData;
    _themeName = themeName;
    PhoneDatabase.saveAppTheme(themeName);
    notifyListeners();
  }


}


ThemeData getStringToTheme(String themeName){
  switch(themeName){
    case "blueTheme":
      return blueTheme;
    case "blackTheme":
      return blackTheme;
    case "greenTheme":
      return greenTheme;
    case "pinkTheme":
      return pinkTheme;
    case "whiteTheme":
      return whiteTheme;
    default :
      return blackTheme;
  }
}


/// ---- Theme.of(context).highlightColor is for paws and tails button colors which only consists of black and white colors
/// --- hover color is for the background of the chat screen


/// ----  Blue Theme  ----
final bluePrimary         = Color(0xFF3F51B5);
final blueAccent          = Color(0xFFFF9800);
final blueBackground      = Color(0xFFFFFFFF);


final blueTheme = ThemeData(
    primaryColor: bluePrimary,
    accentColor: blueAccent,
    backgroundColor: blueBackground,
  highlightColor: Colors.black,
    shadowColor: Colors.grey[500],
  hoverColor: Color(0xFF9DA2D5)

);

/// ----  Black Theme  ----
final blackPrimary       = Color(0xFF000000);
final blackAccent        = Color(0xFFBB86FC);
final blackBackground    = Color(0xFF4A4A4A);
final blackTheme = ThemeData(
  primaryColor: blackPrimary,
  accentColor: blackAccent,
  backgroundColor: blackBackground,
  highlightColor: Colors.white,
    hoverColor: Colors.grey[800],
  canvasColor: Colors.black,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  shadowColor: Colors.black,

);

/// ----  Green Theme  ----
final greenPrimary        = Color(0xFF4CAF50);
final greenAccent         = Color(0xFF631739);
final greenBackground      = Color(0xFFFFFFFF);
final greenTheme = ThemeData(
    primaryColor: greenPrimary,
    accentColor: greenAccent,
    backgroundColor: greenBackground,
  highlightColor: Colors.black,
    shadowColor: Colors.grey[500],
    hoverColor: Color(0xFF9DA2D5)

);

/// ----  Pink Theme  ----
final pinkPrimary         =
Color(0xFFF85C70
    // E91E63
);
final pinkAccent          = Color(0xFF0C7D9C);
final pinkBackground      = Color(0xFFFFFFFF);
final pinkTheme = ThemeData(
    primaryColor: pinkPrimary,
    accentColor: pinkAccent,
    backgroundColor: pinkBackground,
  highlightColor: Colors.black,
    shadowColor: Colors.grey[500],
    hoverColor: Color(0xFF9DA2D5)

);


/// ---- White Theme ----
final whitePrimary = Color(0xFFFFFFFF);
final whiteAccent         = Color(0xFF000000);
final whiteBackground      = Color(0xFFFFFFFF);

final whiteTheme = ThemeData(
  primaryColor: whitePrimary,
  accentColor: whiteAccent,
  backgroundColor: whiteBackground,
  highlightColor: Colors.black,
    hoverColor: Color(0xFF9DA2D5),
  shadowColor: Colors.grey[500],
    brightness: Brightness.light,
);


class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> sky = [Color(0xFF6448FE), Color(0xFF5FC6FF)];
  static List<Color> sunset = [Color(0xFFFE6197), Color(0xFFFFB463)];
  static List<Color> sea = [Color(0xFF61A3FE), Color(0xFF63FFD5)];
  static List<Color> mango = [Color(0xFFFFA738), Color(0xFFFFE130)];
  static List<Color> fire = [Color(0xFFFF5DCD), Color(0xFFFF8484)];
  static List<Color> temp = [Color(0xFFFF00AF), Color(0xFF38FF00)];

}

class GradientTemplate {
  static List<GradientColors> gradientTemplate = [
    GradientColors(GradientColors.sky),
    GradientColors(GradientColors.sunset),
    GradientColors(GradientColors.sea),
    GradientColors(GradientColors.mango),
    GradientColors(GradientColors.fire),
    GradientColors(GradientColors.temp),

  ];
}

