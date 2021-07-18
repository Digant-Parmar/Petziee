// @dart=2.9

import 'package:petziee/BackgroundTask/UploadingToDatabse.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import 'UpdateCurrentUser.dart';

class VideoUploadProgressIndicatorWidget extends StatefulWidget {
  final String filePath;
  final String postId;

  // static final GlobalKey<_VideoUploadProgressIndicatorWidgetState> videoUploadGlobalKey = GlobalKey();

  VideoUploadProgressIndicatorWidget({this.filePath, this.postId});

  @override
  _VideoUploadProgressIndicatorWidgetState createState() =>
      _VideoUploadProgressIndicatorWidgetState();
}

class _VideoUploadProgressIndicatorWidgetState
    extends State<VideoUploadProgressIndicatorWidget> {
  firebase_storage.UploadTask mainUT;
  double _progress = 0.0;
  String _processPhase = "Uploading";
  UploadingToDatabase _uploadingToDatabase;

  setCurrentUploadTask(firebase_storage.UploadTask uploadTask) {
    if (!mounted) return;
    setState(() {
      mainUT = uploadTask;
    });
  }

  setProgressState(double progress, String processPhase) {
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _processPhase = processPhase;
    });
  }

  double getCurrentProgress() {
    return _progress;
  }

  String getCurrentProcessPhase() {
    return _processPhase;
  }

  // Future<void> _processVideo()async{
  //   if(!File(widget.filePath).existsSync())return;
  //   setState(() {
  //     processPhase = "Processing video...";
  //     _progress = 0.0;
  //   });
  //   final info = await EncodingProvider.getMediaInformation(widget.filePath);
  //   final aspectRation  = EncodingProvider.getAspectRatio(info);
  //   final _videoDuration = EncodingProvider.getDuration(info);
  //   final thumbFilePath = await EncodingProvider.getThumb(widget.filePath, 300);
  //   final thumbUrl = await uploadToStorage("thumbnails",widget.postId,thumbFilePath);
  //
  //   FirebaseProvider.saveVideo(VideoInfo(
  //     thumbUrl: thumbUrl,
  //     aspectRatio: aspectRation,
  //     uploadedAt: DateTime.now(),
  //     videoName: widget.postId,
  //     duration: _videoDuration,
  //     finishedProcessing: true,
  //   ));
  //
  // }
  //
  // Future<String>uploadToStorage(String folder,String id, String uploadFilePath)async{
  //   firebase_storage.Reference _ref = firebase_storage.FirebaseStorage.instance
  //       .ref()
  //       .child(folder)
  //       .child(id);
  //
  //   firebase_storage.UploadTask uploadTask =
  //   _ref.putFile(File(uploadFilePath));
  //   mainUT = uploadTask;
  //   uploadTask.snapshotEvents.listen((event) {
  //     if (mounted)
  //       setState(() {
  //         _progress =
  //             event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
  //         print("Progress: $_progress");
  //       });
  //   });
  //   firebase_storage.TaskSnapshot taskSnapshot =
  //   await uploadTask.whenComplete(() {});
  //   String url = await taskSnapshot.ref.getDownloadURL();
  //   return url;
  // }
  //
  // void initialize() async {
  //   await _processVideo();
  //   setState(() {
  //     processPhase = "Posting...";
  //     _progress = 0.0;
  //   });
  //   String videoUrl = await uploadToStorage("videos", widget.postId, widget.filePath);
  //   await FirebaseProvider.saveDownloadUrl(widget.postId, videoUrl, currentUser.id);
  //   if (_progress == 1 && processPhase == "Posting...") {
  //     setState(() {
  //       processPhase = "Done";
  //     });
  //     Future.delayed(Duration(seconds: 2),(){
  //       HomePage.globalKey.currentState.hideSneakBar();
  //     });
  //   }
  // }

  @override
  void initState() {
    _uploadingToDatabase = UploadingToDatabase(
      getCurrentProcessPhase: getCurrentProcessPhase,
      getCurrentProgress: getCurrentProgress,
      setCurrentUploadTask: setCurrentUploadTask,
      setProgressState: setProgressState,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _uploadingToDatabase.initialize(
            postId: widget.postId,
            filePath: widget.filePath,
            currentUserId: currentUser.id));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  child: Text(
                    _processPhase,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  alignment: Alignment.topLeft,
                ),
                _processPhase != "Done"
                    ? Center(
                        child: LinearProgressIndicator(
                          value: _progress,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.grey[900],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: Center(
                child: IconButton(
                  splashRadius: 21,
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    print("Presses");
                    if (mainUT != null) {
                      mainUT.cancel();
                      HomePage.globalKey.currentState.hideSneakBar();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
