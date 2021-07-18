// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:petziee/apis/Pagination.dart';
import 'package:petziee/widgets/FeedItemWidget.dart';
import 'package:petziee/widgets/FeedMostLikedWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import '../HomePage.dart';

// import 'package:transparent_image/transparent_image.dart';
// import 'package:path/path.dart'as p;
// import 'package:petziee/apis/encoding_provider.dart';
// import 'package:petziee/apis/firebase_provider.dart';
// import 'package:petziee/models/VideoInfo.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_ffmpeg/statistics.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_uploader/flutter_uploader.dart';

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

class FeedItems extends StatefulWidget {
  @override
  _FeedItemsState createState() => _FeedItemsState();
}

class _FeedItemsState extends State<FeedItems>
    with AutomaticKeepAliveClientMixin<FeedItems> {
  List<FeedMostLikedWidget> imageList = [];

  //
  // final thumbWidth = 300;
  // List<VideoInfo> _videos = <VideoInfo>[];
  // bool _imagePickerActive = false;
  // bool _processing = false;
  // bool _canceled = false;
  // double _progress = 0.0;
  // int _videoDuration = 0;
  // String _processPhase = '';
  // final bool _debugMode = false;
  //

  List<FeedItemWidget> feeds = [];

  FeedListBloc feedListBloc;
  bool shouldLoad = true;
  bool isLast = false;
  bool isLoading = true;
  bool _isBellowLoading = true;
  ScrollController _scrollController = ScrollController();
  // Future<void> retrieveTimeline() async {
  //   var _now = DateTime.now();
  //   var _yesterday_1 =
  //       DateTime(_now.year, _now.month, _now.day - 2, _now.hour, _now.second);
  //   if (feeds.isNotEmpty) {
  //     setState(() {
  //       feeds.clear();
  //       feeds = null;
  //     });
  //   }
  //   if (imageList.isNotEmpty) {
  //     setState(() {
  //       imageList.clear();
  //       imageList = null;
  //     });
  //   }
  //   _getMostLiked();
  //   _getCurrentUserStory();
  //   print("Feeds length is ${feeds == null}");
  //   QuerySnapshot querySnapshot = await timelineReference
  //       .doc("today")
  //       .collection("posts")
  //       .where("timestamp", isGreaterThan: _yesterday_1)
  //       .orderBy("timestamp", descending: true)
  //       .get();
  //   List<FeedItemWidget> allFeeds = querySnapshot.docs
  //       .map((document) => FeedItemWidget.fromDocument(document))
  //       .toList();
  //   setState(() {
  //     this.feeds = allFeeds;
  //     print("Feeds length is ${feeds.length}");
  //   });
  // }
  Future<void> retrieveTimeline() async {
    print("In retrieve timeline lol ");
    if (imageList.isNotEmpty) {
      setState(() {
        feedListBloc.dispose();
        imageList.clear();
        imageList = [];
        isLoading = true;
        _isBellowLoading = true;
      });
    }
    getTopList();
    getFeed();
    setState(() {
      _isBellowLoading = false;
    });
  }

  Future<List<FeedMostLikedWidget>>_getMostLiked() async {
    QuerySnapshot querySnapshot = await timelineReference
        .doc("mostLiked")
        .collection("posts")
        .orderBy("totalLikes", descending: true)
        .get();
    List<FeedMostLikedWidget> temp = querySnapshot.docs
        .map((document) => FeedMostLikedWidget.fromDocument(document,isMostLiked: true,))
        .toList();
    return temp;
  }

  Future<List<FeedMostLikedWidget>>_getCurrentUserStory() async {
    var now = DateTime.now();
    var yesterday_1 =
        DateTime(now.year, now.month, now.day - 2, now.hour, now.second);
    QuerySnapshot querySnapshot = await postReference
        .doc(currentUser.id)
        .collection("userPosts")
        .where(
          "timestamp",
          isGreaterThan: yesterday_1,
        )
        .orderBy("timestamp", descending: true)
        .get();
    List<FeedMostLikedWidget> temp1 = querySnapshot.docs
        .map((document) => FeedMostLikedWidget.fromDocument(document))
        .toList();

    return temp1;
  }
  Future<List<FeedMostLikedWidget>>_getMainUserStory()async{
    List<FeedMostLikedWidget> temp = [];
    DocumentSnapshot dox = await FirebaseFirestore.instance.collection("users").doc(currentUser.id).get();
    Timestamp time= dox.get("timestamp");
    DateTime currentTime = DateTime.now() ;
    Duration duration =currentTime.difference(DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch));
    final mainUserStoryRef = FirebaseFirestore.instance.collection("MainUserStory");

    QuerySnapshot ds = await mainUserStoryRef.doc("Stories").collection("Posts").orderBy("timestamp",descending: true).where("timestamp",isGreaterThanOrEqualTo:DateTime(currentTime.year, currentTime.month, currentTime.day-2,currentTime.hour,currentTime.minute, currentTime.second) ).limit(1).get();

    List<FeedMostLikedWidget> temp1 = ds.docs
        .map((document) => FeedMostLikedWidget.fromDocument(document,isMain: true,))
        .toList();

    if(temp1.isNotEmpty)temp.add(temp1.first);
    if(duration.inDays < 8){
      QuerySnapshot newUserDocument =await mainUserStoryRef.doc("Stories").collection("ForNewUser").orderBy("timestamp",descending: true).limit(1).get();
      List<FeedMostLikedWidget> x = newUserDocument.docs
          .map((document) => FeedMostLikedWidget.fromDocument(document,isMain: true,))
          .toList();

      if(x.isNotEmpty)temp.insert(0,x.first);
    }
    return temp;
  }


  getTopList()async{
    var result = await Future.wait([_getMostLiked(),_getMainUserStory(),_getCurrentUserStory()]);
    setState(() {
      imageList.addAll(result[0]);
      imageList.addAll(result[1]);
      imageList.addAll(result[2]);
      isLoading = false;
    });
    print("Final length bellow is :${imageList.length}");
  }

  getFeed()async{
    feedListBloc = new FeedListBloc();
    print("Feed list is ${feedListBloc.feedStream.first}");
    feedListBloc.fetchFirstList();
    setState(() {
      _isBellowLoading = false;
    });
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    feedListBloc.getShowIndicatorStream.listen((event) {
      if (!event) {
        print("Event is $event");
        setState(() {
          shouldLoad = event;
        });
      }
    });
  }

  @override
  void initState() {
    getTopList();
    getFeed();
    super.initState();
  }
  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("At the end of the list");
      feedListBloc.fetchNextFeed();
    }
  }

  // FirebasePagination firebasePagination;

  // getItems()async{
  //   List<DocumentSnapshot>documentList = await firebasePagination.fetchFirstList();
  //   List<FeedItemWidget>_temp = documentList.map((document) =>FeedItemWidget.fromDocument(document)).toList();
  //
  // }
  //
  //
  // _initialize()async{
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
  //   await FirebaseProvider.listenToVideos((List<VideoInfo> newVideos) {
  //
  //       if (newVideos[0].uploadComplete) {
  //         _saveDownloadUrl(newVideos[0]);
  //       } else if (newVideos[0].uploadUrl != null) {
  //         _processVideo(newVideos[0]);
  //       }
  //       setState(() {
  //         _videos = newVideos;
  //       });
  //   });
  //
  //   EncodingProvider.enableStatisticsCallback((Statistics stats) {
  //     if (_canceled) return;
  //
  //     setState(() {
  //       _progress = stats.time / _videoDuration;
  //     });
  //   });
  // }
  //
  //
  //
  // void _onUploadProgress(event) {
  //   if (event.type == StorageTaskEventType.progress) {
  //     final double progress =
  //         event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
  //     setState(() {
  //       _progress = progress;
  //     });
  //   }
  // }
  //
  // Future<String> _uploadFile(filePath, folderName) async {
  //   final file = new File(filePath);
  //   final basename = p.basename(filePath);
  //
  //   final StorageReference ref =
  //   FirebaseStorage.instance.ref().child(folderName).child(basename);
  //
  //   StorageUploadTask uploadTask = ref.putFile(file);
  //   uploadTask.events.listen(_onUploadProgress);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   String videoUrl = await taskSnapshot.ref.getDownloadURL();
  //   return videoUrl;
  // }
  //
  // Future<String> _uploadFileBackground(filePath, uploadUrl) async {
  //   final tag = 'upload';
  //
  //   final upload = RawUpload(
  //     url: uploadUrl,
  //     path: filePath,
  //     method: UploadMethod.PUT,
  //     tag: tag,
  //   );
  //
  //   await _uploader.enqueue(upload);
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
  // Future<void> _saveDownloadUrl(VideoInfo video) async {
  //   final StorageReference ref =
  //   FirebaseStorage.instance.ref().child('${video.videoName}.mp4');
  //
  //   String url = await ref.getDownloadURL();
  //   await FirebaseProvider.saveDownloadUrl(video.videoName, url);
  // }
  //
  // Future<void> _processVideo(VideoInfo video) async {
  //   final Directory extDir = await getApplicationDocumentsDirectory();
  //   final outDirPath = '${extDir.path}/Videos/${video.videoName}';
  //   final videosDir = new Directory(outDirPath);
  //   videosDir.createSync(recursive: true);
  //
  //   final rawVideoPath = video.rawVideoPath;
  //   if (!File(rawVideoPath).existsSync()) return;
  //   final info = await EncodingProvider.getMediaInformation(rawVideoPath);
  //   final aspectRatio = EncodingProvider.getAspectRatio(info);
  //
  //   setState(() {
  //     _processPhase = 'Generating thumbnail';
  //     _videoDuration = EncodingProvider.getDuration(info);
  //     _progress = 0.0;
  //   });
  //
  //   final thumbFilePath =
  //   await EncodingProvider.getThumb(rawVideoPath, thumbWidth);
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
  //     coverUrl: thumbUrl,
  //     aspectRatio: aspectRatio,
  //     uploadedAt: DateTime.now().millisecondsSinceEpoch,
  //     videoName: video.videoName,
  //   );
  //   await FirebaseProvider.saveVideo(videoInfo);
  //
  //   setState(() {
  //     _processPhase = 'Starting background upload task';
  //     _progress = 0.0;
  //   });
  //
  //   final uploadTask =
  //   await _uploadFileBackground(video.rawVideoPath, video.uploadUrl);
  //
  //   setState(() {
  //     _processPhase = 'Waiting for processing completed status from cloud';
  //     _progress = 0.0;
  //   });
  // }
  //
  // void _takeVideo() async {
  //
  //   String result = fileToUpload.value;
  //
  //   _imagePickerActive = false;
  //
  //   if (result == null) return;
  //
  //   setState(() {
  //     _processing = true;
  //   });
  //
  //   try {
  //     final String rand = '${new Random().nextInt(10000)}';
  //     final videoName = 'video$rand';
  //     await FirebaseProvider.createNewVideo(
  //         videoName, result);
  //   } catch (e) {
  //     print('${e.toString()}');
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

  // setTheState(){
  //   isUpload.value = false;
  //   fileToUpload.value = "";
  // }

  // createUserTimeLine(){
  //   if(feeds == null){
  //     return CircularProgressIndicator();
  //   }else{
  //     Random rn = Random();
  //     return Container(
  //         child: ListView(
  //           shrinkWrap: true,
  //           children: [
  //             // Container(
  //             //   decoration: BoxDecoration(
  //             //     color:  Colors.black,
  //             //     border: Border(
  //             //       top: BorderSide(
  //             //         color: Colors.redAccent,
  //             //       ),
  //             //       bottom: BorderSide(
  //             //         color: Colors.redAccent,
  //             //       ),
  //             //     ),
  //             //   ),
  //             //   height: 40.0,
  //             //   width: MediaQuery.of(context).size.width,
  //             //   child: Text("Hello"),
  //             // ),
  //             Container(
  //               margin: EdgeInsets.only(bottom: 12.0, top: 5.0),
  //               height: 200,
  //               child: ListView.builder(
  //                   scrollDirection: Axis.horizontal,
  //                   physics: ScrollPhysics(),
  //                   itemCount: imageList.length,
  //                   shrinkWrap: true,
  //                   itemBuilder: (context, index){
  //                     return imageList[index];
  //                     // return Container(
  //                     //   margin: EdgeInsets.only(right: 12.0,left: 2.0, bottom: 7.0),
  //                     //   height: 200,
  //                     //   width: 150,
  //                     //   decoration: BoxDecoration(
  //                     //     // boxShadow: [
  //                     //     //   BoxShadow(
  //                     //     //     offset: const Offset(3.0, 3.0),
  //                     //     //     color: Colors.grey[500],
  //                     //     //     blurRadius: 2,
  //                     //     //     spreadRadius: 1.5,
  //                     //     //   ),
  //                     //     // ],
  //                     //       color: Colors.transparent,
  //                     //       borderRadius: BorderRadius.all(Radius.circular(12))),
  //                     //   child: ClipRRect(
  //                     //     borderRadius: BorderRadius.all(Radius.circular(12)),
  //                     //     child: Image.asset(imageList[index],fit: BoxFit.fitHeight,),
  //                     //   ),
  //                     // );
  //                   }),
  //             ),
  //             Container(
  //               margin: EdgeInsets.only(right: 3.0, left: 3.0),
  //               child: new StaggeredGridView.countBuilder(
  //                   shrinkWrap: true,
  //                   scrollDirection: Axis.vertical,
  //                   physics: ScrollPhysics(),
  //                   crossAxisCount: 2,
  //                   crossAxisSpacing: 5,
  //                   mainAxisSpacing: 5,
  //                   addAutomaticKeepAlives: true,
  //                   itemCount: feeds.length,
  //                   itemBuilder: (context, index) {
  //                     return feeds[index];
  //                   },
  //                   staggeredTileBuilder: (index){
  //                     return new StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
  //                   }),
  //             ),
  //           ],
  //         ),
  //       );
  //   }
  // }

  createUserTimeLine() {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 55),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      controller: _scrollController,
      children: [
        !isLoading?Container(
          margin: EdgeInsets.only(bottom: 12.0, top: 5.0),
          height: 200,
          child: ListView(
            children: imageList,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            scrollDirection: Axis.horizontal,
          ),
        ):Center(child: CircularProgressIndicator(),),
        StreamBuilder<List<FeedItemWidget>>(
            stream: feedListBloc.feedStream,
            builder: (context, snapshot) {
              if (snapshot.data != null || snapshot.hasError) {
                if(!snapshot.hasData){
                  return Container();
                }
                return new StaggeredGridView.countBuilder(
                    padding: EdgeInsets.only(right: 3.0, left: 3.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    crossAxisCount: 2,
                    physics: ScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return snapshot.data[index];
                    },
                    staggeredTileBuilder: (index) {
                      return new StaggeredTile.count(
                          1, index.isEven ? 1.2 : 1.8);
                    });
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        isLast && shouldLoad ? Center(
          child: CircularProgressIndicator(),
        ):Container(),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child:!_isBellowLoading? createUserTimeLine():Center(child: CircularProgressIndicator(),),
      onRefresh: () => retrieveTimeline(),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}
