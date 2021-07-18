// @dart=2.9
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Imd;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:uuid/uuid.dart';

import '../../HomePage.dart';
import 'TextFieldsWidget.dart';


class EditProfilePage extends StatefulWidget {
  final bool isSignUp;
  EditProfilePage({this.isSignUp =false});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final firebase_storage.Reference profileReference = firebase_storage.FirebaseStorage.instance.ref().child("Profile").child(currentUser.id);

  // final ImagePicker _imgPicker = ImagePicker();
  bool isPet = true;
  File file;
  bool uploading = false;
  String profileImageId = Uuid().v4();
  User _user;

  takeImage(mContext, bool pet) {
    setState(() {
      isPet = pet;
    });
    return showDialog(
      context: mContext,
      builder: (context){
        return SimpleDialog(
          title: Text(
            "Profile Photo",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                "Capture Image with Camera",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Open From Gallery",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed:pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "Remove Photo",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed:removePhoto,
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: ()=>Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  //TODO ADD COMPRESSION INSTADE OF FIXED WIDTH AND HEIGHT


  removePhoto()async{
    Navigator.pop(context);
    print("In Remove Photo");
    String path = isPet? "pet" : "human";
    // firebase_storage.UploadTask mStorageUploadTask = profileReference.child("${path}_$profileImageId").putFile(mImageFile);
    // firebase_storage.TaskSnapshot storageTaskSnapshot = await mStorageUploadTask.whenComplete(() => null);
    // String dpath =  storageTaskSnapshot.ref.fullPath;
    try{
      String link = path == 'pet'?currentUser.petUrl:currentUser.humanUrl;
      firebase_storage.Reference ref =  firebase_storage.FirebaseStorage.instance.refFromURL(link);
      print("TO be deleted ${ref.fullPath}");
      if(ref.parent.name != "defaults"){
        await ref.delete();
      }
    }catch(e){
      print("Error on delete: $e");
    }

    // final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    //   'getCircularCroppedImage',);
    //
    // dynamic resp = await callable.call(<String,dynamic>{
    //   'path': dpath,
    //   'name': profileImageId,
    // });
    // print("Resp is $resp");
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("defaults").child(path=="pet"?"dog.png":"human.png");
    String du =await ref.getDownloadURL();
    print("Download url: $du");

    saveProfileImageToFireStore(
      url: du,
    );

    updateCurrentUser();

  }


  pickImageFromGallery()async{
   Navigator.pop(context);
    final imageFile = await ImagePicker().getImage(source: ImageSource.gallery);

   File val =await ImageCropper.cropImage(
     sourcePath: imageFile.path,
     compressQuality: 70,
     cropStyle: CropStyle.circle,
     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
     compressFormat: ImageCompressFormat.png,
     androidUiSettings: AndroidUiSettings(
       toolbarColor: Colors.black,
       toolbarWidgetColor: Colors.white70,
       toolbarTitle: "Crop",
       lockAspectRatio: true,
       initAspectRatio:CropAspectRatioPreset.square,
     ),
   );

   // await getTheCircle(val);

   // // var c = Imd.copyCropCircle(Imd.decodeImage(val.readAsBytesSync()),center: Imd.Point(0,0),radius: 150);
   // //
   // // val = await  val.writeAsBytes(c.getBytes());
    setState(() {
      this.file = val;
    });

  }


  captureImageWithCamera()async{
    Navigator.pop(context);
    final imageFile = await ImagePicker().getImage(source: ImageSource.camera,);
    File val =await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      maxHeight:300,
      maxWidth: 300,

      compressQuality: 100,
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.png,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white70,
        toolbarTitle: "Crops",
      ),
    );

    var c = Imd.copyCropCircle(Imd.Image.fromBytes(300, 300, file.readAsBytesSync()),center: Imd.Point(0,0),radius: 150);

    val = await  val.writeAsBytes(c.getBytes());
    setState(() {
      this.file = val;
    });
  }

  Future<DocumentSnapshot>getUserInfo()async{
    DocumentSnapshot dox =await usersReference.doc(currentUser.id).get();
    User user = User.fromDocument(dox);
    setState(() {
      _user = user;
    });
    return dox;
  }
  createProfileTopView(){
    double size = (MediaQuery.of(context).size.width-325)/2;
    return FutureBuilder(
      future:getUserInfo(),
      builder: (context,dataSnapshot){
        //print("$currentUser is the id");
        if(!dataSnapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 15,),
              Row(
                children: [
                  SizedBox(width: size,),
                  Column(
                    children: [
                      GestureDetector(
                        //PET PROFILE IMAGE
                        onTap: ()=>takeImage(context,true),
                        child: CircleAvatar(
                          radius: 65.0,
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(user.petUrl),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "Pet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: (MediaQuery.of(context).size.width/2)-size-130,),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: ()=>takeImage(context, false),
                        child: CircleAvatar(
                          radius: 65.0,
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(user.humanUrl),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "Friend",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30.0,),
              Center(
                child: Text(
                  "Click on image to update",
                  style: TextStyle(
                    color: Colors.grey[600].withOpacity(0.6),
                    fontSize: 16
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
              SizedBox(height: 20.0,),
              TextFields(isSignIn: widget.isSignUp,),
            ],
          ),
        );
      },
    );
  }


  displayEditProfilePage(){
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if(!currentFocus.hasPrimaryFocus && currentFocus.focusedChild!=null){
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            "Edit Profile",
          ),
        ),
        body: ListView(
          children: [
            createProfileTopView(),
          ],
        ),
      ),
    );
  }

  clearPostInfo(){
    setState(() {
      file = null;
    });
  }


  compressPhoto()async{
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    Imd.Image mImageFile = Imd.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$profileImageId.jpg')
    ..writeAsBytesSync(Imd.encodeJpg(mImageFile, quality: 60));
    setState(() {
      file = compressImageFile;
    });
    print("Compression Done");
  }

  Future<String> uploadPhoto(mImageFile)async{
    print("In upload");
    String path = isPet? "pet" : "human";
    firebase_storage.UploadTask mStorageUploadTask = profileReference.child("${path}_$profileImageId").putFile(mImageFile);
    firebase_storage.TaskSnapshot storageTaskSnapshot = await mStorageUploadTask.whenComplete(() => null);
    String dpath =  storageTaskSnapshot.ref.fullPath;
   try{
     String link = path == 'pet'?currentUser.petUrl:currentUser.humanUrl;
   firebase_storage.Reference ref =  firebase_storage.FirebaseStorage.instance.refFromURL(link);
   print("TO be deleted ${ref.fullPath}");
   if(ref.parent.name != "defaults"){
     await ref.delete();
   }
   }catch(e){
      print("Error on delete: $e");
   }

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'getCircularCroppedImage',);

    dynamic resp = await callable.call(<String,dynamic>{
      'path': dpath,
      'name': profileImageId,
    });
    print("Resp is $resp");
    String downloadUrl =await profileReference.child("${path}_$profileImageId").getDownloadURL();
    print("Download url: $downloadUrl");
    return downloadUrl;
  }

  saveProfileImageToFireStore({String url}){
    if(isPet){
      usersReference.doc(currentUser.id).update({
        "petUrl" : url,
      });

      FirebaseFirestore.instance.collection("location").doc(currentUser.isOpen?"open":"close").collection("usersLocation").doc(currentUser.id).update({
        "url":url,
      });

    }else{
      usersReference.doc(currentUser.id).update({
        "humanUrl" : url
      });
    }
    updateCurrentUser();
    print("Post Saved");
  }

  controllUploadAndSave()async{
    print("In upload 0 ");
    setState(() {
      uploading = true;
    });
    // await compressPhoto();

    String downloadUrl = await uploadPhoto(file);
    saveProfileImageToFireStore(
      url: downloadUrl,
    );

    updateCurrentUser();

    if(mounted)setState(() {
      file = null;
      uploading = false;
      profileImageId = Uuid().v4();
    });


  }

  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();


  displayEditProfileImagePage(){
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
            "Profile Image",
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        actions: [
          FlatButton(onPressed: uploading? null : ()=>
              controllUploadAndSave(),
      // cropImage(),
              child: Text(
                "Update",
                style: TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
          )
        ],
      ),
      body:Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width,
            child:
            // AspectRatio(
            //   aspectRatio: 16/9,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: FileImage(file),
            //         fit: BoxFit.cover
            //       ),
            //     ),
            //   ),
            // ),
            CircleAvatar(
              backgroundImage: FileImage(file),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          uploading? Center(child: CircularProgressIndicator(),):Container(),
        ],
      ),
    );


  }

  // cropImage()async{
  //   final c = editorKey.currentState;
  //   final sccale= c.editAction.cropRect.
  //
  // }

  @override
  Widget build(BuildContext context) {
    return file == null? displayEditProfilePage() : displayEditProfileImagePage();
  }

}

// class CircleEditorCropLayerPainter extends EditorCropLayerPainter {
//   const CircleEditorCropLayerPainter();
//
//   @override
//   void paintCorners(
//       Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
//     // do nothing
//   }
//
//   @override
//   void paintMask(
//       Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
//     final Rect rect = Offset.zero & size;
//     final Rect cropRect = painter.cropRect;
//     final Color maskColor = painter.maskColor;
//     canvas.saveLayer(rect, Paint());
//     canvas.drawRect(
//         rect,
//         Paint()
//           ..style = PaintingStyle.fill
//           ..color = maskColor);
//     canvas.drawCircle(cropRect.center, cropRect.width / 2.0,
//         Paint()..blendMode = BlendMode.clear);
//     canvas.restore();
//   }
//
//   @override
//   void paintLines(
//       Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
//     final Rect cropRect = painter.cropRect;
//     if (painter.pointerDown) {
//       canvas.save();
//       canvas.clipPath(Path()..addOval(cropRect));
//       super.paintLines(canvas, size, painter);
//       canvas.restore();
//     }
//   }
// }

  // Canvas _drawCanvas(Size size, Canvas canvas,ui.Image image) {
  //   final center = Offset(size.width /2 ,size.height/2);
  //   final radius = math.min(size.width, size.height);
  //
  //   // The circle should be paint before or it will be hidden by the path
  //   Paint paintCircle = Paint()..color = Colors.black;
  //   Paint paintBorder = Paint()
  //     ..color = Colors.white
  //     ..strokeWidth = size.width / 36
  //     ..style = PaintingStyle.stroke;
  //   canvas.drawCircle(center, radius, paintCircle);
  //   // canvas.drawCircle(center, radius, paintBorder);
  //
  //   double drawImageWidth = 0;
  //   var drawImageHeight = 0.0;
  //
  //   Path path = Path()
  //     ..addOval(Rect.fromLTWH(drawImageWidth, drawImageHeight,
  //         image.width.toDouble(), image.height.toDouble()));
  //
  //   // Path path = Path()
  //   //   ..addOval(new Rect.fromCircle(center: new Offset(size.width/2, size.height/2), radius: radius))
  //   //   ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
  //   //   ..fillType = PathFillType.evenOdd;
  //
  //   canvas.clipPath(path);
  //
  //   canvas.drawImage(image, Offset(drawImageWidth, drawImageHeight), Paint());
  //   return canvas;
  // }

  // Future<File>_saveCanvas(Size size,ui.Image image,File file) async {
  //   var pictureRecorder = ui.PictureRecorder();
  //   var canvas = Canvas(pictureRecorder);
  //   var paint = Paint();
  //   paint.isAntiAlias = true;
  //   _drawCanvas(size, canvas,image);
  //   var pic = pictureRecorder.endRecording();
  //   ui.Image img = await pic.toImage(image.width, image.height);
  //   var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  //   var buffer = byteData.buffer.asUint8List();
  //
  //   // // var response = await get(imgUrl);
  //   // var documentDirectory = await getApplicationDocumentsDirectory();
  //   // File file = File('temp.png');
  //   file.writeAsBytesSync(buffer);
  //   return file;
  // }


