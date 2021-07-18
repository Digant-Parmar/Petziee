// @dart=2.9
import 'package:flutter/material.dart';

class MapFilter extends StatefulWidget {
  
  MapFilter({Key key}) : super(key: key);
  
  @override
  _MapFilterState createState() => _MapFilterState();
}

class _MapFilterState extends State<MapFilter> {

  Widget appBarTitle = new Text("Filter", style: new TextStyle(color: Colors.white),);
  Icon actionIcon = new Icon(Icons.search, color: Colors.white,);
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<String>_list;
  bool _isSearching;
  String _searchText = "";


  _MapFilterState(){
    _searchQuery.addListener(() {
      if(_searchQuery.text.isEmpty){
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      }else{
        setState(() {
          _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  void initState() {
    _isSearching = false;
    init();
    super.initState();
  }
  
  void init(){
    _list = [];
    _list.add("All");
    _list.add("Paws");
    _list.add("Pet Trainer");
    _list.add("Pet Shop");
    _list.add("Vet");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: buildBar(context),
      body: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: _isSearching? _buildSearchList():_buildList(),
      ),
    );
  }
  
  List<ChildItem> _buildList(){
    return _list.map((e) => new ChildItem(e)).toList();
  }
  
  List<ChildItem> _buildSearchList(){
    
    
    if(_searchText.isEmpty){
      return _list.map((e) => new ChildItem(e)).toList();
    }else{
      List<String> _searchList = List();
      for(int i= 0; i<_list.length ; i++){
        String name = _list.elementAt(i);
        if(name.toLowerCase().contains(_searchText.toLowerCase())){
          _searchList.add(name);
        }
      }
      return _searchList.map((e) => new ChildItem(e)).toList();
    }
  }
  
  Widget buildBar(BuildContext context){
    return new AppBar(
      centerTitle: true,
      title: appBarTitle,
      actions: [
        new IconButton(icon: actionIcon, onPressed: (){
          setState(() {
            if(this.actionIcon.icon == Icons.search){
              this.actionIcon = new Icon(Icons.close, color: Colors.white,);
              this.appBarTitle = new TextField(
                controller: _searchQuery,
                style: new TextStyle(
                  color: Colors.white
                ),
                decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search, color: Colors.white,),
                  hintText: "Search...",
                  hintStyle: new TextStyle(color: Colors.white),
                ),
              );
              _handleSearchStart();
            }else{
              _handleSearchEnd();
            }
          });
        }),
      ],
    );
  }
  
  void _handleSearchStart(){
    setState(() {
      _isSearching = true;
    });
  }
  
  void _handleSearchEnd(){
    setState(() {
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      this.appBarTitle = new Text("Fillter", style: new TextStyle(color: Colors.white),);
      _isSearching = false;
      _searchQuery.clear();
    });
  }

}

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>applyFilter(context, name),
        child: new ListTile(title: new Text(this.name),)
    );
  }

  applyFilter(BuildContext context, String filterName){
    Navigator.pop(context, filterName);
  }

}

