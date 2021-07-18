// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/BackgroundTask/onlineOfflineTask.dart';
import 'package:petziee/Notification/NotificationsBloc.dart';
import 'package:petziee/UploadingWidget/UploadProgressIndicator.dart';
import 'package:petziee/icons.dart';
import 'package:petziee/pages/Map/MapPage.dart';
import 'package:petziee/pages/Overview/OverviewPage.dart';
import 'package:petziee/pages/Profile/ProfilePage.dart';
import 'package:petziee/pages/Profile/SideMenuOptions/EditProfilePage.dart';
import 'package:petziee/pages/chat/ChatScreen.dart';
import 'package:petziee/pages/uploadPost/CameraScreen.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../config.dart';
import 'file:///C:/Users/digan/AndroidStudioProjects/petziee/lib/pages/Feeds/FeedPage.dart';

import '../colors/Themes.dart';

//TODO Implemet imageloading vuilder
final DateTime timestamp = DateTime.now();
final usersReference = FirebaseFirestore.instance.collection("users");
final firebase_storage.Reference postStorageReference =
    firebase_storage.FirebaseStorage.instance.ref().child("Post Picture");

final postReference = FirebaseFirestore.instance.collection("posts");
final pawsReference = FirebaseFirestore.instance.collection("paws");
final tailsReference = FirebaseFirestore.instance.collection("tails");

final timelineReference = FirebaseFirestore.instance.collection("timeline");

class HomePage extends StatefulWidget {
  final int initPage;
  static final GlobalKey<_HomePageState> globalKey = GlobalKey();

