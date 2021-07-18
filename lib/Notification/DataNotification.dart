// @dart=2.9

import 'package:enum_to_string/enum_to_string.dart';

class DataNotification {

  final String id;
  final String title;
  final String body;
  final NotificationType notificationType;
  final String imageUrl;
  final dynamic data;
  final DateTime readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataNotification({this.id, this.title, this.body, this.notificationType, this.imageUrl, this.data, this.readAt, this.createdAt, this.updatedAt});


  factory DataNotification.fromPushMessage(dynamic data){
    return DataNotification(
      id: data['id'],
      title: data['title'],
      body: data['body'],
      notificationType: EnumToString.fromString(NotificationType.values, data['notificationType']),
      imageUrl: data['imageUrl']??null,
      data: data,
      readAt: null,
      createdAt: null,
      updatedAt: null,
    );
  }



}

enum NotificationType{
  NONE,
  COMMENT,
  LIKED,
  MESSAGE,
  GOT_IN_TRENDING,
  GOT_IN_TRENDING_LIST,
  NEW_MAP_REQUEST,
  MAP_REQUEST_ACCEPT,
}