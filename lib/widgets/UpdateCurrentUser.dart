// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;


User currentUser;

updateCurrentUser()async{
  final auth.User user = auth.FirebaseAuth.instance.currentUser;
  DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
  if(!documentSnapshot.exists){
    print("Repeated twice");
    documentSnapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
  }
  currentUser =  User.fromDocument(documentSnapshot);
  print("Current user info is : ${currentUser.id}");
  PhoneDatabase.saveUserLoggedInSharedPreference(true);
  if(currentUser.username!=null)PhoneDatabase.saveUserNameSharedPreference(currentUser.username);
  PhoneDatabase.saveProfileNameSharedPreference(currentUser.profileName);
  PhoneDatabase.saveBioSharedPreference(currentUser.bio);
}