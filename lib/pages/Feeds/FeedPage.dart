// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petziee/pages/uploadPost/CameraScreen.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../icons.dart';
import '../SearchPage.dart';
import 'FeedItems.dart';

//
// FlutterUploader _uploader = FlutterUploader();
// final ValueNotifier<bool> isUpload = ValueNotifier<bool>(false);
// final ValueNotifier<String> fileToUpload = ValueNotifier<String>("");
//
//
// void backgroundHandler(){
//
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Notice these instances belong to a forked isolate.
//   var uploader = FlutterUploader();
//
//   var notifications = FlutterLocalNotificationsPlugin();
//
//   // Only show notifications for unprocessed uploads.
//   SharedPreferences.getInstance().then((preferences) {
//     var processed = preferences.getStringList('processed') ?? <String>[];
//
//     if (Platform.isAndroid) {
//       uploader.progress.listen((progress) {
//         if (processed.contains(progress.taskId)) {
//           return;
//         }
//
//         notifications.show(
//           progress.taskId.hashCode,
//           'Background Uploading',
//           'Upload in progress...',
//           NotificationDetails(
//             android:
//             AndroidNotificationDetails(
//               'FlutterUploader.Example',
//               'FlutterUploader',
//               'Installed when you activate the Flutter Uploader Example',
//               progress: progress.progress,
//               icon: 'ic_upload',
//               enableVibration: false,
//               importance: Importance.low,
//               showProgress: true,
//               onlyAlertOnce: true,
//               maxProgress: 100,
//               channelShowBadge: false,
//             ),
//             iOS:
//             IOSNotificationDetails(),
//           ),
//         );
//       });
//     }
//
//     uploader.result.listen((result) {
//       print("Running first uploader");
//       if (processed.contains(result.taskId)) {
//         return;
//       }
//
//       processed.add(result.taskId);
//       preferences.setStringList('processed', processed);
//
//       notifications.cancel(result.taskId.hashCode);
//
//       final successful = result.status == UploadTaskStatus.complete;
//
//       var title = 'Upload Complete';
//       if (result.status == UploadTaskStatus.failed) {
//         title = 'Upload Failed';
//       } else if (result.status == UploadTaskStatus.canceled) {
//         title = 'Upload Canceled';
//       }
//       // else{
//       //   FirebaseProvider.setUploadComplete( preferences.getString('currentId'));
//       //   _uploader.clearUploads();
//       // }
//
//       notifications
//           .show(
//         result.taskId.hashCode,
//         'Background Uploading',
//         title,
//         NotificationDetails(
//           android:
//           AndroidNotificationDetails(
//             'FlutterUploader.Example',
//             'FlutterUploader',
//             'Installed when you activate the Flutter Uploader Example',
//             icon: 'ic_upload',
//             enableVibration: !successful,
//             importance: result.status == UploadTaskStatus.failed
//                 ? Importance.high
//                 : Importance.min,
//           ),
//           iOS:
//           IOSNotificationDetails(
//             presentAlert: true,
//           ),
//         ),
//       )
//           .catchError((e, stack) {
//         print('error while showing notification: $e, $stack');
//       });
//     });
//   });
// }
//

