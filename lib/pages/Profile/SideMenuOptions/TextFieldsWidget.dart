// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:petziee/widgets/widget.dart';

import '../../HomePage.dart';

class TextFields extends StatefulWidget {
  final bool isSignIn;
  TextFields({this.isSignIn =false});
  @override
  _TextFieldsState createState() => _TextFieldsState();
}


class _TextFieldsState extends State<TextFields> {
  TextEditingController _userNameEditingController = new TextEditingController();
  TextEditingController _profileNameEditingController = new TextEditingController();
  TextEditingController _bioEditingController = new TextEditingController();
  final formKey = GlobalKey<FormState>();

  updateProfileTextFields()async{
    await usersReference.doc(currentUser.id).update({
      "username" : _userNameEditingController.text,
      "profileName": _profileNameEditingController.text,
      "bio" : _bioEditingController.text,
      "usernameInLowerCase":_userNameEditingController.text.toLowerCase(),
    });

   DocumentSnapshot _dox = await FirebaseFirestore.instance.collection("location").doc(currentUser.isOpen?"open":"close").collection("usersLocation").doc(currentUser.id).get();
   if(_dox.exists){
     await FirebaseFirestore.instance.collection("location").doc(currentUser.isOpen?"open":"close").collection("usersLocation").doc(currentUser.id).update({
       "username":_userNameEditingController.text,
       "profileName": _profileNameEditingController.text,
     });
   }
    FocusScopeNode currentFocus = FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus && currentFocus.focusedChild!=null){
      FocusManager.instance.primaryFocus.unfocus();
    }
    await PhoneDatabase.saveUserNameSharedPreference(_userNameEditingController.text);
    await PhoneDatabase.saveProfileNameSharedPreference(_profileNameEditingController.text);
    await PhoneDatabase.saveBioSharedPreference(_bioEditingController.text);
    if(widget.isSignIn){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>HomePage(initPage: 2,)));
    }
  }

  @override
  void initState() {
       PhoneDatabase.getUserNameSharedPreference().then((value){
          if(value == null){
            _userNameEditingController.text = "";
          }else{
            _userNameEditingController.text = value;
          }
      });
       PhoneDatabase.getProfileNameSharedPreference().then((value){
         if(value==null){
           _profileNameEditingController.text = "";
         }else{
           _profileNameEditingController.text = value;

         }
       });
       PhoneDatabase.getBioSharedPreference().then((value){
         if(value == null){
           _bioEditingController.text ="";
         }else{
           _bioEditingController.text = value;
         }
       });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (val){
                  return val.isEmpty || val.length<2
                      ? "Please provide proper Username"
                      : null;
                },
                controller: _userNameEditingController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: profileEditInputDecoration("Username"),
              ),
              SizedBox(height: 15,),
              TextFormField(
                controller: _profileNameEditingController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: profileEditInputDecoration("Profile Name"),
              ),
              SizedBox(height: 15,),
              TextFormField(
                controller: _bioEditingController,
                maxLines: 8,
                maxLength: 250,
                minLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: profileEditInputDecoration("Bio"),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0,),
        FlatButton(
          onPressed: updateProfileTextFields,
          child: Container(
            width: 130,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white),
            ),
            child: Center(
              child: Text(
                widget.isSignIn?"Next":"Update",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
