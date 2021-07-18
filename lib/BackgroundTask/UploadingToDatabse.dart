// @dart=2.9

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:petziee/apis/encoding_provider.dart';
import 'package:petziee/apis/firebase_provider.dart';
import 'package:petziee/models/VideoInfo.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

class UploadingToDatabase {
  final Function setCurrentUploadTask;
  final Function setProgressState;
  final Function getCurrentProgress;
  final Function getCurrentProcessPhase;

  UploadingToDatabase(
      {this.setCurrentUploadTask,
      this.setProgressState,
      this.getCurrentProgress,
      this.getCurrentProcessPhase});

  double _progress = 0.0;
  String _processPhase = "Uploading";
  String _thumbUrl;

  initialize(
      {String postId,
      String filePath,
      String currentUserId,
      bool isChat = false,
      String chatRoomId,

      }) async {
    if (!isChat) {
      PhoneDatabase.saveIsUploading(true);
      await processVideo(filePath: filePath, postId: postId);
      _progress = 0.0;
      _processPhase = "Posting...";
      setProgressState(0.0, "Posting...");
      String videoUrl = await uploadToStorage(
          folder: "videos", id: postId, uploadFilePath: filePath);
      await FirebaseProvider.saveDownloadUrl(postId, videoUrl, currentUserId);
      print("progrees: $_progress, progressPhase: $_processPhase");
        setProgressState(0.0, "Done");
        PhoneDatabase.saveIsUploading(false);
        Future.delayed(Duration(seconds: 3), () {
          HomePage.globalKey.currentState.hideSneakBar();
        });
        _processPhase = "Uploading";
        _progress = 0.0;
    } else {
      var time =DateTime.now().millisecondsSinceEpoch;

      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("chats")
          .doc(postId)
          .update({
        "isUploading": true,
        "time":time,
      });

      await processVideo(
          filePath: filePath,
          postId: postId,
          isChat: true,
          chatRoomId: chatRoomId);
      _processPhase = "Uploading...";
      setProgressState("Uploading...");
      String videoUrl = await uploadToStorage(
          folder: "Videos", id: postId, uploadFilePath: filePath, isChat: true);
      // await FirebaseProvider.saveDownloadUrl(postId, videoUrl, currentUserId);
      setProgressState("Sent");
      time =DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("chats")
          .doc(postId)
          .update({
        "replyText": videoUrl,
        "message": _thumbUrl,
        "time":time,

      });
      String otherUserId =chatRoomId.replaceAll("_", "").replaceAll(currentUser.id, "");
      await FirebaseFirestore.instance.collection("chatRoom")
          .doc(chatRoomId).update({
        "lastMessage" : "Video",
        "sendBy" : currentUser.username,
        "time" :time,
        otherUserId: false,
      });
    }
  }

  processVideo(
      {String filePath,
      String postId,
      bool isChat = false,
      String chatRoomId}) async {
    if (!File(filePath).existsSync()) return;
    if (!isChat) {
      _progress = 0.0;
      _processPhase = "Processing Video...";
      setProgressState(0.0, "Processing Video...");

      final info = await EncodingProvider.getMediaInformation(filePath);
      final aspectRation = EncodingProvider.getAspectRatio(info);
      final _videoDuration = EncodingProvider.getDuration(info);
      final thumbFilePath = await EncodingProvider.getThumb(filePath, 0);
      print("Thumb file path $thumbFilePath}");
      final thumbUrl = await uploadToStorage(
          folder: "thumbnails", id: postId, uploadFilePath: thumbFilePath);
      _thumbUrl = thumbUrl;
      FirebaseProvider.saveVideo(VideoInfo(
        thumbUrl: thumbUrl,
        aspectRatio: aspectRation,
        uploadedAt: DateTime.now(),
        videoName: postId,
        duration: _videoDuration,
        finishedProcessing: true,
      ));
    } else {
      _processPhase = "Processing Video...";
      setProgressState("Processing Video...");
      // final info = await EncodingProvider.getMediaInformation(filePath);
      // final aspectRation = EncodingProvider.getAspectRatio(info);
      // final _videoDuration = EncodingProvider.getDuration(info);
      final thumbFilePath = await EncodingProvider.getThumb(filePath, 0);
      final thumbUrl = await uploadToStorage(
          folder: "thumbnails",
          id: postId,
          uploadFilePath: thumbFilePath,
          isChat: true);
      _thumbUrl = thumbUrl;
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("chats")
          .doc(postId)
          .update({
        "replyText": thumbUrl,
      });
    }
  }

  Future<String> uploadToStorage(
      {String folder, String id, String uploadFilePath, isChat = false}) async {
    if (!isChat) {
      firebase_storage.Reference _ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(id);

      firebase_storage.UploadTask uploadTask =
          _ref.putFile(File(uploadFilePath));

      setCurrentUploadTask(uploadTask);
      uploadTask.snapshotEvents.listen((event) {
        final double progress =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        print("Progress: $progress");
        _progress = progress;
        _processPhase = "Uploading";
        setProgressState(progress, "Uploading");
      });
      firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() {});
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } else {
      firebase_storage.Reference _ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child("Chat")
          .child(folder)
          .child(id);
      firebase_storage.UploadTask uploadTask =
          _ref.putFile(File(uploadFilePath));
      // setCurrentUploadTask(uploadTask);
      firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() {});
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    }
  }
}

// class CustomKeys{
//   static final videoUploadGlobalKey = GlobalKey();
// }
