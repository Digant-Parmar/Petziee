// @dart=2.9

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:petziee/models/mapInfo.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/pages/Map/MapPage.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';


final locationReference = FirebaseFirestore.instance
    .collection("location");

class GoogleMapProvider {
  static Future<List<MapInfo>> getOpenLocation() async {
    List<MapInfo> infoList = [];
    await locationReference
        .doc("open")
        .collection("usersLocation")
        .where("isOpen",isEqualTo: true)
        .get()
        .then((value)async {
          for(DocumentSnapshot element in value.docs){
            print("Element id is ${element.id}");
            final Uint8List _tempList= await createMapIcon(iconId: element.get("iconId"));
            infoList.add(MapInfo.fromDocument(doc: element,icon: BitmapDescriptor.fromBytes(_tempList)));
          }
    });
    return infoList;
  }

  static Future<List<MapInfo>>getPawsLocation()async{
    List<MapInfo> _infoList = [];
    QuerySnapshot _snapshot=  await pawsReference.doc(currentUser.id).collection("userPaws").where(FieldPath.documentId,isNotEqualTo: currentUser.id).get();
     for(DocumentSnapshot documentSnapshot in _snapshot.docs){
       MapInfo _temp = await getSpecificUserLocation(documentSnapshot.id);
       _infoList.add(_temp);
     }
     return _infoList;
  }

   static getAllLocation()async{
    Set<MapInfo> _allLocationList = {};
    try{
      List response = await Future.wait([getOpenLocation(),getPawsLocation(),]);
      List<MapInfo>_temp0= response[0];
      List<MapInfo>_temp1= response[1];
      // print("All location list length ${_temp0.length} and ${_temp1.length}");
      _allLocationList.addAll(_temp0.toSet());
      // print("All location list length ${_allLocationList.length}");
      _allLocationList.addAll(_temp1.toSet());
      // print("All location list length ${_allLocationList.length}");
      return _allLocationList.toList();
    }catch(e){
      print(e);
      return null;
    }
  }

  static getPetTrainerLocation()async{
    List<MapInfo> _infoList = [];
    await locationReference.doc("open").collection("usersLocation").where("accountType.Pet Trainer",isEqualTo: true).where("isOpen",isEqualTo: true).get().then((value)async{
      for(DocumentSnapshot element in value.docs){
        final Uint8List _tempList= await createMapIcon(iconId: element.get("iconId"));
        _infoList.add(MapInfo.fromDocument(doc: element,icon: BitmapDescriptor.fromBytes(_tempList)));
      }
    });
    return _infoList;
  }

  static getPetShopLocation()async{
    List<MapInfo> _infoList = [];
    await locationReference.doc("open").collection("usersLocation").where("accountType.Pet Shop",isEqualTo: true).where("isOpen",isEqualTo: true).get().then((value)async{
      for(DocumentSnapshot element in value.docs){
        final Uint8List _tempList= await createMapIcon(iconId: element.get("iconId"));
        _infoList.add(MapInfo.fromDocument(doc: element,icon: BitmapDescriptor.fromBytes(_tempList)));
      }
    });
    return _infoList;
  }

  static getVetLocation()async{
    List<MapInfo> _infoList = [];
    await locationReference.doc("open").collection("usersLocation").where("accountType.Vet",isEqualTo: true).where("isOpen",isEqualTo: true).get().then((value)async{
      for(DocumentSnapshot element in value.docs){
        final Uint8List _tempList= await createMapIcon(iconId: element.get("iconId"));
        _infoList.add(MapInfo.fromDocument(doc: element, icon: BitmapDescriptor.fromBytes(_tempList)));
      }
    });
    return _infoList;
  }

  static Future getSpecificUserLocation(String userId) async {
    DocumentSnapshot _temp = await locationReference
        .doc("open")
        .collection("usersLocation")
        .doc(userId)
        .get();
    if(_temp.exists){
      Map<String, dynamic>_map = _temp.data();
      // print("Dox id ${_temp.get("iconId")}");
      try{
          print("It has iconId");
          final Uint8List _tempList= await createMapIcon(iconId:_map["iconId"]);
          return MapInfo.fromDocument(doc: _temp,icon: BitmapDescriptor.fromBytes(_tempList));
      }catch(e){
        print("ERROR: $e");
        return null;
      }
    }
  }


  static Future<void> addLocationToDatabase(Position position) async {
    DocumentSnapshot _dox = await locationReference
        .doc("open")
        .collection("usersLocation")
        .doc(currentUser.id).get();
    if(_dox.exists){
      await locationReference
          .doc("open")
          .collection("usersLocation")
          .doc(currentUser.id)
          .update({
        "currentLocation": GeoPoint(position.latitude, position.longitude),
        "liveLocation": false,
        "id": currentUser.id,
        "url": currentUser.petUrl,
        "username": currentUser.username,
        "profileName": currentUser.profileName,
        "isOpen":currentUser.isOpen,
        "accountType": currentUser.accountType,
      });
    }else{
      await locationReference
          .doc("open")
          .collection("usersLocation")
          .doc(currentUser.id)
          .set({
        "currentLocation": GeoPoint(position.latitude, position.longitude),
        "liveLocation": false,
        "id": currentUser.id,
        "url": currentUser.petUrl,
        "username": currentUser.username,
        "profileName": currentUser.profileName,
        "isOpen":currentUser.isOpen,
        "accountType": currentUser.accountType,
        "iconId":"default"
      });
    }

  }

  static saveToLocalStorage(Uint8List iconImage,String code)async{
    Directory directory = await getTemporaryDirectory();
    String directoryPath = directory.path;
    File _temp =await File('$directoryPath/$code.png').create();
    _temp.writeAsBytes(iconImage).then((value){
      print("id: ${code} and path is ${value.path}");
      storedIcons.add({
        code : value.path
      });
    });
  }


  static Future<Uint8List> createMapIcon({String iconId})async{
    if(storedIcons.isEmpty){
      print("No StoredIcons");
      Uint8List _iconImage =await firebase_storage.FirebaseStorage.instance.ref("MapIcons/$iconId").getData();
      saveToLocalStorage(_iconImage,iconId);
      return _iconImage;
    }else{
      print("Icons are stored");
      for(Map map in storedIcons){
        if(map.containsKey(iconId)){
          print(iconId);
          print("Found in stored icon");
          if(!File(map[iconId]).existsSync()){
            storedIcons = [];
            print("No StoredIcons");
            Uint8List _iconImage =await firebase_storage.FirebaseStorage.instance.ref("MapIcons/$iconId").getData();
            saveToLocalStorage(_iconImage,iconId);
            return _iconImage;
          }
          print("Found at ${File(map[iconId])} and id is ${iconId}");
          return File(map[iconId]).readAsBytesSync();
        }
      }
      Uint8List _iconImage =await firebase_storage.FirebaseStorage.instance.ref("MapIcons/$iconId").getData();
      saveToLocalStorage(_iconImage,iconId);
      return _iconImage;
    }

    // BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(,size:Size(1,1)), 'assets/pets/dog.png',mipmaps: false);
    // return icon;

    // ByteData data = await rootBundle.load('assets/pets/dog.png');
    // final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
    //     data.buffer.asUint8List());
    // final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
    //     buffer);
    // print("width is ${descriptor.width}");
    // ui.Codec codec = await ui.instantiateImageCodec(
    //     data.buffer.asUint8List(), targetWidth: 170);
    // ui.FrameInfo fi = await codec.getNextFrame();
    // return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer
    //     .asUint8List();
  }

}
