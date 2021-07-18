// @dart=2.9
import 'package:cloud_functions/cloud_functions.dart';

class SendHttpsNotification{
  static sendLikeNotification({String currentUserId, String ownerId, String postId,String currentUsername,String currentUserImageUrl})async{
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'onLikeNotification',);
    dynamic resp = callable.call(<String,dynamic>{
      'ownerId': ownerId,
      'postId': postId,
      'currentUserId':currentUserId,
      'currentUsername': currentUsername,
      'imageUrl':currentUserImageUrl,
    });
  }
  static sendAddPawNotification({String currentUserId, String otherUserId,
                                      String currentUsername,String currentUserImageUrl})async{
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'onAddPawNotification',);
    dynamic resp = callable.call(<String,dynamic>{
      'otherUserId': otherUserId,
      'currentUserId':currentUserId,
      'currentUsername': currentUsername,
      'imageUrl':currentUserImageUrl,
    });
  }
  static pawRequestAcceptNotification({String acceptedById, String otherUserId,
    String acceptedByUsername,String acceptedByImageUrl})async{
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'onPawRequestAcceptNotification',);
    dynamic resp = callable.call(<String,dynamic>{
      'otherUserId': otherUserId,
      'acceptedById':acceptedById,
      'acceptedByUsername': acceptedByUsername,
      'imageUrl':acceptedByImageUrl,
    });
  }

  static videoUploadNotification({String userId, String videoId, String token, String videoRawPath})async{
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'backgroundVideoUpload',);
    dynamic resp = callable.call(<String,dynamic>{
      'userId': userId,
      'videoId':videoId,
      'token': token,
      'videoRawPath':videoRawPath,
    });
    return resp;
  }

}