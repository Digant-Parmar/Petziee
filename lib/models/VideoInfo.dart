// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
class VideoInfo {
String ownerId;
String postId;
String thumbUrl;
double aspectRatio;
DateTime uploadedAt;
String videoName;
bool finishedProcessing;
String uploadedAtString;
String url;
String rawPath;
bool uploadComplete;
bool isPhoto;
String duration;

VideoInfo({
  this.thumbUrl,
  this.aspectRatio,
  this.uploadedAt,
  this.videoName,
  this.finishedProcessing,
  this.url,
  this.rawPath,
  this.uploadComplete,
  this.ownerId,
  this.postId,
  this.uploadedAtString,
  this.isPhoto,
  this.duration,
});
}
