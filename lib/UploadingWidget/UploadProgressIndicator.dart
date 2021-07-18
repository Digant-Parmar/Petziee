// @dart=2.9
import 'package:petziee/widgets/VideoUploadProgressIndicatorWidget.dart';
import 'package:flutter/material.dart';


class UploadProgressIndicator extends StatefulWidget {

  final List<Map<String , String>> uploadPostList;

  UploadProgressIndicator({Key key,this.uploadPostList}) : super(key: key);
  @override
  _UploadProgressIndicatorState createState() => _UploadProgressIndicatorState();
}

class _UploadProgressIndicatorState extends State<UploadProgressIndicator> {

  List<VideoUploadProgressIndicatorWidget>_list=[];

  @override
  void initState() {
    widget.uploadPostList.forEach((element) {
      _list.add(VideoUploadProgressIndicatorWidget(filePath: element["filePath"],postId: element["postId"],));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _list.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context,index){
        return _list[index];
      },
    );
  }
}