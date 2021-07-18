// @dart=2.9
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/Editing/VideoTrimming.dart';
import 'package:petziee/apis/firebase_provider.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tapioca/src/video_editor.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class VideoUpload extends StatefulWidget {
  final String filePath;
  final bool isChat;
  final String chatRoomId;

  final Function showSneakBar;

  VideoUpload({this.filePath, this.isChat = false, this.showSneakBar,this.chatRoomId});

  @override
  _VideoUploadState createState() => _VideoUploadState(
        isChat: isChat,
      );
}

class _VideoUploadState extends State<VideoUpload> {
  final bool isChat;

  _VideoUploadState({this.isChat});

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  String _platformVersion = 'Unknown';
  bool isLoading = false;
  String filePath;
  bool isUpdated = false;

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await VideoEditor.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get the platformVersion.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void initState() {
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    initPlatformState();
    setState(() {
      filePath = widget.filePath;
    });
    _controller = VideoPlayerController.file(File(widget.filePath));
    _initializeVideoPlayerFuture = _controller.initialize().then((value) {
      print("${_controller.value.size} is size");
      print("${_controller.value.duration} is duration");
    });
    _controller.setLooping(true);
    _controller.setVolume(1.0);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget textEditing() {
    return Container();
  }

  Widget colorEditing() {
    return Container();
  }

  //
  // addText()async{
  //   _controller.pause();
  //   _controller.dispose();
  //   var tempDir = await getApplicationSupportDirectory();
  //   final path = '${tempDir.path}/result.mp4';
  //   tempDir.listSync(recursive: true,followLinks: true).forEach((element){
  //     print(element.uri);
  //   });
  //   print(tempDir);
  //   try{
  //     final tapicoBalls = [
  //       TapiocaBall.filter(Filters.pink),
  //       TapiocaBall.textOverlay("HELLO WORLD", 100, 10, 100, Colors.redAccent),
  //     ];
  //
  //     print(filePath);
  //     final cup = Cup(Content(widget.filePath ), tapicoBalls);
  //     cup.suckUp(path).then((_)async{
  //       print("Finished");
  //       Navigator.pop(context);
  //       setState(() {
  //         filePath = path;
  //         // _controller = VideoPlayerController.file(File(path));
  //         // _initializeVideoPlayerFuture = _controller.initialize();
  //         // _controller.setLooping(true);
  //         // _controller.setVolume(1.0);
  //       });
  //     });
  //   }on PlatformException{
  //     print("ERROR!!!!");
  //   }
  // }

  Widget middleScreen() {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Container(
              color: Colors.redAccent.withOpacity(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: _controller.value.isPlaying
                  ? Icon(Icons.pause, color: Colors.transparent)
                  : Icon(
                      Icons.play_arrow_rounded,
                      size: 80,
                    ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop()),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.content_cut_outlined),
                  onPressed: () => sendToTrim()),
              IconButton(
                  icon: Icon(Icons.text_fields_outlined),
                  onPressed: () => optional()),
              IconButton(
                  icon: Icon(Icons.settings_input_svideo_rounded),
                  onPressed: () => optional()),
              IconButton(
                icon: Icon(Icons.send_rounded),
                onPressed: () => uploadAndPop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  optional() {}

  sendToTrim()async {

    _controller.pause();
    setState(() {
      isLoading = true;
    });
   await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => VideoTrimmer(
                  filePath: filePath,
                ))).then((value)async {
      if (value != null) {
        _controller.pause();
        _controller.dispose();
        setState(() {
          filePath = value;
          isUpdated = true;
          _controller = VideoPlayerController.file(File(value));
          _initializeVideoPlayerFuture = _controller.initialize();
          _controller.setLooping(true);
          _controller.setVolume(1.0);
          print("Length is ${_controller.value.duration}");
          isLoading = false;
        });
      }
    });
  }


  uploadAndPop() async {
    // int count = 0;
    // fileToUpload.value = widget.filePath;
    // isUpload.value = true;
    // Navigator.pushAndRemoveUntil(context,
    // MaterialPageRoute(builder: (BuildContext context)=>HomePage(initPage: 2)),
    // (route){return count++ == 1;});
    final String rand = Uuid().v4();
    if (!widget.isChat) {
      bool isUploading = await PhoneDatabase.getIsUploading();
      if(isUploading==null)isUploading = false;
      if (isUploading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wait for the previous post to be uploaded"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          elevation: 5,
          duration: Duration(seconds: 5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ));
        return;
      }
      await FirebaseProvider.createNewVideo('V$rand', filePath, currentUser.id);
      HomePage.globalKey.currentState.showSneakBar(forVideoUpload: true, data: [
        {
          "filePath": filePath,
          "postId": 'V$rand',
        }
      ]);
      PhoneDatabase.saveIsUploading(true);
      Navigator.pop(context);
    } else {
      var _file = File(filePath);
      int bytes = await _file.length();
      var i = (log(bytes) / log(1000)).floor();
      double mb = bytes / pow(1000, i);
      print("Size in mb $mb");
      if (mb > 30.2) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Container(
              //color: Colors.white,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), border: Border.all(width: 2.0, color: Colors.black), borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 75),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Video file size is too large. Please upload a short video.",style: TextStyle(color: Colors.white.withOpacity(0.8),),),
              ),
            ), backgroundColor: Colors.transparent, elevation: 1000, behavior: SnackBarBehavior.floating,),
        );
      } else {
       //  String tempPath = filePath;
       //  if(isUpdated){
       //   final directory = await getTemporaryDirectory();
       //  Uint8List intFile = await File(filePath).readAsBytes();
       //   final File file=await File('$directory/$rand').writeAsBytes(intFile);
       //   tempPath = file.path;
       // }
        Map<String , dynamic>chatVideo ={
          "message":null,
          "username":currentUser.username,
          "type":"video",
          "replyText":"",
          "sendBy":currentUser.username,
          "isGroup":"False",
          "isReply":"False",
          "replyName":"",
          "userId":currentUser.id,
          "time":DateTime.now().millisecondsSinceEpoch,
          "rawPath":filePath,
          "isUploading":false,
        };
        await FirebaseFirestore.instance.collection("chatRoom")
            .doc(widget.chatRoomId)
            .collection("chats")
            .add(chatVideo).catchError((e){print(e.toString());});


        print("chat Video Uploaded");
        Navigator.pop(context);

      }
    }
  }

  onBackButtonPressed() {
    print("It came Here");
    // File(widget.filePath).delete();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackButtonPressed(),
      child: Scaffold(
        body: isLoading
            ? Container()
            : FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return middleScreen();
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){
        //     setState(() {
        //       if(_controller.value.isPlaying){
        //         _controller.pause();
        //       }else{
        //         _controller.play();
        //       }
        //     });
        //   },
        //     child: Icon(
        //       _controller.value.isPlaying?Icons.pause : Icons.play_arrow
        // ),
        // ),
      ),
    );
  }
}
