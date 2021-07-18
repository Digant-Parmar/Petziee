
// @dart=2.9
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petziee/BackgroundTask/UploadingToDatabse.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ChatBubble extends StatefulWidget {
  final String message, time, username, type, replyText, replyName;
  final bool isMe, isGroup, isReply;
  final String chatId, userId;
  final String chatRoomId;
  final bool isUploading;

  ChatBubble({
    @required this.message,
    @required this.time,
    @required this.isMe,
    @required this.isGroup,
    @required this.username,
    @required this.type,
    @required this.replyText,
    @required this.isReply,
    @required this.replyName,
    this.isUploading,
    this.chatId,
    this.userId,
    this.chatRoomId,
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  //final key = new GlobalKey<SlidableState>();

  // SlidableState state = SlidableState();

  List colors = Colors.primaries;
  static Random random = Random();
  int rNum = random.nextInt(18);
  String processState = "Processing";

  // SlidableController slidableController;

  Color chatBubbleColor() {
    if (widget.type != "text" && !widget.isReply) {
      return Colors.transparent;
      //  transparent
    }
    if (widget.isMe) {
      return Colors.grey[800].withOpacity(0.3);
    } else {
      //Check If the Device has enable dark theme or not
      if (Theme.of(context).brightness == Brightness.dark) {
        return Colors.black54;
        //  black54
      } else {
        return Colors.grey[50];
      }
    }
  }

  Color chatBubbleReplyColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[800];
      //grey 800
    } else {
      return Colors.grey[50];
    }
  }

  // Animation<double> _rotationAnimation;
  //
  // void handelSlideAnimationChanged(Animation <double> slideAnimation){
  //   setState(() {
  //     _rotationAnimation = slideAnimation;
  //   });
  // }
  //
  // void handleSlideIsOpenChange(bool isOpen){
  //   print("Hereee");
  //   isOpen?print("Open"):print("Close");
  // }

  @override
  void initState() {
    // print("Chat  id is ${widget.chatId}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final align =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    // final salign = widget.isMe ? Alignment.centerRight: Alignment.centerLeft;

    final radius = widget.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.5));

    return widget.message != null ||
            (widget.message == null && widget.userId == currentUser.id)
        ? Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: align,
              children: [
                Container(
                  margin: const EdgeInsets.all(3.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: chatBubbleColor(),
                    borderRadius: radius,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.3,
                    minWidth: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      widget.isMe
                          ? SizedBox()
                          :
//IF ISGROUP THEN ADD RANDOM COLOR TO THE USERNAME OF THE PEOPLE IN GROUP
                          widget.isGroup
                              ? Padding(
                                  padding: EdgeInsets.only(right: 48.0),
                                  child: Container(
                                    child: Text(
                                      widget.username,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors[rNum],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                )
                              : SizedBox(),
                      widget.isGroup
                          ? widget.isMe
                              ? SizedBox()
                              : SizedBox(
                                  height: 5,
                                )
                          : SizedBox(),
                      widget.isReply
                          ? Container(
                              decoration: BoxDecoration(
                                color: chatBubbleReplyColor(),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 80,
                                minHeight: 25,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      child: Text(
                                        widget.isMe ? "You" : widget.replyName,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                      ),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Text(
                                            widget.type == "text"
                                                ? widget.replyText
                                                : widget.type,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                              fontSize: 10,
                                            ),
                                            maxLines: 2,
                                          ),
                                          alignment: Alignment.centerLeft,
                                        ),
                                        widget.type != "text"
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  width: 62,
                                                  height: 45,
                                                  child: Image(
                                                    errorBuilder: (context,
                                                        object, trace) {
                                                      return Container();
                                                    },
                                                    image: NetworkImage(
                                                        widget.replyText),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 2,
                            ),
                      widget.isReply
                          ? SizedBox(
                              height: 5,
                            )
                          : SizedBox(),
                      Padding(
                        padding: EdgeInsets.all(
                            widget.type == "text" || widget.isReply ? 5 : 0),
                        child: widget.type == "text" || widget.isReply
                            ? !widget.isReply
                                ? Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: widget.isMe
                                          ? Colors.white
                                          : Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.message,
                                      style: TextStyle(
                                        color: widget.isMe
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .color,
                                      ),
                                    ),
                                  )
                            : GestureDetector(
                                onTap: () => widget.message != null
                                    ? sendToViewer()
                                    : {},
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width /
                                              1.5,
                                      maxHeight:
                                          MediaQuery.of(context).size.height /
                                              2.6,
                                    ),
                                    child: widget.message != null
                                        ? CachedNetworkImage(
                                            imageUrl: widget.message,
                                            imageBuilder:
                                                (context, imageProvider) {
                                              return Container(
                                                width: 250,
                                                height: 150,
                                                child: Stack(
                                                  children: [
                                                    SizedBox(
                                                      child: Image(
                                                        image: imageProvider,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      width: 250,
                                                      height: 150,
                                                    ),
                                                    widget.type == "video"
                                                        ? Center(
                                                            child: Icon(
                                                              Icons
                                                                  .play_arrow_rounded,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.9),
                                                              size: 60,
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              );
                                            },
                                            progressIndicatorBuilder:
                                                (context, url, progress) {
                                              return Container(
                                                width: 210,
                                                height: 210,
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      25.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: 60,
                                                        height: 60,
                                                        child:
                                                            CircularProgressIndicator
                                                                .adaptive(
                                                          backgroundColor:
                                                              Colors.white54,
                                                          strokeWidth: 1.7,
                                                          value:
                                                              progress.progress,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : uploadWidget(),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: widget.isMe
                      ? EdgeInsets.only(right: 10.0, bottom: 10.0)
                      : EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: Text(
                    (DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.time.toString()))))
                        .toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  getResults(String state) {
    print("ProcessState: $state");
    setState(() {
      processState = state;
    });
  }

  createUpload() async {
    print("here");
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(widget.chatRoomId)
        .collection("chats")
        .doc(widget.chatId)
        .get();
    UploadingToDatabase uploadingToDatabase =
        UploadingToDatabase(setProgressState: getResults);
    uploadingToDatabase.initialize(
        postId: widget.chatId,
        filePath: snap.get("rawPath"),
        currentUserId: currentUser.id,
        chatRoomId: widget.chatRoomId,
        isChat: true);
  }

  Widget uploadWidget() {
    if (!widget.isUploading) {
      createUpload();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.replyText != null
            ? CachedNetworkImage(
                imageUrl: widget.replyText,
                errorWidget: (context, url, _) {
                  return Container(
                    width: 210,
                    height: 210,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.white54,
                                  strokeWidth: 1.7,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                progressIndicatorBuilder: (context, url, progress) {
                  return Container(
                    width: 210,
                    height: 210,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white54,
                              strokeWidth: 1.7,
                              value: progress.progress,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                width: 210,
                height: 210,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white54,
                              strokeWidth: 1.7,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        Text(
          processState,
          style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }

  sendToViewer() {
    // print("${CachedNetworkImage(imageUrl: widget.message,)}");
    if (widget.type == "image") {
      showGeneralDialog(
          context: context,
          pageBuilder: (context, anim1, anim2) {
            return PhotoPreview(
              imageUrl: widget.message,
            );
          },
          barrierLabel: "Label",
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: Duration(milliseconds: 300),
          transitionBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position:
                  Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
              child: child,
            );
          });
    } else if (widget.type == "video") {
      showGeneralDialog(
          context: context,
          pageBuilder: (context, anim1, anim2) {
            return VideoPreview(
              url: widget.replyText,
            );
          },
          barrierLabel: "Label",
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: Duration(milliseconds: 300),
          transitionBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position:
                  Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
              child: child,
            );
          });
    }
  }
}

class PhotoPreview extends StatefulWidget {
  final String imageUrl;

  const PhotoPreview({Key key, this.imageUrl}) : super(key: key);

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.down,
      key: const Key('photoviewDismissibleKey'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.grey.withOpacity(0.9),
        // ),

        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            PhotoView(
              imageProvider: CachedNetworkImageProvider(
                widget.imageUrl,
              ),
              loadingBuilder: (context, event) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
              minScale: PhotoViewComputedScale.contained,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8),
                  child: GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade700.withOpacity(0.6)),
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPreview extends StatefulWidget {
  final String url;

  const VideoPreview({this.url, Key key}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  bool loading = true;
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  initialize() async {
    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      looping: false,
      allowMuting: false,
      allowPlaybackSpeedChanging: false,
    );
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center(
            child: Chewie(
              controller: _chewieController,
            ),
          );
    return Dismissible(
      direction: DismissDirection.down,
      key: const Key('photoviewDismissibleKey'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Chewie(
                  controller: _chewieController,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
