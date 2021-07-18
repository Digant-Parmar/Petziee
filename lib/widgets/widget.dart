import 'package:flutter/material.dart';

InputDecoration textFieldInputDecoration(String hintText){
  return InputDecoration(
    labelText: hintText,

    // hintText: hintText,
    // hintStyle: TextStyle(
    //   color: Colors.white54,
    //   fontSize: 12
    // ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.amber),
    ),
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54)
    ),
  );
}

InputDecoration profileEditInputDecoration(String text){
  return InputDecoration(
    labelText: text,
    labelStyle: TextStyle(
      color: Colors.white54,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54)
    ),
  );
}
