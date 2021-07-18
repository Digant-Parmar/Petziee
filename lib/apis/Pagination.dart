// @dart=2.9

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:petziee/widgets/FeedItemWidget.dart';
import 'package:rxdart/rxdart.dart';

import 'FirebasePagination.dart';

class FeedListBloc{

  FirebasePagination firebasePagination;
  bool showIndicator = false;


  List<DocumentSnapshot>documentList;
  BehaviorSubject<List<FeedItemWidget>> feedController;
  BehaviorSubject<bool>showIndicatorController;

  FeedListBloc() {
    feedController = BehaviorSubject<List<FeedItemWidget>>();
    showIndicatorController =BehaviorSubject<bool>();
    firebasePagination = FirebasePagination();
  }


  Stream <List<FeedItemWidget>> get feedStream => feedController.stream;
  Stream get getShowIndicatorStream => showIndicatorController.stream;

  //For getting the first 10 list document

  Future fetchFirstList()async{
    print("In first fecht");
    try{
      documentList = await firebasePagination.fetchFirstList();
      List<FeedItemWidget>_temp = documentList.map((document) =>FeedItemWidget.fromDocument(document)).toList();
      feedController.sink.add(_temp);
      print( "t is ${_temp.length}");
      try {
        if (documentList.length == 0) {
          feedController.sink.addError("No data Available");
        }
      }catch(e){}
    }on SocketException{
      feedController.sink.addError(SocketException("No internet connection"));
    }catch(e){
      print(e.toString());
      feedController.sink.addError(e);
    }
  }


  //For automatically fetch other 10 documents

  fetchNextFeed()async{
    print("fetch next");
    try{

      updateIndicator(true);
      List<DocumentSnapshot>newDocumentList = await firebasePagination.fetchNextList(documentList);
      documentList.addAll(newDocumentList);
      List<FeedItemWidget>temp = documentList.map((document) =>FeedItemWidget.fromDocument(document)).toList();
      print( "t is ${documentList.length}");
      feedController.sink.add(temp);
      try{
        if(newDocumentList.length == 0){
          // feedController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      }catch(e){
        updateIndicator(false);
      }
    }on SocketException{
      // feedController.sink.addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    }catch(e){
      updateIndicator(false);
      print(e.toString());
      feedController.sink.addError(e);

    }
  }

  updateIndicator(bool value)async{
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }


  void dispose()async{
    print("Disposed");
    await feedController.close();
    await showIndicatorController.close();
    feedController.stream.value.clear();
  }

}