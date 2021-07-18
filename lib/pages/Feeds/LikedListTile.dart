// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:petziee/pages/Profile/ProfilePage.dart';

import '../HomePage.dart';
class LikedListTile extends StatefulWidget {

  final String userId;

  LikedListTile({this.userId});


  @override
  _LikedListTileState createState() => _LikedListTileState();
}

class _LikedListTileState extends State<LikedListTile> {

  bool _isLoaded = false;
  String username;
  String humanUrl;

  getUserInfo()async{
    usersReference.doc(widget.userId).get().then((value){
      setState(() {
        username = value.get('username');
        humanUrl = value.get('humanUrl');
        _isLoaded = true;
      });
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return _isLoaded? ListTile(
      title: Text(username),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(humanUrl),
      ),
      onTap: ()=>sendToProfile(),
    ):Center(child: CircularProgressIndicator(),);
  }

  sendToProfile(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: widget.userId,allowAutomaticLeadingBack: true,)));
  }
}
