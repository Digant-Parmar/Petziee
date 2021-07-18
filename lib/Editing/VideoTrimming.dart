// @dart=2.9

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmer extends StatefulWidget {
  final String filePath;

  VideoTrimmer({this.filePath});

  @override
  _VideoTrimmerState createState() => _VideoTrimmerState(
        filePath: filePath,
      );
}

class _VideoTrimmerState extends State<VideoTrimmer> {
  final String filePath;

  _VideoTrimmerState({this.filePath});

  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool _isLoaded = false;

  loadVideo() async {
    File file = File(filePath);
    await _trimmer.loadVideo(videoFile: file).then((_) {
      setState(() {
        _isLoaded = true;
      });
    });
  }

  @override
  void initState() {
    loadVideo();
    super.initState();
  }

  Future<String> _saveVideo() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   leading: IconButton(
      //     icon: Icon(Icons.clear,),
      //     onPressed: (){},
      //     padding: EdgeInsets.only(left: 30),
      //   ),
      //   actions: [
      //     IconButton(icon: Icon(Icons.done,), onPressed: (){}, padding: EdgeInsets.only(right: 30),)
      //   ],
      // ),
      // extendBodyBehindAppBar: true,
      body: _isLoaded
          ? Builder(
              builder: (context) => Center(
                child: Stack(
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Visibility(
                            visible: _progressVisibility,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          Expanded(
                            child: VideoViewer(),
                          ),
                          Center(
                            child: TrimEditor(
                              viewerHeight: 50.0,
                              viewerWidth: MediaQuery.of(context).size.width,
                              maxVideoLength: Duration(seconds: 30),
                              onChangeStart: (value) {
                                _startValue = value;
                              },
                              onChangeEnd: (value) {
                                _endValue = value;
                              },
                              onChangePlaybackState: (value) {
                                setState(() {
                                  _isPlaying = value;
                                });
                              },
                            ),
                          ),
                          FlatButton(
                            child: _isPlaying
                                ? Icon(
                                    Icons.pause,
                                    size: 80.0,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.play_arrow,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                            onPressed: () async {
                              bool playbackState =
                                  await _trimmer.videPlaybackControl(
                                      startValue: _startValue,
                                      endValue: _endValue);
                              setState(() {
                                _isPlaying = playbackState;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                        child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.done,
                                size: 30,
                              ),
                              onPressed: _progressVisibility
                                  ? null
                                  : () async {
                                      saveTrimmedVideo().then((value) {
                                        print(
                                            "OutPut trimmed Video Path is $value");
                                        Navigator.of(context).pop(value);
                                      });
                                    },
                              padding: EdgeInsets.only(right: 20),
                            ))),
                    SafeArea(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 30,
                              ),
                              onPressed: () => Navigator.of(context).pop(widget.filePath),
                              padding: EdgeInsets.only(left: 20),
                            ))),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }

  Future<String> saveTrimmedVideo() async {
    // final String rand = Uuid().v4();
    // final directory = await getApplicationDocumentsDirectory();
    // final newFilePath = '${directory.path}/$rand.mp4';
    setState(() {
      _progressVisibility = true;
    });
    String _value;
    await _trimmer
        .saveTrimmedVideo(
            startValue: _startValue,
            endValue: _endValue,
            storageDir: StorageDir.temporaryDirectory)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });
    // try {
    //   // prefer using rename as it is probably faster
    //   await File(_value).rename(newFilePath);
    // } on FileSystemException catch (e) {
    //   // if rename fails, copy the source file and then delete it
    //   final newFile = await File(_value).copy(newFilePath);
    //   print("New file ${newFile}");
    //   await File(_value).delete();
    // }
    // Uint8List intFile = await File(_value).readAsBytes();
    // await file.writeAsBytes(intFile);
    print("On complete");
    return _value;
  }
}
