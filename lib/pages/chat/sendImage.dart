// @dart=2.9

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:petziee/UploadingWidget/ImageUpload.dart';
import 'package:petziee/UploadingWidget/VideoUpload.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

class SendImage extends StatefulWidget {
  final List<PlatformFile> file;
  final String fileType;
  final String chatRoomId;

  SendImage({this.file, this.fileType, this.chatRoomId});

  @override
  _SendImageState createState() => _SendImageState(
    file: file,
        fileType:fileType,
  );
}

class _SendImageState extends State<SendImage> {
  final List<PlatformFile> file;
  final String fileType;
  _SendImageState({this.file, this.fileType});

  send(){
     ImageUpload(filePath: file[0].path,isChat: true,chatRoomId: widget.chatRoomId,gCurrentUser: currentUser,);
  }

  Widget imageView(){
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints.expand(),
          child: Image.file(File(file[0].path),),
        ),
        GestureDetector(
          onTap: (){},
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
    );
  }

    @override
  Widget build(BuildContext context) {
    return fileType=='image'?send():VideoUpload(filePath: file[0].path,);
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      result ? print("Files Removed Succsefflut") : print(
          "Failed to remove the files");
    });
  }

  @override
  void dispose() {
   _clearCachedFiles();
    super.dispose();
  }
}
