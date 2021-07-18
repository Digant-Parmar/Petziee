// @dart=2.9

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class ImageUpload extends StatefulWidget {

  final String filePath;
  final User gCurrentUser;
  final bool isChat;
  final String chatRoomId;
  final bool isTaken;

  ImageUpload({this.filePath, this.gCurrentUser, this.isChat, this.chatRoomId,this.isTaken = false});

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {




  bool first = true;
  File file;
  bool uploading = false;
  String postid = Uuid().v4();
  TextEditingController descriptionTextEditingController ;
  TextEditingController locationTextEditingController;

  initState(){
    super.initState();
    descriptionTextEditingController = TextEditingController();
    locationTextEditingController = TextEditingController();

  }

  clearPostInfo(){
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      first = true;
    });
    Navigator.of(context).pop();
  }

  compressPhoto()async{
    final tD = await getTemporaryDirectory();
    final path = tD.path;
    Img.Image mImageFile = Img.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$postid.jpg')
    ..writeAsBytesSync(Img.encodeJpg(mImageFile, quality: 80));
    setState(() {
      file= compressImageFile;
    });
    print("Compression done");
  }

  Future<String> uploadPhoto(mImageFile)async{
    final firebase_storage.Reference chatPhotoStorageReference =
    firebase_storage.FirebaseStorage.instance.ref().child("Chat").child("Photos");

    firebase_storage.UploadTask mStorageUploadTask = widget.isChat
        ?chatPhotoStorageReference.child("chat_$postid.jpg").putFile(mImageFile)
        :postStorageReference.child("post_$postid.jpg").putFile(mImageFile);
    firebase_storage.TaskSnapshot storageTaskSnapshot = await mStorageUploadTask.whenComplete(() => null);
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  controlUploadAndSave()async{
    setState(() {
      uploading = true;
    });
    // await compressPhoto();
    var temp = await decodeImageFromList(File(widget.filePath).readAsBytesSync());
    // final data = File(widget.filePath).readAsBytesSync();
    // final image = Img.decodeImage(data.toList());
    // if(image!=null){
    //   final blurHash = BlurHash.encode(image, numCompX: 4, numCompY: 3);
    //   print(blurHash.hash);
    //   replyText = blurHash.hash;
    // }else{
    //   final data = File('path/to/image.png').readAsBytesSync();
    //   final image = Img.decodeImage(data.toList());
    //   final blurHash = BlurHash.encode(image, numCompX: 4, numCompY: 3);
    //   print(blurHash.hash);
    //   replyText = blurHash.hash;
    // }
    String downloadUrl = await uploadPhoto(file);
    widget.isChat
        ?saveChatInfoToFireStore(
      url: downloadUrl,
    )
        :savePostInfoToFireStore(
      url: downloadUrl,
      location: locationTextEditingController.text,
      description: descriptionTextEditingController.text,
    );
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    if(widget.isTaken) await File(widget.filePath).delete();
    if(!widget.isChat){
      await deleteFiles();
    }

    setState(() {
      uploading = false;
      postid = Uuid().v4();
      int count = 0;
      Navigator.popUntil(context, (route){
        return count++ == 2;
      });
    });


  }

  Future<void>deleteFiles()async{
    Directory d = await getApplicationDocumentsDirectory();
    String path = d.path;

    try{
      int i = await PhoneDatabase.getDrawingImageCounter();
     for(int j = 0; j<i;j++){
       var file  = File('$path/DrawingImage$j');
       print("Deleting $path/DrawingImage$j");
       await file.delete();
     }
    } catch(e){
      print("Error deleting Files : $e");
    }
  }


  saveChatInfoToFireStore({String url})async{
    var time =DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> chatImage = {
      "message" : url,
      // "username" : currentUser.username,
      "time":time,
      "type" : "image",
      "replyText":"",
      // "sendBy" : currentUser.username,
      "isGroup" : "False",
      "isReply" :  "False",
      "replyName":"",
      "userId":currentUser.id,
    };

    await FirebaseFirestore.instance.collection("chatRoom")
    .doc(widget.chatRoomId)
    .collection("chats")
    .add(chatImage).catchError((e){print(e.toString());});
    String otherUserId =widget.chatRoomId.replaceAll("_", "").replaceAll(currentUser.id, "");

    FirebaseFirestore.instance.collection("chatRoom")
    .doc(widget.chatRoomId).update({
      "lastMessage" : "Photo",
      "sendBy" : currentUser.username,
      "time" : time,
      otherUserId:false,
    });

    print("chat Image Uploaded");
  }

  savePostInfoToFireStore({String url, String location, String description}){
    print("Url is $url");
      postReference
      .doc(currentUser.id)
          .collection("userPosts")
          .doc(postid)
          .set({
        "finishedProcessing":true,
        "postId" : postid,
        "ownerId" : currentUser.id,
        "timestamp" : DateTime.now(),
        "totalViews": 0,
        "totalLikes": 0,
        "duration":'7.0',
        "username" : currentUser.username,
        "description" : description,
        "location" : location,
        "url" : url,
        "isPhoto": true,
        "rawPath": file.path,
        "thumbUrl":url,
        "uploadComplete":true,
      });
      print("Post saved");
  }


  getUserCurrentLocation()async{
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMark = await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark mPlaceMark = placeMark[0];
    // Complete Address
    // String completeAddress = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country}';

    String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;

  }
  
  displayPostUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: clearPostInfo,
        ),
        title: Center(
            child: Text(
              "New Post",
              style: TextStyle(
                  fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
            )),
        actions: <Widget>[
          // FlatButton(
          //   onPressed: uploading ? null : () => controlUploadAndSave(),
          //   child: Text(
          //     "Share",
          //     style: TextStyle(
          //         color: Colors.lightGreenAccent,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16.0),
          //   ),
          // )
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? LinearProgressIndicator() : Text(""),
          Container(
            height: MediaQuery.of(context).size.height/1.8,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: FileImage(file).scale,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(file), fit: BoxFit.contain)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          // ListTile(
          //   leading: CircleAvatar(
          //     backgroundImage: CachedNetworkImageProvider( currentUser.humanUrl),
          //   ),
          //   title: Container(
          //     width: 250.0,
          //     child: TextField(
          //       style: TextStyle(color: Colors.white),
          //       controller: descriptionTextEditingController,
          //       decoration: InputDecoration(
          //         hintText: "Say Something About image",
          //         hintStyle: TextStyle(color: Colors.white),
          //         border: InputBorder.none,
          //       ),
          //     ),
          //   ),
          // ),
          Divider(),
          // ListTile(
          //   leading: Icon(
          //     Icons.person_pin_circle,
          //     color: Colors.white,
          //     size: 36.0,
          //   ),
          //   title: Container(
          //     width: 250.0,
          //     child: TextField(
          //       style: TextStyle(color: Colors.white),
          //       controller: locationTextEditingController,
          //       decoration: InputDecoration(
          //         hintText: "Write the location",
          //         hintStyle: TextStyle(color: Colors.white),
          //         border: InputBorder.none,
          //       ),
          //     ),
          //   ),
          // ),
          // Container(
          //   width: 220.0,
          //   height: 110.0,
          //   alignment: Alignment.center,
          //   child: RaisedButton.icon(
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(35.0)),
          //     color: Colors.green,
          //     icon: Icon(
          //       Icons.location_on,
          //       color: Colors.white,
          //     ),
          //     label: Text(
          //       "Get my Current Location",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     onPressed: getUserCurrentLocation,
          //   ),
          // ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child: ButtonTheme(
              minWidth: 110,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: Colors.white,)
                ),
                color: Colors.transparent,
                child: Text(
                  "Share",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed:uploading ? null : () => controlUploadAndSave(),
              ),
            ),
          ),
          // FlatButton(
          //   onPressed: uploading ? null : () => controlUploadAndSave(),
          //   child: Text(
          //     "Share",
          //     style: TextStyle(
          //         color: Colors.lightGreenAccent,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16.0),
          //   ),
          // )
        ],
      ),
    );
  }


  displayChatUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Image Screen"),
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            child: Image.file(File(widget.filePath),),
          ),
          GestureDetector(
            onTap:  uploading ? null : () => controlUploadAndSave(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Align(alignment: Alignment.center,child: Icon(Icons.send_rounded, color: Colors.white,))
                  )

              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if(first){
       file = File(widget.filePath);
       first = false;
    }
    
    return widget.isChat? displayChatUploadFormScreen():displayPostUploadFormScreen();

  }

  goBack() {
    Navigator.pop(context);
  }
}
