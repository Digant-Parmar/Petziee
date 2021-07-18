// @dart=2.9

import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petziee/UploadingWidget/ImageUpload.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

import 'DrawingWidget.dart';

class EditImage extends StatefulWidget {

  final String filePath;
  final User gCurrentUser;
  final bool isTaken;
  EditImage({this.filePath, this.gCurrentUser,this.isTaken=false});


  @override
  _EditImageState createState() => _EditImageState();
}


class _EditImageState extends State<EditImage> {


  String filePath ;
  String dFilePath;
  Canvas canvas;

  getData()async{
    getApplicationDocumentsDirectory().then((value){
      setState(() {
        dFilePath = value.path;
      });
    });



  }


  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    getData();
    setState(() {
      filePath = widget.filePath;
    });

    super.initState();
  }

  updateFile()async{
    PhoneDatabase.getDrawingImageCounter().then((i){
      setState(() {
        filePath = '$dFilePath/DrawingImage$i';
      });
    });
  }
  goToDrawingWidget()async{
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => DrawingWidget(filePath: filePath,),
        transitionDuration: Duration(seconds: 0),
      ),
    ).then((value){
      setState(() {
        filePath = value;
      });
    });
  }

  Widget initWidget(){
    return SafeArea(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            color: Colors.transparent,
            child: Image(image: FileImage(File(filePath)),fit: BoxFit.cover,alignment: Alignment.center,),
          ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(child: Icon(Icons.edit_outlined, color: Colors.white,size: 30,), onTap: (){
            goToDrawingWidget();
          }),
          // SizedBox(width: 14,),
          // GestureDetector(child: Icon(Icons.text_fields, color: Colors.white,size: 30,), onTap: (){
          //   setState(() {
          //   });
          // },),
          SizedBox(width:14,),
          GestureDetector(child: Icon(Icons.close, color: Colors.white,size: 30,),onTap: ()=>getOut(),),
        ],
      ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: (){
                print("On Tapped");
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageUpload(filePath: filePath,gCurrentUser: widget.gCurrentUser,isChat: false,isTaken:widget.isTaken)));
              },
                child: Container(
                  padding: EdgeInsets.all(13),
                  margin: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Icon(Icons.send_rounded, color: Colors.white,size: 30,),
                ),
            ),
          ),
        ],
      ),
    );


  }

  getOut()async{
    await File(widget.filePath).delete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return initWidget();
  }
}