class FeedPage extends StatefulWidget {
  // final String filePath;
  // final bool isUpload;
  //
  // FeedPage({this.filePath, this.isUpload});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
  }

  // _initialize()async{
  //   print("Inside initialize");
  //   await Firebase.initializeApp();
  //
  //   _uploader.setBackgroundHandler(backgroundHandler);
  //
  //   var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   var initializationSettingsAndroid =
  //   AndroidInitializationSettings('ic_upload');
  //   var initializationSettingsIOS = IOSInitializationSettings(
  //     requestSoundPermission: false,
  //     requestBadgePermission: false,
  //     requestAlertPermission: true,
  //     onDidReceiveLocalNotification:
  //         (int id, String title, String body, String payload) async {},
  //   );
  //   var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //   );
  //   // initializationSettingsAndroid, initializationSettingsIOS);
  //   flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onSelectNotification: (payload) async {},
  //   );
  //
  //   await FirebaseProvider.listenToVideos((List<VideoInfo> newVideos ) {
  //     setState(() {
  //       print("Total lenght of video is ${newVideos.length}");
  //       _videos = newVideos;
  //     });
  //     for (VideoInfo video in newVideos) {
  //       print("Video is  ${video.videoName} is uploadComplete ${video.finishedProcessing}");
  //       if(video.finishedProcessing && video.uploadComplete){
  //         continue;
  //       }
  //       if(!video.isPhoto){
  //         if (video.uploadComplete) {
  //           _saveDownloadUrl(video, "original");
  //         } else if (video.url != null) {
  //           _processVideo(video);
  //         }
  //       }
  //     }
  //   },currentUser.id);
  //
  //   EncodingProvider.enableStatisticsCallback((Statistics stats) {
  //     if (_canceled) return;
  //     setState(() {
  //       _progress = stats.time / 100000;
  //     });
  //   });
  //
  //
  // }

  //Depereicated in the new update

  // void _onUploadProgress(event) {
  //   if (event.type == firebase_storage.TaskSnapshot.progress) {
  //     final double progress =
  //         event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
  //     setState(() {
  //       _progress = progress;
  //     });
  //   }
  // }

  // Future<String> _uploadFile(filePath, folderName) async {
  //   final file = new File(filePath);
  //   final basename = p.basename(filePath);
  //
  //   final firebase_storage.Reference ref =
  //   firebase_storage.FirebaseStorage.instance.ref().child(folderName).child(basename);
  //
  //   firebase_storage.UploadTask uploadTask = ref.putFile(file);
  //   uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot){
  //     print('Snapshot state: ${snapshot.state}');
  //     final double progress = snapshot.totalBytes/snapshot.bytesTransferred;
  //     setState(() {
  //       _progress = progress;
  //     });
  //   });
  //   firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
  //   String videoUrl = await taskSnapshot.ref.getDownloadURL();
  //   return videoUrl;
  // }
  //
  // Future<String> _uploadFileBackground(filePath, url) async {
  //   final tag = 'upload';
  //
  //   final upload = RawUpload(
  //     url: url,
  //     path: filePath,
  //     method: UploadMethod.PUT,
  //     tag: tag,
  //
  //   );
  //
  //   await _uploader.enqueue(upload);
  //
  //
  // }
  //
  // String getFileExtension(String fileName) {
  //   final exploded = fileName.split('.');
  //   return exploded[exploded.length - 1];
  // }
  //
  // void _updatePlaylistUrls(File file, String videoName) {
  //   final lines = file.readAsLinesSync();
  //   var updatedLines = List<String>();
  //
  //   for (final String line in lines) {
  //     var updatedLine = line;
  //     if (line.contains('.ts') || line.contains('.m3u8')) {
  //       updatedLine = '$videoName%2F$line?alt=media';
  //     }
  //     updatedLines.add(updatedLine);
  //   }
  //   final updatedContents =
  //   updatedLines.reduce((value, element) => value + '\n' + element);
  //
  //   file.writeAsStringSync(updatedContents);
  // }
  //
  // Future<void> _saveDownloadUrl(VideoInfo video, String fromWhere) async {
  //   bool putUrlDone = false;
  //  _uploader.result.listen((result)async {
  //    print("It came inside listen");
  //    if(result.status == UploadTaskStatus.failed || result.status == UploadTaskStatus.canceled){
  //      print("Upload Failed");
  //      //TODO send notification for failed
  //      _uploader.cancel(taskId: result.taskId);
  //      return ;
  //    }else if(result.status == UploadTaskStatus.complete){
  //      final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("video").child('${video.videoName}.mp4');
  //      print("It came from $fromWhere");
  //      if(ref.fullPath.isEmpty)return;
  //      print("ref path is ${ref.fullPath}");
  //      try{
  //         if(!putUrlDone){
  //           String url = await ref.getDownloadURL();
  //           await FirebaseProvider.saveDownloadUrl(video.videoName, url, currentUser.id);
  //           putUrlDone = true;
  //         }
  //      }catch(e){
  //        print("The ref while error is ${ref.fullPath}");
  //        print(e);
  //      }
  //      return;
  //    }
  //  });
  // }
  //
  // Future<void> _processVideo(VideoInfo video) async {
  //   final Directory extDir = await getApplicationDocumentsDirectory();
  //   final outDirPath = '${extDir.path}/Videos/${video.videoName}';
  //   final videosDir = new Directory(outDirPath);
  //   videosDir.createSync(recursive: true);
  //
  //   final rawPath = video.rawPath;
  //   if (!File(rawPath).existsSync()) return;
  //   final info = await EncodingProvider.getMediaInformation(rawPath);
  //   final aspectRatio = EncodingProvider.getAspectRatio(info);
  //   final _videoDuration = EncodingProvider.getDuration(info);
  //   setState(() {
  //     _processPhase = 'Generating thumbnail';
  //
  //     _progress = 0.0;
  //   });
  //   final thumbFilePath =
  //   await EncodingProvider.getThumb(rawPath, thumbWidth);
  //
  //   final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
  //
  //   setState(() {
  //     _processPhase = 'Saving video metadata to cloud firestore';
  //     _progress = 0.0;
  //   });
  //
  //   final videoInfo = VideoInfo(
  //     thumbUrl: thumbUrl,
  //     aspectRatio: aspectRatio,
  //     uploadedAt: DateTime.now(),
  //     videoName: video.videoName,
  //     duration: _videoDuration,
  //     uploadComplete: true,
  //   );
  //   FirebaseProvider.saveVideo(videoInfo).then((value){
  //     _saveDownloadUrl(videoInfo,"processvideo");
  //   });
  //
  //   setState(() {
  //     _processPhase = 'Starting background upload task';
  //     _progress = 0.0;
  //   });
  //
  //   final uploadTask =
  //   await _uploadFileBackground(video.rawPath, video.url);
  //
  //   setState(() {
  //     _processPhase = 'Waiting for processing completed status from cloud';
  //     _progress = 0.0;
  //   });
  // }
  //
  // void _takeVideo() async {
  //
  //   print("Inside _take video");
  //   String result = fileToUpload.value;
  //
  //   _imagePickerActive = false;
  //
  //   if (result == null) return;
  //
  //   setState(() {
  //     _processing = true;
  //     fileToUpload.value = "";
  //   });
  //
  //   try {
  //     final String rand = Uuid().v4();
  //     // final videoName = 'video$rand';
  //     print("Initializing the video name $rand ");
  //     SharedPreferences.getInstance().then((value) {
  //       value.setString("currentId", rand);
  //     });
  //     await FirebaseProvider.createNewVideo(
  //         'V$rand', result, currentUser.id
  //     );
  //   } catch (e) {
  //     print('Error is ${e.toString()}');
  //   } finally {
  //     setState(() {
  //       _processing = false;
  //     });
  //   }
  // }
  //
  // _getProgressBar() {
  //   return Container(
  //     color: Colors.yellow,
  //     padding: EdgeInsets.all(30.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Container(
  //           margin: EdgeInsets.only(bottom: 30.0),
  //           child: Text(_processPhase),
  //         ),
  //         LinearProgressIndicator(
  //           value: _progress,
  //           backgroundColor: Colors.red,
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // _getListView() {
  //   return ListView.builder(
  //       padding: const EdgeInsets.all(8),
  //       itemCount: _videos.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         final video = _videos[index];
  //         return GestureDetector(
  //           onTap: () {
  //             // if (!video.finishedProcessing) return;
  //             //
  //             // Navigator.push(
  //             //   context,
  //             //   MaterialPageRoute(
  //             //     builder: (context) {
  //             //       return Player(
  //             //         video: video,
  //             //       );
  //             //     },
  //             //   ),
  //             // );
  //           },
  //           child: Card(
  //             child: Container(
  //               padding: EdgeInsets.all(10.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: <Widget>[
  //                   if (video.thumbUrl != null)
  //                     Stack(
  //                       children: <Widget>[
  //                         Container(
  //                           width: thumbWidth.toDouble(),
  //                           height: video.aspectRatio * thumbWidth.toDouble(),
  //                           child: Center(child: CircularProgressIndicator()),
  //                         ),
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           child: FadeInImage.memoryNetwork(
  //                             placeholder: kTransparentImage,
  //                             image: video.thumbUrl,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   if (!video.finishedProcessing)
  //                     Container(
  //                       margin: new EdgeInsets.only(top: 12.0),
  //                       child: Text('Processing...'),
  //                     ),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   Row(
  //                     children: <Widget>[
  //                       IconButton(
  //                         icon: Icon(Icons.delete),
  //                         onPressed: () {
  //                           FirebaseProvider.deleteVideo(video.videoName, currentUser.id);
  //                         },
  //                       ),
  //                       Text("${video.videoName}"),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }
  //
  // _getFinishingUp(){
  //   final video = _videos[0];
  //   return  Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: <Widget>[
  //       if (!video.finishedProcessing)
  //         Container(
  //           margin: new EdgeInsets.only(top: 12.0),
  //           child: Text('Processing...'),
  //         ),
  //     ],
  //   );
  // }
  //

  sendToCamera(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CameraPage(gCurrentUser: currentUser,)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          // backgroundColor: Colors.white,
          bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.red,
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.red.withOpacity(0.4),
                        Colors.black.withOpacity(0.9)
                      ])),
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(1.0),
          ),
          leading: IconButton(
            icon: Icon(CustomIcons.plus_square,
              // color: Theme.of(context).primaryColor,
            ),
            onPressed: ()=>sendToCamera()
          ),
          title: Text(
            "Trend",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24.0,
                // color: Colors.pinkAccent
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: Icon(Icons.search,
                    // color: Colors.deepOrangeAccent,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchPage(
                                isMap: false,
                              )));
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          child: Stack(
            children: [
              FeedItems(),
              // isUpload.value
              //     ? Center(child: _processing ? _getProgressBar() : _getFinishingUp())
              // : Container(),
            ],
          ),
        ),
      ),
    );


  }

