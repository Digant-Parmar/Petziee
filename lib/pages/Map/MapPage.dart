// @dart=2.9
import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/triangle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:petziee/apis/googlemap_provider.dart';
import 'package:petziee/models/mapInfo.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/Profile/ProfilePage.dart';
import 'package:petziee/pages/chat/ConversationScreen.dart';
import 'package:petziee/widgets/CustomDialogWidget.dart';
import 'package:petziee/widgets/MapTransition.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

import '../HomePage.dart';
import '../SearchPage.dart';
import 'MapFilter.dart';
import 'MapSettings.dart';
import 'PawsTails.dart';

List<dynamic> storedIcons = [];

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();

  Position position = new Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 90,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 10);
  bool isPosReady = false;

  BitmapDescriptor customIcon;
  MapInfo currentUserInfo = new MapInfo();
  Set<Widget> userData = {};
  Set<Marker> _markers = {};
  final locationReference = FirebaseFirestore.instance.collection("location");
  String filter = "ALL";
  String _darkMapStyle;
  String _lightMapStyle;
  bool isGoogleMapLoaded = false;
  bool initialLoad = true;
  bool _isContainerLoading = true;
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  // Future<PlaceFilter>getPlaces(String filter)async{
  //   String k = "AIzaSyBlsG78jMrky6tWQGBR4_MD3Q_ypFwcD-0";
  //   final response = await http.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=1500&type=restaurant&keyword=cruise&key=$k");
  //   return PlaceFilter.fromJson(jsonDecode(response.body));
  // }

  getLocationOfDevice() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (pos == null) {
      pos = await Geolocator.getLastKnownPosition();
    }
    setState(() {
      position = pos;
      isPosReady = true;
    });
    if (_controller.isCompleted) {
      _goTOLocation(pos.latitude, pos.longitude);
    } else {
      _controller.future.whenComplete(() {
        _goTOLocation(pos.latitude, pos.longitude);
      });
    }
  }

  checkLocationPermission({bool isRecheck = false}) async {
    loc.Location location = new loc.Location();
    bool isLocationServiceEnabled = await location.serviceEnabled();
    if (!isLocationServiceEnabled) {
      isLocationServiceEnabled = await location.requestService();
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.whileInUse ||
        permission != LocationPermission.always) {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
      LocationPermission per = await Geolocator.requestPermission();
      setState(() {
        permission = per;
      });
    }

    await getLocationOfDevice();
    await GoogleMapProvider.addLocationToDatabase(position);
    MapInfo temp =
        await GoogleMapProvider.getSpecificUserLocation(currentUser.id);
    print("Current user returned is $temp");
    setState(() {
      currentUserInfo = temp;
    });
    print("$isRecheck came from recheck}");
    if (temp.iconId == "default") {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        var result = await MapIconsDialog().showDialog(
          context,
          currentIconId: "default",
        );
        if (result != null && result != currentUserInfo.iconId) {

          PhoneDatabase.saveCurrentUserMapIcon(result);

          await locationReference
              .doc("open")
              .collection("usersLocation")
              .doc(currentUser.id)
              .update({
            'iconId': result,
          });
          recheckCurrentLocation();
        }
        print("Result is : $result");
      });
    }
    if (!isRecheck) {
      addMarkers(filter);
    } else {
      addSpecificMarker(currentUserInfo);
    }
  }

  _loadMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/map_styles/dark_mode.json');
    _lightMapStyle =
        await rootBundle.loadString('assets/map_styles/light_mode.json');
  }

  getinitMapStyle() {
    PhoneDatabase.getMapSettingIsOpneState().then((value) {
      setState(() {
        if (value != null) {
          _setMapStyle(value);
        } else {
          _setMapStyle(true);
        }
      });
    });
  }

  // Future<Uint8List> getCustomIcon(String path, int width) async {
  //
  //   String mapIconName = await PhoneDatabase.getMapIcon();
  //   Directory dir =await getApplicationSupportDirectory();
  //   final String  dirPath = dir.path;
  //   if(mapIconName == null){
  //     // Uint8List _markerIcon = await createMapIcon("1", 150);
  //     File _file = File('$dirPath/MapIcons/icon');
  //     _file.writeAsBytes(_markerIcon);
  //     return _file.readAsBytes();
  //   }else{
  //
  //   }
  // }

  getMapIcons() async {
    var _temp;
    await PhoneDatabase.getMapIcons().then((value) {
      if (value == null) {
        storedIcons = [];
      } else if (value.isNotEmpty) {
        _temp = jsonDecode(value);
        storedIcons = _temp;
      }
    });
  }

  @override
  void initState() {
    _loadMapStyles();

    getMapIcons();
    checkLocationPermission();
    getinitMapStyle();
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        initialLoad = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.future.then((value) => value.dispose());
    _customInfoWindowController.dispose();
    PhoneDatabase.saveMapIcons(jsonEncode(storedIcons));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialLoad
          ? Center(
              child: CircularProgressIndicator(),
            )
          : loader(),
    );
  }

  Widget loader() {
    return Stack(
      children: [
        _googleMap(context),
        _addTopBar(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 135),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up_sharp,
                color: Colors.deepOrangeAccent,
                size: 35.0,
              ),
              onPressed: moveToFilterPage,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(bottom: 135, right: 10),
            child: Container(
              width: 40,
              height: 40,
              child: RawMaterialButton(
                  onPressed: () => recheckCurrentLocation(),
                  fillColor: Colors.black.withOpacity(0.8),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  shape: new CircleBorder(),
                  child: Icon(
                    Icons.my_location,
                    size: 30.0,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
        _isContainerLoading ? Container() : _buildContainer(),
      ],
    );
  }

  recheckCurrentLocation() {
    checkLocationPermission(isRecheck: true);
  }

  // givenUserId()async{
  //   print("Its in here");
  //   MapInfo temp = await GoogleMapProvider.getSpecificUserLocation(profileId.value, isOpen.value?"open":"close");
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(temp.currentLocation.latitude,temp.currentLocation.longitude), zoom: 15, tilt: 50.0, bearing: 45.0)));
  // }

  moveToFilterPage() async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new MapFilter(),
          fullscreenDialog: true,
        ));
    print("RESULT IS $result");
    if (result != filter && result != null) {
      setState(() {
        filter = result;
        _isContainerLoading = true;
      });
      addMarkers(result);
    }
  }

  Widget _addTopBar() {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 50,
                height: 50,
                child: RawMaterialButton(
                    onPressed: () => goToPawTail(),
                    fillColor: Colors.black.withOpacity(0.5),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    shape: new CircleBorder(),
                    child: Icon(
                      Icons.person_pin,
                      size: 30.0,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
          Spacer(),
          // Padding(
          //   padding: const EdgeInsets.only(top: 25.0, left: 10.0, right: 10.0),
          //   child: Align(
          //     alignment: Alignment.topLeft,
          //     child: Container(
          //       child: Text(
          //         "TADWADI",
          //         style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 25,
          //           fontWeight: FontWeight.w700,
          //           fontStyle: FontStyle.italic,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 50,
                height: 50,
                child: RawMaterialButton(
                    onPressed: () => searchMap(),
                    fillColor: Colors.black.withOpacity(0.5),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    shape: new CircleBorder(),
                    child: Icon(
                      Icons.search,
                      size: 30.0,
                      color: Colors.red,
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 50,
                height: 50,
                child: RawMaterialButton(
                    onPressed: () => mapSettings(),
                    fillColor: Colors.black.withOpacity(0.5),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    shape: new CircleBorder(),
                    child: Icon(
                      Icons.settings,
                      size: 30.0,
                      color: Colors.red,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  goToPawTail() async {
    // storedIcons = [];
    // PhoneDatabase.saveMapIcons(jsonEncode(storedIcons));
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PawsTails()));
  }

  mapSettings() async {
    var _result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MapSettings()));
    print("IconId : ${_result["iconId"]} and style : ${_result["style"]}");

    if (_result != null) {
      if (_result["iconId"] != null) recheckCurrentLocation();
      if (_result["style"] != null) {
        setState(() {
          _setMapStyle(_result["style"]);
        });
      }
    }
  }

  Future _setMapStyle(bool result) async {
    final controller = await _controller.future;
    if (result) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(_lightMapStyle);
    }
  }

  // Align(
  // alignment: Alignment.bottomLeft,
  // child: Container(
  // margin: EdgeInsets.symmetric(vertical: 20.0),
  // height: 100.0,
  // child: ListView(
  // scrollDirection: Axis.horizontal,
  // children: [
  // Padding(
  // padding: const EdgeInsets.only(top: 8, bottom: 8.0, right: 5.0, left: 5.0),
  // child: _boxes(
  // "https://image.shutterstock.com/image-photo/bright-spring-view-cameo-island-260nw-1048185397.jpg",
  // 40.732128,-73.999619,"Digant"
  // ),
  // ),
  // Padding(
  // padding: const EdgeInsets.only(top: 8, bottom: 8.0, right: 5.0, left: 5.0),
  // child: _boxes(
  // "https://image.shutterstock.com/image-photo/bright-spring-view-cameo-island-260nw-1048185397.jpg",
  // 40.632128,-73.995619,"digant17"
  // ),
  // ),
  // Padding(
  // padding: const EdgeInsets.only(top: 8, bottom: 8.0, right: 5.0, left: 5.0),
  // child: _boxes(
  // "https://image.shutterstock.com/image-photo/bright-spring-view-cameo-island-260nw-1048185397.jpg",
  // 40.702128,-73.899619,"_+digant+_"
  // ),
  // ),
  // ],
  // ),
  // ),
  // );
  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 50.0),
        height: 100.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: userData.toList(),
        ),
      ),
    );
  }

  searchMap() async {
    var _result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchPage(
                  isMap: true,
                )));
    if (_result != null) {
      addSpecificMarker(_result);
    } else {
      print("No specified Location");
    }
  }

  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          GoogleMap(
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                () => new EagerGestureRecognizer(),
              ),
            ].toSet(),
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove();
            },
            mapType: MapType.normal,
            markers: _markers,
            zoomControlsEnabled: false,
            compassEnabled: false,
            initialCameraPosition: isPosReady
                ? CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 12)
                : CameraPosition(target: LatLng(20.5937, 78.9629)),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _customInfoWindowController.googleMapController = controller;
              setState(() {
                isGoogleMapLoaded = true;
              });
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 150,
            width: 250,
            offset: 83,
          ),
          isGoogleMapLoaded
              ? Container()
              : Center(
                  child: CircularProgressIndicator(),
                )
        ],
      ),
    );
  }

  makeMarker(MapInfo info) {
    return Marker(
      markerId: MarkerId(info.id),
      position:
          LatLng(info.currentLocation.latitude, info.currentLocation.longitude),
      onTap: () {
        if(info.id !=currentUser.id){
          _customInfoWindowController.addInfoWindow(
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CircleAvatar(
                                radius: 35.0,
                                backgroundColor: Colors.transparent,
                                child: CachedNetworkImage(
                                  imageUrl: info.url,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 4, left: 2),
                                  child: Text(
                                    info.username,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Text(
                                  info.profileName,
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  (Geolocator.distanceBetween(
                                      currentUserInfo
                                          .currentLocation.latitude,
                                      currentUserInfo
                                          .currentLocation.longitude,
                                      info.currentLocation.latitude,
                                      info.currentLocation
                                          .longitude) /
                                      1000)
                                      .toStringAsFixed(2) +
                                      " km",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 14.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: ()=>sendToChat(info.id),
                                        child: Container(
                                          width: 65,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(7),
                                            border:
                                            Border.all(color: Colors.white),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Message",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: ()=>_goToProfile(info.id),
                                        // mapButtonName == "Map"?()=>sendToMap() :onMapButtonPressed,
                                        child: Container(
                                          width: 65,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(7),
                                              border: Border.all(
                                                  color: Colors.blueAccent),
                                              color: Colors.blueAccent),
                                          child: Center(
                                            child: Text(
                                              "Profile",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.blue,
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             Icons.account_circle,
                //             color: Colors.white,
                //             size: 30,
                //           ),
                //           SizedBox(
                //             width: 8.0,
                //           ),
                //           Text(
                //             "I am here",
                //             style:
                //             Theme.of(context).textTheme.headline6.copyWith(
                //               color: Colors.white,
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //     width: double.infinity,
                //     height: double.infinity,
                //   ),
                // ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Triangle.isosceles(
                    edge: Edge.BOTTOM,
                    child: Container(
                      color: Colors.blue,
                      width: 20.0,
                      height: 10.0,
                    ),
                  ),
                ),
              ],
            ),
            LatLng(info.currentLocation.latitude, info.currentLocation.longitude),
          );
        }
      },
      icon: info.icon,
    );
  }

  addSpecificMarker(specificUser) async {
    MapInfo temp =
        await GoogleMapProvider.getSpecificUserLocation(specificUser.id);
    if (temp != null) {
      Marker tempMarker = makeMarker(temp);
      if (!_markers.contains(tempMarker)) {
        setState(() {
          _markers.add(tempMarker);
        });
      }
      _goTOLocation(
          temp.currentLocation.latitude, temp.currentLocation.longitude);
    }
  }

  getMakeBox(MapInfo info, double distance) {
    return makeBoxes(
        image: info.url == " "
            ? "https://image.shutterstock.com/image-photo/bright-spring-view-cameo-island-260nw-1048185397.jpg"
            : info.url,
        lat: info.currentLocation.latitude,
        long: info.currentLocation.longitude,
        username: info.username,
        profileName: info.profileName,
        distance: distance,
        id: info.id);
  }

  addMarkers(String which) async {
    _markers.clear();
    userData.clear();
    print(DateTime.now().second);
    print(DateTime.now().second);
    //To add the current user location marker on the map
    if (currentUserInfo.id == null) {
      // print("currentUser is null");
      Future.delayed(Duration(milliseconds: 500), () async {
        MapInfo _temp =
            await GoogleMapProvider.getSpecificUserLocation(currentUser.id);
        _markers.add(await makeMarker(currentUserInfo));
        currentUserInfo = _temp;
        //
        // setState(() {
        // });
      });
    } else {
      // print("Marker id is : ${currentUserInfo.id}");
      _markers.add(await makeMarker(currentUserInfo));
    }

    //Adding the needed marker when the map page is opened
    switch (which) {
      case "open":
        List<MapInfo> openList = await GoogleMapProvider.getOpenLocation();
        if (openList.isNotEmpty || openList != null) {
          openList.forEach((element) {
            _markers.add(makeMarker(element));
            double _distance = Geolocator.distanceBetween(
                    currentUserInfo.currentLocation.latitude,
                    currentUserInfo.currentLocation.longitude,
                    element.currentLocation.latitude,
                    element.currentLocation.longitude) /
                1000;
            userData.add(getMakeBox(element, _distance));
          });
        }
        break;
      case "Paws":
        await GoogleMapProvider.getPawsLocation().then((allLocations) {
          if (allLocations.isNotEmpty || allLocations != null) {
            allLocations.forEach((eachLocation) {
              _markers.add(makeMarker(eachLocation));
              double _distance = Geolocator.distanceBetween(
                      currentUserInfo.currentLocation.latitude,
                      currentUserInfo.currentLocation.longitude,
                      eachLocation.currentLocation.latitude,
                      eachLocation.currentLocation.longitude) /
                  1000;
              userData.add(getMakeBox(eachLocation, _distance));
            });
          }
        });
        break;
      case "All":
        await GoogleMapProvider.getAllLocation().then((allLocations) {
          if(allLocations!=null){
            if (allLocations.isNotEmpty) {
              allLocations.forEach((eachLocation) {
                double _distance = Geolocator.distanceBetween(
                    currentUserInfo.currentLocation.latitude,
                    currentUserInfo.currentLocation.longitude,
                    eachLocation.currentLocation.latitude,
                    eachLocation.currentLocation.longitude) /
                    1000;
                userData.add(getMakeBox(eachLocation, _distance));
                _markers.add(makeMarker(eachLocation));
              });
            }
          }
        });
        break;
      case "Pet Trainer":
        Set<Marker> _temp = {};
        List<Widget> _temp1 = [];
        await GoogleMapProvider.getPetTrainerLocation()
            .then((petTrainerLocation) {
          if (petTrainerLocation.isNotEmpty || petTrainerLocation != null) {
            petTrainerLocation.forEach((eachLocation) {
              _temp.add(makeMarker(eachLocation));
              double _distance = Geolocator.distanceBetween(
                      currentUserInfo.currentLocation.latitude,
                      currentUserInfo.currentLocation.longitude,
                      eachLocation.currentLocation.latitude,
                      eachLocation.currentLocation.longitude) /
                  1000;
              _temp1.add(getMakeBox(eachLocation, _distance));
            });
          }
          _markers.addAll(_temp);
          userData.addAll(_temp1);
        });
        break;
      case "Vet":
        await GoogleMapProvider.getVetLocation().then((vetLocations) {
          if (vetLocations.isNotEmpty || vetLocations != null) {
            vetLocations.forEach((eachLocation) {
              _markers.add(makeMarker(eachLocation));
              double _distance = Geolocator.distanceBetween(
                      currentUserInfo.currentLocation.latitude,
                      currentUserInfo.currentLocation.longitude,
                      eachLocation.currentLocation.latitude,
                      eachLocation.currentLocation.longitude) /
                  1000;
              userData.add(getMakeBox(eachLocation, _distance));
            });
          }
        });
        break;
      case "Pet Shop":
        await GoogleMapProvider.getPetShopLocation().then((petShopLocations) {
          if (petShopLocations.isNotEmpty || petShopLocations != null) {
            petShopLocations.forEach((eachLocation) {
              _markers.add(makeMarker(eachLocation));
              double _distance = Geolocator.distanceBetween(
                      currentUserInfo.currentLocation.latitude,
                      currentUserInfo.currentLocation.longitude,
                      eachLocation.currentLocation.latitude,
                      eachLocation.currentLocation.longitude) /
                  1000;
              userData.add(getMakeBox(eachLocation, _distance));
            });
          }
        });
        break;
      default:
        await GoogleMapProvider.getAllLocation().then((allLocations) {
          if (allLocations.isNotEmpty || allLocations != null) {
            allLocations.forEach((eachLocation) {
              _markers.add(makeMarker(eachLocation));
              double _distance = Geolocator.distanceBetween(
                      currentUserInfo.currentLocation.latitude,
                      currentUserInfo.currentLocation.longitude,
                      eachLocation.currentLocation.latitude,
                      eachLocation.currentLocation.longitude) /
                  1000;
              userData.add(getMakeBox(eachLocation, _distance));
            });
          }
        });
        break;
    }

    //For the user entering from the profile page
    if (profileId != null) {
      _isContainerLoading = false;
      MapInfo temp = await GoogleMapProvider.getSpecificUserLocation(profileId);
      Marker tempMarker = Marker(
        markerId: MarkerId(profileId),
        position: LatLng(
            temp.currentLocation.latitude, temp.currentLocation.longitude),
        infoWindow: InfoWindow(
          title: temp.id,
          snippet: temp.currentLocation.latitude.toString(),
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      _markers.add(tempMarker);

      _goTOLocation(
          temp.currentLocation.latitude, temp.currentLocation.longitude);
    }
    // print("Duration end: ${DateTime
    //     .now()
    //     .difference(current)
    //     .inMilliseconds}");
    // print("Marker lenght :${_markers.length} and ${_markers.first.markerId}");
    print("Set state");
    print(
        "Marker length : ${_markers.length} and userData length ${userData.length}");
    if (userData.isNotEmpty) {
      _isContainerLoading = false;
    }
    setState(() {});
  }

  //
  // _markers.add(Marker(
  // markerId: MarkerId(position.toString()),
  // position: LatLng(position.latitude, position.longitude),
  // infoWindow: InfoWindow(
  // title: "Me",
  // snippet: "Bio",
  // ),
  // icon: BitmapDescriptor.defaultMarker,
  // ));
  Future<List<dynamic>>getChatRoomId(String a, String b) async{
    final _ref =FirebaseFirestore.instance.collection("chatRoom");
    print("$a is the a and $b is the b");
    if (a.substring(0, 1).codeUnitAt(0) >= b.substring(0, 1).codeUnitAt(0)) {
      DocumentSnapshot doc = await _ref.doc("$b\_$a").get();
      if(doc.exists){return[true, doc.id];}
      else{return [false,"$b\_$a"];}
    } else {
      DocumentSnapshot doc = await _ref.doc("$a\_$b").get();
      if(doc.exists){return[true,doc.id];}
      else{return [false,"$a\_$b"];}
    }
  }

  sendToChat(String userProfileId)async{
    List<dynamic> chatRoomId =await getChatRoomId(currentUser.id, userProfileId);
    print("${chatRoomId[0]}");
    DocumentSnapshot documentSnapshot =
    await usersReference.doc(userProfileId).get();
    if (!documentSnapshot.exists) {
      documentSnapshot = await usersReference.doc(userProfileId).get();
    }

    User otherUser = User.fromDocument(documentSnapshot);

    if(chatRoomId[0]){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                chatRoomId: chatRoomId[1],
                otherUser: otherUser,
                isVisible: false,
                profile: false,
              )));
    }else{
      List<String> users = [otherUser.id, currentUser.id];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomId[1],
        "lastMessage": null,
        "sendBy": currentUser.username,
        "time": DateTime.now().millisecondsSinceEpoch,
        "${currentUser.id}": true,
        "${otherUser.id}": true,
        "seenBy${currentUser.id}":true,
        "seenBy${otherUser.id}":false,
      };
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId[1])
          .set(chatRoomMap)
          .catchError((e) {
        print(e);
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                chatRoomId: chatRoomId[1],
                otherUser: otherUser,
                isVisible: false,
                profile: true,
              )));
    }

  }

  _goToProfile(String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: id,
                  allowAutomaticLeadingBack: true,
                )));
  }


  makeBoxes(
      {String username,
      String profileName,
      double lat,
      double long,
      String image,
      double distance,
      String id}) {
    print("In make box");
    return Padding(
      padding:
          const EdgeInsets.only(top: 8, bottom: 8.0, right: 5.0, left: 5.0),
      child: GestureDetector(
        onTap: () {
          _goTOLocation(lat, long);
        },
        //Send user to the profile page if it long presses the container bellow
        onLongPress: () {
          _goToProfile(id);
        },
        onDoubleTap: () {
          _goToProfile(id);
        },
        child: Material(
          color: Colors.black.withOpacity(0.7),
          elevation: 14.0,
          borderRadius: BorderRadius.circular(30),
          shadowColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(image),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: myDetailContainer(
                      username: username,
                      profileName: profileName,
                      distance: distance),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goTOLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, long), zoom: 19, tilt: 50.0, bearing: 45.0)));
  }

  Widget myDetailContainer(
      {String username, String profileName, double distance}) {
    return Container(
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80.0,
            child: Text(
              username,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Text(
              profileName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Text(
              "${distance.toStringAsFixed(2)} km",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

//
// class Boxes extends StatelessWidget {
//   final String image;
//   final double lat;
//   final double long;
//   final String name;
//   Boxes({this.image, this.lat, this.long, this.name});
//   @override
//   Widget build(BuildContext context) {
//       return Padding(
//         padding: const EdgeInsets.only(top: 8, bottom: 8.0, right: 5.0, left: 5.0),
//         child: GestureDetector(
//           onTap: (){
//             _goTOLocation(lat,long);
//           },
//           child: Material(
//             color: Colors.black.withOpacity(0.7),
//             elevation: 14.0,
//             borderRadius: BorderRadius.circular(30),
//             shadowColor: Colors.transparent,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: CircleAvatar(
//                     radius: 25,
//                     backgroundColor: Colors.grey,
//                     backgroundImage: NetworkImage(image),
//                   ),
//                 ),
//                 Container(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: myDetailContainer(name),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//   }
//   Future<void> _goTOLocation(double lat, double long)async{
//
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat,long), zoom: 15, tilt: 50.0, bearing: 45.0)));
//
//   }
//   Widget myDetailContainer(String name){
//     return Container(
//       height: 70,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 80.0,
//             child: Text(
//               name,
//               textAlign: TextAlign.left,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.0,
//               ),
//             ),
//           ),
//           Container(
//             alignment: Alignment.bottomRight,
//             child: Text(
//               "Digant Parmar",
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14.0,
//                   fontWeight: FontWeight.w400
//               ),
//             ),
//           ),
//           SizedBox(height: 3.0,),
//           Container(
//             alignment: Alignment.bottomRight,
//             child: Text(
//               "3.5 km",
//               style: TextStyle(
//                 color: Colors.white38,
//                 fontSize: 14.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
