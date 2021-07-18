// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import 'CustomDialogWidget.dart';

class CustomMapIconList extends StatefulWidget {
  final String iconId;
  const CustomMapIconList({Key key,this.iconId}) : super(key: key);

  @override
  _CustomMapIconListState createState() => _CustomMapIconListState();
}

class _CustomMapIconListState extends State<CustomMapIconList> {
  bool _isLoading = true;
  List<Map<String, String>> defaultsMap = [];
  List<Map<String, String>> trainerMap = [];
  List<Map<String, String>>shopMap = [];
  List<Map<String, String>> vetMap = [];
  String selectedIcon;

  iconPressed({String iconId}){
    if(selectedIcon!=iconId){
      setState(() {
        selectedIcon = iconId;
      });
      print("Selected icon : $iconId");

    }
    // switch(map){
    //   case "defaultsMap":
    //
    //     break;
    //   case"trainerMap":
    //     break;
    //   case"shopMap":
    //     break;
    //   case "vetMap":
    //     break;
    // }
  }

  getIconsList() async {
    QuerySnapshot _snap =
        await FirebaseFirestore.instance.collection("MapIcons").get();
    for (DocumentSnapshot element in _snap.docs) {
      if (element.id.contains("id")) {
        defaultsMap.add({
          element.id: element.get("link"),
        });
        print("Elemnt id : ${element.get("link")}");
      } else if (element.id.contains("iv")) {
        vetMap.add({element.id: element.get("link")});
      } else if (element.id.contains("is")) {
        shopMap.add({element.id: element.get("link")});
      } else if (element.id.contains("it")) {
        trainerMap.add({
          element.id: element.get("link"),
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    getIconsList();
    selectedIcon = widget.iconId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: Constants.padding,
                        top: 10,
                        right: Constants.padding,
                        bottom: Constants.padding),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(Constants.padding),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 10),
                              blurRadius: 5),
                        ]),
                    child: Material(
                      color: Colors.grey[900],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: EdgeInsets.only(top: 5,left: 3),
                              child: Text(
                                "Icons",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          // Divider(),
                          SizedBox(
                            height:  deviceSize.height*0.58,
                            child: ListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              children: [
                                Text(
                                  "Default Icons",
                                  style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 8,),
                                GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (_,index){
                                    return CachedNetworkImage(
                                      imageUrl: defaultsMap[index].values.first,
                                      imageBuilder: (context,imageProvide){
                                        return Stack(
                                          children: [
                                            Image(image: imageProvide),
                                            GestureDetector(
                                              child:Container(
                                                child: Icon(Icons.check_circle_outline,color:selectedIcon==defaultsMap[index].keys.first?  Colors.greenAccent:Colors.transparent,),
                                                alignment: Alignment.topRight,
                                                color: Colors.transparent,
                                              ),
                                              onTap: (){iconPressed(iconId:defaultsMap[index].keys.first);},
                                            ),
                                            // Text(defaultsMap[index].keys.first,style: TextStyle(color: Colors.white),),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  itemCount: defaultsMap.length,
                                ),
                                Divider(),
                                trainerMap.isNotEmpty?Text(
                                  "Trainer Icons",
                                  style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                                ):Container(),
                                trainerMap.isNotEmpty?SizedBox(height: 8,):Container(),
                                trainerMap.isNotEmpty?GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (_,index){
                                    return CachedNetworkImage(
                                      imageUrl: trainerMap[index].values.first,
                                      imageBuilder: (context,imageProvide){
                                        return Stack(
                                          children: [
                                            Image(image: imageProvide),
                                            GestureDetector(
                                              child:Container(
                                                child: Icon(Icons.check_circle_outline,color:selectedIcon==trainerMap[index].keys.first?  Colors.greenAccent:Colors.transparent,),
                                                alignment: Alignment.topRight,
                                                color: Colors.transparent,
                                              ),
                                              onTap: (){iconPressed(iconId:trainerMap[index].keys.first);},
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  itemCount: trainerMap.length,
                                ):Container(),
                                trainerMap.isNotEmpty?Divider():Container(),
                                shopMap.isNotEmpty?Text(
                                  "Shop Icons",
                                  style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                                ):Container(),
                                shopMap.isNotEmpty?SizedBox(height: 8,):Container(),
                                shopMap.isNotEmpty?GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (_,index){
                                    return CachedNetworkImage(
                                      imageUrl: shopMap[index].values.first,
                                      imageBuilder: (context,imageProvide){
                                        return Stack(
                                          children: [
                                            Image(image: imageProvide),
                                            GestureDetector(
                                              child:Container(
                                                child: Icon(Icons.check_circle_outline,color:selectedIcon==shopMap[index].keys.first?  Colors.greenAccent:Colors.transparent,),
                                                alignment: Alignment.topRight,
                                                color: Colors.transparent,
                                              ),
                                              onTap: (){iconPressed(iconId:shopMap[index].keys.first);},
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  itemCount: shopMap.length,
                                ):Container(),
                                shopMap.isNotEmpty?Divider():Container(),
                                vetMap.isNotEmpty?Text(
                                  "Vet Icons",
                                  style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                                ):Container(),
                                vetMap.isNotEmpty?SizedBox(height: 8,):Container(),
                                vetMap.isNotEmpty?GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (_,index){
                                    return CachedNetworkImage(
                                      imageUrl: vetMap[index].values.first,
                                      imageBuilder: (context,imageProvide){
                                        return Stack(
                                          children: [
                                            Image(image: imageProvide),
                                            GestureDetector(
                                              child:Container(
                                                child: Icon(Icons.check_circle_outline,color:selectedIcon==vetMap[index].keys.first?  Colors.greenAccent:Colors.transparent,),
                                                alignment: Alignment.topRight,
                                                color: Colors.transparent,
                                              ),
                                              onTap: (){iconPressed(iconId:vetMap[index].keys.first);},
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  itemCount: vetMap.length,
                                ):Container(),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(null);
                                    },
                                    child: Text(
                                      "Close",
                                      style: TextStyle(fontSize: 18),
                                    )),
                              ),
                              Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(selectedIcon);
                                    },
                                    child: Text("Done",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.redAccent))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

}