// Scaffold(
// appBar: AppBar(
// title: Text("Video"),
// ),
// body: _loading
// ? Center(child: CircularProgressIndicator())
//     : Center(child: _processing ? _getProgressBar() : _getListView()),
//       floatingActionButton: FloatingActionButton(
// child: _processing
// ? CircularProgressIndicator(
// valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
// )
//     : Icon(Icons.add),
// onPressed: _takeVideo),
// ):

// backgroundUpload()async{
//
//   double percent;
//
//   Function(TransferProgress progress) progressCallBack = (progress) {
//     setState(() {
//       percent = progress.count/progress.total;
//     });
//   };
//
//   var downloadTask = DownloadTask(filePath: widget.filePath);
//   final worker = Worker(poolSize: 1);
//   await worker.handle(downloadTask, callback: progressCallBack);
//   print("Uploaded video to Storage!!!!!");
//
// }

}

// _getListView() {
//   return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: _videos.length,
//       itemBuilder: (BuildContext context, int index) {
//         final video = _videos[index];
//         return GestureDetector(
//           onTap: () {
//             // if (!video.finishedProcessing) return;
//             //
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //     builder: (context) {
//             //       return Player(
//             //         video: video,
//             //       );
//             //     },
//             //   ),
//             // );
//           },
//           child: Card(
//             child: Container(
//               padding: EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   if (video.thumbUrl != null)
//                     Stack(
//                       children: <Widget>[
//                         Container(
//                           width: thumbWidth.toDouble(),
//                           height: video.aspectRatio * thumbWidth.toDouble(),
//                           child: Center(child: CircularProgressIndicator()),
//                         ),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8.0),
//                           child: FadeInImage.memoryNetwork(
//                             placeholder: kTransparentImage,
//                             image: video.thumbUrl,
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (!video.finishedProcessing)
//                     Container(
//                       margin: new EdgeInsets.only(top: 12.0),
//                       child: Text('Processing...'),
//                     ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () {
//                           FirebaseProvider.deleteVideo(video.videoName);
//                         },
//                       ),
//                       Text("${video.videoName}"),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       });
// }