  HomePage({
    this.initPage = 2,
  }) : super(key: globalKey);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> // with WidgetsBindingObserver
{
  PreloadPageController _pageController;
  OnlineOfflineTask database = OnlineOfflineTask();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedPage = 2;

  Timer timer;

  bool isNotify = false;
  bool isMapNotify = false;

  void hideSneakBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void retrieveUploadingPosts() async {
    List<Map<String, String>> uploadList = [];

    await postReference
        .doc(currentUser.id)
        .collection("userPosts")
        .where("uploadComplete", isEqualTo: false)
        .where("isPhoto", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.get("rawPath") != null) {
          File(element.get("rawPath")).exists().then((value) {
            if (value) {
              uploadList.add({
                "filePath": element.get("rawPath"),
                "postId": element.get("postId"),
              });
            }
          });
        }
      });
    });

    if (uploadList.isNotEmpty) {
      showSneakBar(forVideoUpload: true, data: uploadList);
    }else{
      PhoneDatabase.saveIsUploading(false);
    }
  }

  void showSneakBar(
      {bool forVideoUpload = false,
      bool test = false,
      List<Map<String, String>> data}) async {
    if (forVideoUpload) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: UploadProgressIndicator(uploadPostList: data),
          duration: Duration(days: 1),
          margin: EdgeInsets.only(bottom: 47, left: 8, right: 8),
          backgroundColor: Colors.grey[900].withOpacity(0.2),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.only(left: 10, right: 14, top: 1, bottom: 1),
        ),
      );
    }
    if (test) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: UploadProgressIndicator(uploadPostList: [
            {
              "filePath": "",
              "postId": "",
            }
          ]),
          duration: Duration(days: 1),
          backgroundColor: Colors.grey[900].withOpacity(0.2),
          margin: EdgeInsets.only(bottom: 47, left: 8, right: 8),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.only(left: 10, right: 14, top: 1, bottom: 1),
        ),
      );
    }
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PreloadPageView(
            onPageChanged: _pageChange,
            preloadPagesCount: 0,
            children: [
              MapPage(),
              ChatPage(),
              FeedPage(),
              OverviewPage(),
              // CameraPage(
              //   gCurrentUser: currentUser,
              // ),
              ProfilePage(userProfileId: currentUser.id),
            ],
            controller: _pageController,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 8, right: 8),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: selectedPage == 0
                          ? Icon(
                              Icons.my_location,
                              color: Colors.red,
                              size: 37.0,
                            )
                          : Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.location_searching,
                                    color: NInactive,
                                  ),
                                ),
                                isMapNotify
                                    ? Positioned(
                                        top: 0.0,
                                        right: 0.0,
                                        child: new Icon(
                                          Icons.brightness_1,
                                          size: 8.0,
                                          color: Colors.redAccent,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                      onPressed: () => onItemTapped(0),
                    ),
                    IconButton(
                      icon: selectedPage == 1
                          ? Icon(
                              Icons.chat_rounded,
                              color: Colors.greenAccent,
                              size: 35.0,
                            )
                          : Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: NInactive,
                                ),
                              ),
                              isNotify
                                  ? Positioned(
                                      top: 0.0,
                                      right: 0.0,
                                      child: new Icon(
                                        Icons.brightness_1,
                                        size: 8.0,
                                        color: Colors.redAccent,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                      onPressed: () => onItemTapped(1),
                    ),
                    IconButton(
                      icon: selectedPage == 2
                          ? Icon(
                              CustomIcons.paw,
                              color: NActive,
                              size: 32.0,
                            )
                          : Icon(
                              CustomIcons.house_outline,
                              size: 27,
                              color: NInactive,
                            ),
                      onPressed: () => onItemTapped(2),
                    ),
                    IconButton(
                      icon: selectedPage == 3
                          ? Icon(
                              Icons.workspaces_outline,
                              color: Colors.yellowAccent.withOpacity(0.8),
                              size: 35.0,
                            )
                          : Icon(
                              CustomIcons.plus_square,
                              size: 22,
                              color: NInactive,
                            ),
                      onPressed: () => onItemTapped(3),
                    ),
                    IconButton(
                      icon: selectedPage == 4
                          ? Icon(
                              Icons.person,
                              color: Colors.lightBlueAccent,
                              size: 37.0,
                            )
                          : Icon(
                              Icons.person_outline,
                              color: NInactive,
                            ),
                      onPressed: () => onItemTapped(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: CupertinoTabBar(
      //   backgroundColor: Colors.transparent,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: selectedPage == 0
      //           ? Icon(
      //         Icons.my_location,
      //         color: Colors.red,
      //         size: 37.0,
      //       )
      //           : Icon(
      //         Icons.location_searching,
      //       ),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: selectedPage == 1
      //           ? Icon(
      //               Icons.chat,
      //               color: Colors.cyanAccent,
      //               size: 35.0,
      //             )
      //           : Icon(Icons.chat_bubble_outline),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: selectedPage == 2
      //           ? Icon(
      //         Icons.home,
      //         color: NActive,
      //         size: 35.0,
      //       )
      //           : Icon(Icons.home),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: selectedPage == 3
      //           ? Icon(
      //               Icons.add_box,
      //               color: Colors.yellowAccent,
      //               size: 35.0,
      //             )
      //           : Icon(Icons.add_box),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: selectedPage == 4
      //           ? Icon(
      //               Icons.person,
      //               color: Colors.greenAccent,
      //               size: 37.0,
      //             )
      //           : Icon(Icons.person_outline),
      //     ),
      //   ],
      //   currentIndex: selectedPage,
      //   onTap: onItemTapped,
      //   inactiveColor: NInactive.withOpacity(0.7),
      // ),
    );
  }

  Stream<LocalNotification> _notificationStream;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    database.updateUserPresence();
    // Workmanager.initialize(callbackDispatcher,isInDebugMode: true);
    getInfo();
    // timer = Timer.periodic(Duration(minutes: 1), (_) => setState((){}));
    selectedPage = widget.initPage;
    _pageController = new PreloadPageController(initialPage: widget.initPage);
    print("Current user $currentUser");
    _notificationStream = NotificationBloc.instance.notificationStream;
    _notificationStream.listen((notification) {
      print("type is ${notification.data['notificationType']}");
      if (notification.data['notificationType'] == 'MESSAGE') {
        setState(() {
          isNotify = true;
        });
      }

      print("Is Notify: $isNotify");
      print("Notification : $notification");
    });


    super.initState();
    //Added this for State notification for the online and offline status
    // WidgetsBinding.instance.addObserver(this);
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if(state==AppLifecycleState.inactive){
  //     print("Inside inactive");
  //      Workmanager.registerOneOffTask(
  //      "1",
  //      "setOffline",
  //      // initialDelay: Duration(seconds: 10),
  //      constraints: Constraints(
  //        networkType: NetworkType.connected,
  //      ),
  //    );
  //   }
  //   super.didChangeAppLifecycleState(state);
  // }

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
  //   var downloadTask = UploadVideo(filePath: widget.filePath);
  //   final worker = Worker(poolSize: 1);
  //   await worker.handle(downloadTask, callback: progressCallBack);
  //   print("Uploaded video to Storage!!!!!");
  //
  // }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  void onItemTapped(int index) {
    selectedPage = index;
    _pageController.jumpToPage(index);
  }

  void _pageChange(int index) {
    print("This is page index ${index.toDouble()}");
    selectedPage = index;
    setState(() {
      // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      if (isNotify) {
        isNotify = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    print(deviceSize);
    if (currentUser != null) {
      return buildHomeScreen();
    } else {
      return Center(child: Lottie.asset("json_files/initLoader.json",repeat: true,alignment: Alignment.center,fit: BoxFit.contain));
    }
  }

  getInfo() async {
    await updateCurrentUser();
    // OnlineOfflineTask().setOnlineStatus();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => retrieveUploadingPosts());
    if(currentUser.username == null || currentUser.username.replaceAll(" ", "")==""){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>EditProfilePage(isSignUp: true,)));
    }
    setState(() {});
  }

  Future onSelectNotification(String payload) {}

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// void showNotification(DataNotification notification)async{
//   final AndroidNotificationDetails androidNotificationDetails = await getAndroidNotificationDetails(notification);
//   // final IOSNotificationDetails iosNotificationDetails = await getIOSNotificationDetails();
//
//   final NotificationDetails platformChannelSpecifics = NotificationDetails(
//     android: androidNotificationDetails,
//     // iOS: iosNotificationDetails,
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     Text(notification.title,style: TextStyle(fontSize: 10),).data,
//     notification.body,
//     platformChannelSpecifics,
//
//   );
// }
//
// Future<AndroidNotificationDetails>  getAndroidNotificationDetails(DataNotification notification)async{
//   switch(notification.notificationType){
//     case NotificationType.COMMENT:
//       return AndroidNotificationDetails(
//         'general',
//         'General notification',
//         'General notification that are not sorted to any specific topics.',
//         importance: Importance.defaultImportance,
//         showWhen: true,
//         category: "General",
//         largeIcon: FilePathAndroidBitmap(await _downloadAndSaveFile(notification.imageUrl, 'profile')),
//         color: Colors.lightBlueAccent,
//         styleInformation: await getBigPictureStyle(notification),
//         tag: 'general',
//         //Use these to get the custom notification
//         // sound: RawResourceAndroidNotificationSound(),
//       );
//     case NotificationType.GOT_IN_TRENDING:
//     case NotificationType.GOT_IN_TRENDING_LIST:
//     case NotificationType.LIKED:
//     case NotificationType.MAP_REQUEST_ACCEPT:
//     case NotificationType.NEW_MAP_REQUEST:
//     case NotificationType.NONE:
//     case NotificationType.MESSAGE:
//       return AndroidNotificationDetails(
//         'message',
//         'Chat message',
//         'Notification from chat message',
//         tag: 'Message',
//         importance: Importance.defaultImportance,
//         showWhen: true,
//         color: Colors.orangeAccent,
//         category: "Message",
//         largeIcon: FilePathAndroidBitmap(await _downloadAndSaveFile(notification.imageUrl, 'profile')),
//         // DrawableResourceAndroidBitmap('note'),
//         // styleInformation: await getBigPictureStyle(notification),
//         //Use these to get the custom notification
//         // sound: RawResourceAndroidNotificationSound(),
//       );
//     default:
//       return AndroidNotificationDetails(
//         'general',
//         'General notification',
//         'General notification that are not sorted to any specific topics.',
//         importance: Importance.defaultImportance,
//         showWhen: true,
//         category: "General",
//
//         largeIcon: FilePathAndroidBitmap(await _downloadAndSaveFile(notification.imageUrl, 'profile')),
//
//         styleInformation: await getBigPictureStyle(notification),
//         //Use these to get the custom notification
//         // sound: RawResourceAndroidNotificationSound(),
//       );
//   }
// }
//
// // LocalNotification
//
// Future<BigPictureStyleInformation> getBigPictureStyle(DataNotification notification)async{
//   if(notification.imageUrl!=null){
//     print("Downloading");
//     final String bigPicturePath = await _downloadAndSaveFile(notification.imageUrl,'bigPicture');
//
//     return BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
//       hideExpandedLargeIcon: true,
//       contentTitle: notification.title,
//       htmlFormatContentTitle: false,
//       summaryText: notification.body,
//       htmlFormatSummaryText: false,
//
//     );
//   }else{
//     print("Not doenloading");
//     return null;
//   }
// }
//
// Future<String>_downloadAndSaveFile(String url, String fileName)async{
//   final Directory directory = await getApplicationDocumentsDirectory();
//   final String filePath = '${directory.path}/$fileName';
//   final File file = File(filePath);
//   final http.Response response = await http.get(Uri.parse(url));
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
//
//   // firebase_storage.FirebaseStorage.instance.ref('ge').getData().then((value){
//   //   file.writeAsBytes(value);
//   // });
//
// }

}
