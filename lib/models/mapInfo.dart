// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapInfo{
  final String id;
  final GeoPoint currentLocation;
  final bool liveLocation;
  final String url;
  final String username;
  final String profileName;
  final bool isOpen;
  final Map accountType;
  final String iconId;
  final BitmapDescriptor icon;


  MapInfo({
    this.id,
    this.currentLocation,
    this.liveLocation,
    this.url,
    this.profileName,
    this.username,
    this.accountType,
    this.isOpen,
    this.iconId,
    this.icon,
  });

  factory MapInfo.fromDocument(
      {DocumentSnapshot doc,@required BitmapDescriptor icon}){
      return MapInfo(
        id : doc.id,
        currentLocation: doc.get("currentLocation"),
        liveLocation: doc.get('liveLocation'),
        url: doc.get('url'),
        profileName: doc.get('profileName'),
        username: doc.get('username'),
        accountType: doc.get("accountType"),
        isOpen: doc.get("isOpen"),
        iconId: doc.get('iconId'),
        icon : icon,
      );
  }
}