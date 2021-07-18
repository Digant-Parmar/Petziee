// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/pages/HomePage.dart';
import 'package:petziee/widgets/SearchWidget.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final bool isMap;
  SearchPage({Key key,this.isMap }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  final key = new GlobalKey<ScaffoldState>();


  emptyTheTextFormField(){
    searchTextEditingController.clear();
  }

  controlSearch(String str){
    if(str.isEmpty){
      setState(() {
      futureSearchResult = null;
    });
    return;
    }
    Future<QuerySnapshot> allUsers1 = usersReference.where("usernameInLowerCase", isGreaterThanOrEqualTo: str.toLowerCase(),isLessThan: str.substring(0,str.length-1)+String.fromCharCode(str.toLowerCase().codeUnitAt(str.length-1)+1)).get();
    // Future<QuerySnapshot> allUsers2 = usersReference.where("profileName", isGreaterThanOrEqualTo: str).get();

    setState(() {
      futureSearchResult = allUsers1;
    });
  }


  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 17.0, color: Colors.white),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "Search here....",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(Icons.person_pin, color: Colors.white, size: 30.0,),
          suffixIcon: IconButton(icon: Icon(Icons.clear, color: Colors.white,),onPressed: emptyTheTextFormField,),
        ),
        onChanged: controlSearch,
        onFieldSubmitted: controlSearch,
      ),
    );
  }

  displayNoSearchResultScreen(){
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(Icons.group, color: Colors.grey, size: 200.0,),
            Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUsersFoundScreen(){
    return FutureBuilder(
      future: futureSearchResult,
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return CircularProgressIndicator();
        }

        List<UserResult> searchUserResult = [];
        dataSnapshot.data.docs.forEach((document){
          User user = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser: user, isMap: widget.isMap,isPawTail: false,);
          searchUserResult.add(userResult);
        });
        return ListView(children: searchUserResult,);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResult==null ? displayNoSearchResultScreen(): displayUsersFoundScreen(),
    );
  }

  // @override
  // bool get wantKeepAlive =>true;
}


