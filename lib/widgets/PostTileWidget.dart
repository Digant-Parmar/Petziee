// @dart=2.9
import 'package:petziee/pages/chat/chat_bubble.dart';
import 'package:petziee/widgets/PostWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //TODO move to post screen
      onTap: (){
        print("Tappeddddddd");
        if(post.isPhoto){
          showGeneralDialog(
              context: context,
              pageBuilder: (context, anim1, anim2) {
                return PhotoPreview(
                  imageUrl: post.url,
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
        }else{
          showGeneralDialog(
              context: context,
              pageBuilder: (context, anim1, anim2) {
                return VideoPreview(
                  url: post.url,
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
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(post.thumbUrl, fit: BoxFit.cover,),
            post.isPhoto
                ?Container()
                :Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.play_arrow_rounded),
            ),
          ],
        ),
      ),
    );
  }
}