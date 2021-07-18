// @dart=2.9

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';


class OnlineOfflineTask{

  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  final auth.User _user = auth.FirebaseAuth.instance.currentUser;
  updateUserPresence()async{
    print("Inside Here");
    Map<String,dynamic>presenceStatusTrue = {
      "isOnline":true,
      "lastOnline":DateTime.now().microsecondsSinceEpoch,
    };
    await databaseReference
          .child(_user.uid)
          .update(presenceStatusTrue)
          .whenComplete(() => print("Updated your presence"))
          .catchError((e)=>print("EEERRROOORR: $e"));

    Map<String,dynamic>presenceStatusFalse = {
      "isOnline":false,
      "lastOnline":DateTime.now().millisecondsSinceEpoch,
    };

    databaseReference.child(_user.uid).onDisconnect().update(presenceStatusFalse);

  }


  // setOnlineStatus()async{
  //   final auth.User _user = auth.FirebaseAuth.instance.currentUser;
  //   await usersReference.doc(_user.uid).update({
  //     "isOnline": true,
  //   });
  // }
  //
  // setOfflineStatus()async{
  //   print("Inside of the offlineState");
  //   final _usersReference = FirebaseFirestore.instanceFor(app: defaultApp).collection("users");
  //     _usersReference.doc(currentUser.id).update({
  //       "isOnline": false,
  //       "lastOnline":DateTime.now(),
  //     });
  // }
  }