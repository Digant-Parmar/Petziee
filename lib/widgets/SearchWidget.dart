// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/Notification/HttpsNotification.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/pages/Profile/ProfilePage.dart';
import 'package:flutter/material.dart';

import 'UpdateCurrentUser.dart';


class UserResult extends StatelessWidget {
  final User eachUser;
  final bool isMap;
  final bool isPawTail;
  final bool isRemove;
  final String type;
  UserResult({this.eachUser, this.isMap, this.isPawTail = false, this.isRemove = true,this.type});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        // color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: ()=>displayUserProfile(context, userProfileId: eachUser.id,user: eachUser ),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.black, backgroundImage: CachedNetworkImageProvider(eachUser.humanUrl),),
                title: Text(eachUser.username, style: TextStyle(
                  // color: Colors.white,
                  fontSize: 16.0, fontWeight: FontWeight.bold,
                ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(eachUser.profileName, style: TextStyle(
                  // color: Colors.white54,
                  fontSize: 13.0,
                ),
                  overflow: TextOverflow.ellipsis,
                ),
                 trailing: isPawTail ? Container(
                  width: 90.0,
                  height: 70.0,
                  alignment: Alignment.centerRight,
                  child: ButtonTheme(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape:MaterialStateProperty.all( RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.white,)
                        ),),
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Text(
                        isRemove? "Remove":"Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: ()=>onButtonPressed(),
                    ),
                  ),
                ): Container(width: 0,height: 0,),
              ),
            ),
          ],
        ),
      ),
    );
  }


  onButtonPressed()async{
    switch(type){
      //Here considering that only requestPaws is of the accept type rest all is of remove type
      case "removePaw":
        pawsReference.doc(currentUser.id).collection("userPaws").doc(eachUser.id).delete();
        tailsReference.doc(eachUser.id).collection("userTails").doc(currentUser.id).delete();
        break;
      case "removeTail":
        tailsReference.doc(currentUser.id).collection("userTails").doc(eachUser.id).delete();
        pawsReference.doc(eachUser.id).collection("userPaws").doc(currentUser.id).delete();
        break;
      case "acceptPaws":
         SendHttpsNotification.pawRequestAcceptNotification(acceptedById: currentUser.id,
                                                            acceptedByImageUrl: currentUser.humanUrl,
                                                            acceptedByUsername: currentUser.username,
                                                            otherUserId: eachUser.id);
         pawsReference.doc(eachUser.id).collection("userPaws").doc(currentUser.id).set({});
         tailsReference.doc(currentUser.id).collection("userTails").doc(eachUser.id).set({});
         tailsReference.doc(currentUser.id).collection("requestedTails").doc(eachUser.id).delete();
        break;
      case "removeBlockedTails":
        tailsReference.doc(currentUser.id).collection("blockedTails").doc(eachUser.id).delete();
        break;
    }
  }

  displayUserProfile(BuildContext context, {String userProfileId, User user})async{
    print("In display user");
    if(!isMap){
      //If it didnt came from map
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: userProfileId,allowAutomaticLeadingBack: true,)));
    }else{
      //If it came from map search
      bool isOpen = user.isOpen;
      if(isOpen){
        //If the account is open the this will lead to on map view
        Navigator.of(context).pop(user);
      }else{
        //if the account is not open then it will check if the user is tail
        //if so it will open map
        //else it will send to the profile of the other user

        DocumentSnapshot ds = await tailsReference.doc(user.id).collection("userTails").doc(currentUser.id).get();
        if(ds.exists){
          Navigator.of(context).pop(user);
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: userProfileId,allowAutomaticLeadingBack: true,)));
        }

      }
    }
  }

}