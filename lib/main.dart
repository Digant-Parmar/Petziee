// @dart=2.9

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SignIn/signupScreen.dart';
import 'colors/Themes.dart';


import 'Notification/DataNotification.dart';
import 'Notification/NotificationsBloc.dart';
import 'pages/SplashScreen.dart';
import 'widgets/phoneDatabase.dart';

//TODO: -------ADD MAP API FOR IOS AND ALSO ITS PERMISSIONS

bool ?isLoaded;
List<CameraDescription> cameras;
// const myTask = "setOffline";
// FirebaseApp defaultApp;

//Funtion to handle Notification in bacground

//Action to be done when notification is clicked
Future<void> onSelectNotification(String payload) {
  print("FCM onSelectNotification");
  return Future<void>.value();
}

//Function to parse and show notification when app is in foreground

Future<void> main() async {
  isLoaded = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // defaultApp = Firebase.app();
  try {
    cameras = await availableCameras();
    print('Cameras: $cameras ');
  } on CameraException catch (e) {
    print('Error: ${e.code} \n Message: ${e.description}');
  }
  // debugPrintGestureArenaDiagnostics = true;

  PhoneDatabase.getAppTheme().then((theme) {
    runApp(ChangeNotifierProvider(
      create: (BuildContext context) {
        if (theme == null || theme == "" || theme == "blackTheme") {
          PhoneDatabase.saveAppTheme("blackTheme");
          return ThemeNotifier(blackTheme);
        }
        return ThemeNotifier(getStringToTheme(theme));
      },
      child: MyApp(),
    ));
  });
}

