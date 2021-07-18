// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String profileName;
  final String username;
  final String petUrl;
  final String humanUrl;
  final String email;
  final String bio;
  final bool isOnline;
  final int lastOnline;
  final bool isOpen;
  final Map accountType;
  final String notificationToken;

  User({
    this.id,
    this.bio,
    this.petUrl,
    this.humanUrl,
    this.username,
    this.profileName,
    this.email,
    this.isOnline,
    this.lastOnline,
    this.isOpen,
    this.accountType,
    this.notificationToken,
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id : doc.id,
      username: doc.get('username'),
      email: doc.get('email'),
      petUrl: doc.get('petUrl'),
      humanUrl: doc.get('humanUrl'),
      profileName: doc.get('profileName'),
      bio: doc.get('bio'),
      isOnline: doc.get("isOnline"),
      lastOnline: doc.get("lastOnline"),
      isOpen: doc.get("isOpen"),
      accountType: doc.get("accountType"),
      notificationToken: doc.get('notificationToken'),
    );
  }
}