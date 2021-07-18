// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petziee/SignIn/signupScreen.dart';
import 'package:petziee/apis/googlemap_provider.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

import '../../HomePage.dart';


class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {

  Map<String, bool>checkBoxValues = {
    "Pet Trainer": false,
    "Pet Shop": false,
    "Vet" : false,
  };

  bool _switchValue = false;

  @override
  void initState() {
    PhoneDatabase.getMapTypeCheckBocList().then((item) {
       if(item!=null){
         checkBoxValues.update("Pet Trainer", (value) => item[0]=="true");
         checkBoxValues.update("Pet Shop", (value) => item[1]=="true");
         checkBoxValues.update("Vet", (value) => item[2]=="true");
       }else{
         checkBoxValues.updateAll((key, value) => false);
       }
       setState(() {
       });

    });
    PhoneDatabase.getIsPrivateAccount().then((value){
     setState(() {
       if(value!=null){
         _switchValue = value;
       }else{
         _switchValue = false;
       }
     });
    });

    super.initState();
  }

  _backPressed(){
    List<String>_temp =[];
    checkBoxValues.values.forEach((element) {
      if(element)_temp.add("true");
      else _temp.add("false");
    });

    updateAccountInfoToFirebase(_switchValue,checkBoxValues);
    PhoneDatabase.saveIsPrivateAccount(_switchValue);
    PhoneDatabase.saveMapTypeCheckBoxList(_temp);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>_backPressed(),
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              child: Container(
                color: Colors.grey.shade900,
                height: 55,
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: ()=>_backPressed()),
                    SizedBox(width: 5,),
                    Text(
                      "Privacy",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(0),
              children: [
                ListTile(
                  title: Text(
                    "Account Privacy",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // tileColor: Colors.brown,
                ),
                ListTile(
                  title: Text("Private Location"),
                  leading: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                  ),
                  trailing: CupertinoSwitch(value: _switchValue, onChanged: (value){
                    setState(() {
                      _switchValue = !_switchValue;
                    });
                    PhoneDatabase.saveMapSettingIsOpenState(_switchValue);
                  }),
                  horizontalTitleGap: 0,
                  // tileColor: Colors.red,
                ),
                Divider(),
                ListTile(
                  title: Text(
                    "Map",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Account Type",
                  ),
                  subtitle: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      CheckboxListTile(
                        value: checkBoxValues["Pet Trainer"],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        title: Text("Pet Trainer"),
                        onChanged: (value) {
                          checkBoxValues.update("Pet Trainer", (element) => value);
                          setState((){});
                        },
                        dense: true,
                        activeColor: Colors.grey.shade900,
                        checkColor: Colors.white,
                      ),
                      CheckboxListTile(
                        value: checkBoxValues["Pet Shop"],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        title: Text("Pet Shop"),
                        onChanged: (value) {
                          checkBoxValues.update("Pet Shop", (element) => value);
                          setState(() {});
                        },
                        dense: true,
                        activeColor: Colors.grey.shade900,
                        checkColor: Colors.white,
                      ),
                      CheckboxListTile(
                        value: checkBoxValues["Vet"],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        title: Text("Vet"),
                        onChanged: (value) {
                          checkBoxValues.update("Vet", (element) => value);

                          setState(() {});
                        },
                        dense: true,
                        activeColor: Colors.grey.shade900,
                        checkColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    "Log out",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: ()=>logout(),
                  leading: Icon(Icons.logout,color: Colors.white,),
                ),
                // ListTile(
                //   title: Text("Paws"),
                //   leading: Icon(Icons.wc_rounded,color: Colors.white,),
                //   horizontalTitleGap: 0,
                // ),
                // ListTile(
                //   title: Text("Tails"),
                //   leading: Icon(Icons.wc_rounded,color: Colors.white,),
                //   horizontalTitleGap: 0,
                // ),
                // ListTile(
                //   title: Text("Blocked Accounts"),
                //   leading: Icon(Icons.block_outlined,color: Colors.white,),
                //   horizontalTitleGap: 0,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  logout()async{
    // HomePage.globalKey.currentState.showSneakBar(test: true);
    // print("Here");

    FirebaseAuth.instance.signOut();
    print("In Logout");
    // Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>SignUp()), (Route<dynamic> route) => false);
  }
}


updateAccountInfoToFirebase(bool isPrivate,Map<String,bool>type)async{
  usersReference.doc(currentUser.id).update({
    "isOpen": !isPrivate,
    "accountType":type,
  });
  await updateCurrentUser();
  final pos = await Geolocator.getLastKnownPosition();
  GoogleMapProvider.addLocationToDatabase(pos);
}