// void callbackDispatcher(){
//   Workmanager.executeTask((taskName, inputData)async{
//     switch(taskName){
//       case myTask:
//         await Firebase.initializeApp();
//         // await Firebase.initializeApp();
//         print("This method was called from native!");
//         print("Inside of the offlineState");
//             print("App initialized");
//             final _usersReference = FirebaseFirestore.instance
//                 .collection("users");
//             _usersReference.doc(currentUser.id).update({
//               "isOnline": false,
//               "lastOnline": DateTime.now(),
//             });
//         // OnlineOfflineTask().setOfflineStatus();
//         break;
//       case Workmanager.iOSBackgroundTask:
//         print("IOS background fetch delegate ran");
//         break;
//     }
//     return Future.value(true);
//   });
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//
//   FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//
//   Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message)async{
//     await Firebase.initializeApp();
//
//     print("Handling a background message : ${message.data}");
//   }
//
//   configureRealTimePushNotification()async {
//     if (Platform.isIOS) {
//       getIOSPermissions();
//     }
//
//     FirebaseMessaging.instance.getInitialMessage().then((value) {
//       if(value != null){
//         print("value is ${value.data}");
//         return;
//       }
//     });
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if(message.notification !=null){
//         print("Message on Foreground: ${message.notification}");
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("From opened app ");
//     });
//
//     FirebaseMessaging.onBackgroundMessage((message) => null)
//
//     // _firebaseMessaging.setAutoInitEnabled(true);
//
//     // NotificationSettings settings = await _firebaseMessaging.requestPermission(
//     //   alert: true,
//     //   announcement: false,
//     //   badge: true,
//     //   carPlay: false,
//     //   criticalAlert: false,
//     //   provisional: false,
//     //   sound: true,
//     // );
//     // print("User granted permission: ${settings.authorizationStatus}");
//     //
//     // _firebaseMessaging.getToken().then((token) {
//     //   usersReference.doc(currentUser.id).update(
//     //       {"androidNotificationToken": token});
//     // });
//     //
//     // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //   print("Got a message whilst in the foreground!");
//     //   print("Message data: ${message.data}");
//     //
//     //
//     //   if(message.notification != null){
//     //     print("Message also contains notification: ${message.notification}");
//     //   }
//     // });
//
//     // _firebaseMessaging.(
//     //     onMessage: (Map<String, dynamic>msg) async {
//     //       final String recipientId = msg["data"]["recipient"];
//     //       final String body = msg["notification"]["body"];
//     //
//     //       if (recipientId == currentUser.id) {
//     //         SnackBar snackBar = SnackBar(
//     //           backgroundColor: Colors.grey,
//     //           content: Text(body, style: TextStyle(color: Colors.grey),
//     //             overflow: TextOverflow.ellipsis,),
//     //         );
//     //         _scaffoldKey.currentState.showSnackBar(snackBar);
//     //       }
//     //     }
//     // );
//   }
//
//   getIOSPermissions() {
//     _firebaseMessaging.requestPermission();
//   }
//

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    configureRealTimePushNotification();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  configureRealTimePushNotification() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('note');
    var initializationSettingsIos = IOSInitializationSettings();
    var initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: (value) => onSelectNotification(value));

    if (Platform.isIOS) {
      getIOSPermissions();
      _firebaseMessaging.setAutoInitEnabled(true);
    }
    _firebaseMessaging.getToken().then((token) async {
      auth.User user = auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"notificationToken": token});
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        print("value is ${value.data}");
        return;
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Message on Foreground: $message");
      }
      // if (message.notification != null) {
      //   final notification = LocalNotification("notification", message.notification as Map);
      //   NotificationBloc.instance.newNotification(notification);
      // }
      if (message.data != null) {
        final notification = LocalNotification("data", message.data);
        NotificationBloc.instance.newNotification(notification);
      }
      // if(currentPage==null)
      //   showNotification(DataNotification.fromPushMessage(message.data));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("From opened app ");
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: message.notification.title,)));
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // NotificationSettings settings = await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //
    //   provisional: false,
    //   sound: true,
    // );
    // print("User granted permission: ${settings.authorizationStatus}");

    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print("Got a message whilst in the foreground!");
    //   print("Message data: ${message.data}");
    //
    //
    //   if(message.notification != null){
    //     print("Message also contains notification: ${message.notification}");
    //   }
    // });

    // _firebaseMessaging.(
    //     onMessage: (Map<String, dynamic>msg) async {
    //       final String recipientId = msg["data"]["recipient"];
    //       final String body = msg["notification"]["body"];
    //
    //       if (recipientId == currentUser.id) {
    //         SnackBar snackBar = SnackBar(
    //           backgroundColor: Colors.grey,
    //           content: Text(body, style: TextStyle(color: Colors.grey),
    //             overflow: TextOverflow.ellipsis,),
    //         );
    //         _scaffoldKey.currentState.showSnackBar(snackBar);
    //       }
    //     }
    // );
  }

  getIOSPermissions() {
    _firebaseMessaging.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Auth Screen 1',
      theme: themeNotifier.getTheme(),
      // ThemeData(
      //   canvasColor: Colors.black,
      //   brightness: Brightness.dark,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      //   textTheme: TextTheme(
      //     headline4: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //     ),
      //     button: TextStyle(
      //         color: kPrimaryColor,
      //             fontSize: 14.0,
      //     ),
      //     headline5:TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.normal,
      //     ),
      //   ),
      //   inputDecorationTheme: InputDecorationTheme(
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(
      //         color: Colors.white.withOpacity(.2),
      //       ),
      //     ),
      //   ),
      // ),
      // home:OnStartScreen(),
      initialRoute: '/',
      routes: {
        // '/':(context)=>Buffer().onStartScreen(context),
        '/signUp': (context) => SignUp(),
        '/': (context) => SplashScree(),
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void showNotification(DataNotification notification) async {
  final AndroidNotificationDetails androidNotificationDetails =
      await getAndroidNotificationDetails(notification);
  // final IOSNotificationDetails iosNotificationDetails = await getIOSNotificationDetails();

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidNotificationDetails,
    // iOS: iosNotificationDetails,
  );

  switch (androidNotificationDetails.channelId) {
    case "Liked":
      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      break;
    case "message":
      await flutterLocalNotificationsPlugin.show(
        1,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      break;
    case "general":
      await flutterLocalNotificationsPlugin.show(
        2,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      break;
    case "Request Accept":
      await flutterLocalNotificationsPlugin.show(
        3,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      break;
    case "New Request":
      await flutterLocalNotificationsPlugin.show(
        4,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      break;
    default:
      await flutterLocalNotificationsPlugin.show(
        2,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      break;
  }
}

Future<AndroidNotificationDetails> getAndroidNotificationDetails(
    DataNotification notification) async {
  switch (notification.notificationType) {
    case NotificationType.COMMENT:
    case NotificationType.GOT_IN_TRENDING:
    case NotificationType.GOT_IN_TRENDING_LIST:
    case NotificationType.LIKED:
      return AndroidNotificationDetails(
        'Liked',
        'Liked Post',
        'Notification from post Liked',
        importance: Importance.low,
        showWhen: true,
        category: "Like",
        color: Colors.red,
        largeIcon: FilePathAndroidBitmap(
            await _downloadAndSaveFile(notification.imageUrl, 'profile')),
        // DrawableResourceAndroidBitmap('note'),
        // styleInformation: await getBigPictureStyle(notification),
        //Use these to get the custom notification
        // sound: RawResourceAndroidNotificationSound(),
      );
    case NotificationType.MAP_REQUEST_ACCEPT:
      return AndroidNotificationDetails(
        'Request Accept',
        'Request Accept',
        'Notification when request is accepted',
        importance: Importance.defaultImportance,
        showWhen: true,
        category: "Like",
        color: Colors.blueAccent,
        largeIcon: FilePathAndroidBitmap(
            await _downloadAndSaveFile(notification.imageUrl, 'profile')),
        // DrawableResourceAndroidBitmap('note'),
        // styleInformation: await getBigPictureStyle(notification),
        //Use these to get the custom notification
        // sound: RawResourceAndroidNotificationSound(),
      );
    case NotificationType.NEW_MAP_REQUEST:
      return AndroidNotificationDetails(
        'New Request',
        'New Request',
        'Notification when new request is generated',
        importance: Importance.defaultImportance,
        showWhen: true,
        category: "Like",
        color: Colors.cyanAccent,
        largeIcon: FilePathAndroidBitmap(
            await _downloadAndSaveFile(notification.imageUrl, 'profile')),
        // DrawableResourceAndroidBitmap('note'),
        // styleInformation: await getBigPictureStyle(notification),
        //Use these to get the custom notification
        // sound: RawResourceAndroidNotificationSound(),
      );
    case NotificationType.NONE:
    case NotificationType.MESSAGE:
      return AndroidNotificationDetails(
        'message',
        'Chat message',
        'Notification from chat message',
        importance: Importance.defaultImportance,
        showWhen: true,
        category: "Message",
        color: Colors.orangeAccent,
        largeIcon: FilePathAndroidBitmap(
            await _downloadAndSaveFile(notification.imageUrl, 'profile')),
        // DrawableResourceAndroidBitmap('note'),
        // styleInformation: await getBigPictureStyle(notification),
        //Use these to get the custom notification
        // sound: RawResourceAndroidNotificationSound(),
      );
    default:
      return AndroidNotificationDetails(
        'general',
        'General notification',
        'General notification that are not sorted to any specific topics.',
        importance: Importance.defaultImportance,
        showWhen: true,
        category: "General",

        largeIcon: FilePathAndroidBitmap(
            await _downloadAndSaveFile(notification.imageUrl, 'profile')),

        styleInformation: await getBigPictureStyle(notification),
        //Use these to get the custom notification
        // sound: RawResourceAndroidNotificationSound(),
      );
  }
}

// LocalNotification

Future<BigPictureStyleInformation> getBigPictureStyle(
    DataNotification notification) async {
  if (notification.imageUrl != null) {
    print("Downloading");
    final String bigPicturePath =
        await _downloadAndSaveFile(notification.imageUrl, 'bigPicture');

    return BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: notification.title,
      htmlFormatContentTitle: false,
      summaryText: notification.body,
      htmlFormatSummaryText: false,
    );
  } else {
    print("Not doenloading");
    return null;
  }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final File file = File(filePath);
  final http.Response response = await http.get(Uri.parse(url));
  await file.writeAsBytes(response.bodyBytes);
  return filePath;

  // firebase_storage.FirebaseStorage.instance.ref('ge').getData().then((value){
  //   file.writeAsBytes(value);
  // });
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("FCM backgroundMessageHandler is  ${message.data.values}");
  var initializationSettingsAndroid = AndroidInitializationSettings('note');
  var initializationSettingsIos = IOSInitializationSettings();
  var initSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIos,
  );

  showNotification(DataNotification.fromPushMessage(message.data));
  return Future<void>.value();
}
