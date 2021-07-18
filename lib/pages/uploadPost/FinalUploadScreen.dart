// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';


class Editing{
  final String filepath;
  Editing({this.filepath});



  Future<String> videoTextEdit()async{

    String finalFilePath;

    // String  _platformVersion = 'Unknown';

    finalFilePath = await addText();

    return finalFilePath;
  }


  //
  // Future<void>initPlatformState()async{
  //   String platformVersion;
  //   try{
  //     platformVersion = await VideoEditor.platformVersion;
  //   }on PlatformException{
  //     platformVersion = 'Failed to get the platformVersion.';
  //   }
  //   _platformVersion = platformVersion;
  // }
  //


  Future<String> addText()async{
    String editedPath;
    var tempDir = await getApplicationSupportDirectory();
    final path = '${tempDir.path}/result.mp4';
    tempDir.listSync(recursive: true,followLinks: true).forEach((element){
      print(element.uri);
    });
    print(tempDir);
    try{
      final tapicoBalls = [
        TapiocaBall.filter(Filters.pink),
        TapiocaBall.textOverlay("HELLO WORLD", 100, 10, 100, Colors.redAccent),
      ];

      print(filepath);
      final cup = Cup(Content(filepath), tapicoBalls);
      cup.suckUp(path).then((_)async{
        print("Finished");
        editedPath = path;
      });
    }on PlatformException{
      print("ERROR!!!!");
      editedPath = "Error";
    }

    return editedPath;

  }


}