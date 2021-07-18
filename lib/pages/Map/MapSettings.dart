// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petziee/apis/googlemap_provider.dart';
import 'package:petziee/widgets/CustomDialogWidget.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

class MapSettings extends StatefulWidget {
  @override
  _MapSettingsState createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {

  bool _switchValue = true;
  bool _initVale;
  String iconId;
  @override
  void initState() {
    PhoneDatabase.getMapSettingIsOpneState().then((value){
      setState(() {
        if(value!=null){
          _switchValue = value;
          _initVale = value;
        }else{
          _switchValue = true;
          _initVale = true;
        }
      });
    });
    super.initState();
  }

  _backPressed()async {
    Navigator.of(context).pop(
      {
        "style": _initVale != _switchValue ? _switchValue : null,
        "iconId": iconId,
      }
    );
  }
  goToIconDialog()async{
    String currentIconId =await PhoneDatabase.getCurrentUserMapIcon();
    var result =await MapIconsDialog().showDialog(context, currentIconId: currentIconId,);
     if(result!=null){
       PhoneDatabase.saveCurrentUserMapIcon(result);
       await locationReference.doc("open").collection("usersLocation").doc(currentUser.id).update(
           {
             'iconId': result,
           });
       iconId = result;
     }
    print("Result is : $result");

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>_backPressed(),
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(),
                child: Container(
                  height: 55,
                  child: Row(
                    children: [
                      IconButton(icon: Icon(Icons.arrow_back, color: Colors.grey,), onPressed: ()=>_backPressed()),
                      SizedBox(width: 5,),
                      Text(
                        "Settings",
                        style: TextStyle(
                          // color: Colors.white,
                          fontSize: 22
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Container(
                //   color: Colors.red,
                //   child: Text(
                //     "Account",
                //     style: TextStyle(
                //       color: Colors.yellow
                //     ),
                //   ),
                // ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(
                          // color: Colors.white,
                          fontSize: 18
                        ),
                      ),
                      trailing: CupertinoSwitch(value: _switchValue, onChanged: (value){
                        print("Value is $value");
                        setState(() {
                          _switchValue = !_switchValue;
                        });
                        PhoneDatabase.saveMapSettingIsOpenState(_switchValue);
                      }),
                    ),
                    SizedBox(height: 2,),
                    ListTile(
                      title: Text(
                        "Select Map Icon",
                        style: TextStyle(
                            // color: Colors.white,
                            fontSize: 18
                        ),
                      ),
                      trailing: Icon(Icons.arrow_drop_down_outlined),
                      onTap: () {
                        goToIconDialog();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
