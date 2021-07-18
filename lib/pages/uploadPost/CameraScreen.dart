// @dart=2.9
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:petziee/Editing/EditImage.dart';
import 'package:petziee/UploadingWidget/VideoUpload.dart';
import 'package:petziee/apis/encoding_provider.dart';
import 'package:petziee/models/user.dart';
import 'package:petziee/widgets/phoneDatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart' as lip;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../main.dart';

class CameraPage extends StatefulWidget {
  final User gCurrentUser;
  final bool needScaffold;

  // final Function showSneakBar;

  CameraPage({
    this.needScaffold = false,
    this.gCurrentUser,
  });

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  List<String> imageList = [
    'assets/cm0.jpeg',
    'assets/cm1.jpeg',
    'assets/cm2.jpeg',
    'assets/cm3.jpeg',
    'assets/cm4.jpeg',
    'assets/cm5.jpeg',
    'assets/cm6.jpeg',
    'assets/cm7.jpeg',
    'assets/cm8.jpeg',
    'assets/cm9.jpeg',
  ];

  Random ran = Random();

  // LocalImage image;
  String videoPath;
  CameraController controller;
  bool _cameraNotAvailable = false;
  bool _allowPermission = false;
  bool _hasImage = false;
  int _cameraIndex = 0;
  bool takePhoto = true;
  bool isLoading = true;
  File _imageFile;
  File _videoFile;
  final picker = ImagePicker();
  bool isLastImageVideo = false;
  String videoThumbFilePath;

  double _minAvailableZoom;
  double _maxAvailableZoom;
  double _baseScale = 1.0;
  double _currentScale = 1.0;
  int _pointers = 0;

  // Uint8List localImage;
  LocalImage image;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller != null
          ? _initCamera(_cameraIndex)
          : null; //on pause camera disposed so we need call again "issue is only for android"
    }else{
      controller !=null?
          controller.dispose():null;
    }
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _initCamera(int index) async {
    setState(() {
      isLoading = true;
    });
    await _requestReadWritePermission();
    if (!_hasImage) _getLatestImg();
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameras[index], ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg);

    //If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize().then((value) {
        print("Completed initializonf no return in ght evalue to true ");
        setState(() {
          isLoading = false;
        });
      });

      await Future.wait([
        controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value),
        controller.lockCaptureOrientation(DeviceOrientation.portraitUp),
        controller.getMinZoomLevel().then((value) => _minAvailableZoom = value),
        controller.setFlashMode(FlashMode.off),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {
        _cameraIndex = index;
      });
    }
  }

  logError(String code, String description) {
    print('Error: $code\nMessage: $description');
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    // _showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  _requestReadWritePermission() async {
    // if (await Permission.storage.request().isGranted) {
    //   // Either the permission was already granted before or the user just granted it.
    //   setState(() {
    //     _allowPermission = true;
    //   });
    // }

// You can request multiple permissions at once.

    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();
    print(statuses[Permission.location]);
    if (await Permission.storage.request().isGranted &&
        await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted &&
        await Permission.photos.request().isGranted) {
      // PhoneDatabase.saveIsPermissionGiven(true);
      setState(() {
        _allowPermission = true;
      });
    }
    // setState(() {
    //   _allowPermission = true;
    // });
  }

  @override
  void initState() {
    super.initState();


    print('Cameras in CameraScreen : ${cameras.length}');
    if (cameras == null || cameras.isEmpty) {
      setState(() {
        _cameraNotAvailable = true;
      });
    }
    _initCamera(_cameraIndex);
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<XFile> _takePicture() async {
    if (!controller.value.isInitialized || controller.value.isTakingPicture) {
      _showInSnackBar('Please reopen the page');
      return null;
    }

    try {
      XFile file = await controller.takePicture();
      PhoneDatabase.saveDrawingImageCounter(0);
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> _startVideoRecording() async {
    if (!controller.value.isInitialized) {
      _showInSnackBar('Please Wait');
      return;
    }

    //Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      return;
    }

    // final Directory appDirectory = await getApplicationDocumentsDirectory();
    // final String videoDirectory = '${appDirectory.path}/Videos';
    // await new Directory(videoDirectory).create(recursive: true);
    // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      return controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  // Widget _buildGalleryBar(){
  //   final barHeight = 90.0;
  //   final vertPadding = 10.0;
  //
  //   return Container(
  //     height: barHeight,
  //     child: ListView.builder(
  //       padding: EdgeInsets.symmetric(vertical: vertPadding),
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (BuildContext context, int _){
  //         return Container(
  //           padding: EdgeInsets.only(right: 5.0),
  //           width: 70.0,
  //           height: barHeight - vertPadding*2,
  //           child: Image(
  //             //TODO: Use the gallery photos in list view
  //             image: AssetImage(imageList[ran.nextInt(9)]),
  //             fit: BoxFit.cover,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  //

  void _onSwitchCamera() {
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    final newIndex = _cameraIndex + 1 == cameras.length ? 0 : _cameraIndex + 1;
    _initCamera(newIndex);
  }

  pickImageFromGallery() async {
    //Navigator.pop(context);
    final image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 90);
    setState(() {
      _imageFile = File(image.path);
    });

    // Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageUpload(filePath: _imageFile.path, gCurrentUser: widget.gCurrentUser, isChat: false,)));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditImage(
                filePath: _imageFile.path, gCurrentUser: widget.gCurrentUser)));
  }

  pickVideoFromGallery() async {
    // Navigator.pop(context);
    final video = await ImagePicker().getVideo(
      source: ImageSource.gallery,
    );
    setState(() {
      _videoFile = File(video.path);
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoUpload(
                  filePath: _videoFile.path,
                  isChat: false,
                  // showSneakBar: widget.showSneakBar,
                )));
  }

  saveData(String fp) async {
    await PhoneDatabase.saveFilePath(fp);
  }

  void _onTakePictureButtonPress() {
    _takePicture().then((file) {
      //If the error occurs then it may be because of the mounted and still pushing to other screen
      if (mounted) {
        saveData(file.path);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditImage(
                    filePath: file.path, gCurrentUser: widget.gCurrentUser,isTaken:true)));
      }

      // Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageUpload(filePath: filePath, gCurrentUser: widget.gCurrentUser,isChat: false,)));

      // DrawingWidget()
    });
  }

  void _onTakeVideoButtonPress() {
    _startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onStopButtonPressed() {
    _stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        // _showInSnackBar("Video Recorded to ${file.path}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoUpload(
                      filePath: file.path,
                      isChat: false,
                    )));
      }
    });
  }

  Widget _buildTopControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            if (controller?.value?.flashMode == FlashMode.off)
              IconButton(
                padding: EdgeInsets.only(right: 20, bottom: 10),
                color: Colors.white,
                icon: Icon(Icons.flash_off_outlined),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                    : null,
              ),
            if (controller?.value?.flashMode == FlashMode.auto)
              IconButton(
                padding: EdgeInsets.only(right: 20, bottom: 10),
                color: Colors.white,
                icon: Icon(Icons.flash_auto_outlined),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.always)
                    : null,
              ),
            if (controller?.value?.flashMode == FlashMode.always)
              IconButton(
                padding: EdgeInsets.only(right: 20, bottom: 10),
                color: Colors.white,
                icon: Icon(Icons.flash_on_outlined),
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.off)
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      // _showInSnackBar("FlashMode set To ${mode.toString().split('.').last}");
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }


  Future<void> _getLatestImg() async {
    lip.LocalImageProvider imageProvider = lip.LocalImageProvider();

    print("Allow permission $_allowPermission");
    bool hasPermission = await imageProvider.initialize();
    if (hasPermission && _allowPermission) {
      List<LocalImage> images = await imageProvider.findLatest(1);
      if (images.isNotEmpty) {
        if (images.first.isImage) {
          setState(() {
            image = images.first;
            _hasImage = true;
            isLastImageVideo = false;
          });
        } else {
          final videoPath = await imageProvider.videoFile(images.first.id);
          final thumbFilePath = await EncodingProvider.getThumb(videoPath, 300);
          setState(() {
            videoThumbFilePath = thumbFilePath;
            _hasImage = true;
            isLastImageVideo = true;
          });
        }
        print("Image is $image");
      } else {
        setState(() {
          _hasImage = false;
        });
        print("No Images found on the device");
      }
    } else {
      setState(() {
        _hasImage = false;
      });
      print("User Permission Denied from accessing the image");
      await _requestReadWritePermission();
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      // _showInSnackBar('Video Recording resumed');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((file) {
      if (mounted) setState(() {});
      // _showInSnackBar("Video Recording paused");
    });
  }

  Widget _buildControlBar() {
    print('has image $_hasImage');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: takePhoto ? pickImageFromGallery : pickVideoFromGallery,
            child: Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  image:
                      //           DecorationImage(
                      //               image: !(_hasImage)
                      //                   ?AssetImage('assets/cm9.jpeg')
                      //                   :Image.memory(localImage),
                      //             fit: BoxFit.cover,
                      //           ),
                      DecorationImage(
                    image: !(_hasImage)
                        ? AssetImage('assets/cal1.png')
                        : isLastImageVideo
                            ? FileImage(File(videoThumbFilePath), scale: 1)
                            : DeviceImage(
                                image,
                                scale: 1,
                              ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(.8),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                )),
          ),
        ),
        Spacer(
          flex: 5,
        ),
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: takePhoto
                ? _onTakePictureButtonPress
                : !controller.value.isRecordingVideo
                    ? _onTakeVideoButtonPress
                    : _onStopButtonPressed,
            child: takePhoto
                ? Container(
                    height: 80.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 5.0,
                        )),
                  )
                : Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3.0,
                      ),
                    ),
                    height: 80,
                    width: 80,
                    child:
                        controller != null && !controller.value.isRecordingVideo
                            ? Container(
                                margin: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              )
                            : Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              )),
          ),
        ),
        takePhoto
            ? IconButton(
                color: Colors.white,
                padding: EdgeInsets.only(right: 10, left: 20),
                icon: Icon(Icons.videocam_outlined),
                onPressed: () {
                  setState(() {
                    takePhoto = !takePhoto;
                  });
                  if (!takePhoto) {
                    controller.prepareForVideoRecording();
                  }
                },
              )
            : !controller.value.isRecordingVideo &&
                    !controller.value.isRecordingPaused
                ? IconButton(
                    color: Colors.white,
                    padding: EdgeInsets.only(right: 10, left: 20),
                    icon: Icon(Icons.camera_alt_outlined),
                    onPressed: () {
                      setState(() {
                        takePhoto = !takePhoto;
                      });
                    },
                  )
                : IconButton(
                    padding: EdgeInsets.only(right: 10, left: 20),
                    icon:
                        controller != null && controller.value.isRecordingPaused
                            ? Icon(Icons.play_arrow)
                            : Icon(Icons.pause),
                    color: Colors.blue,
                    onPressed: controller != null &&
                            controller.value.isInitialized &&
                            controller.value.isRecordingVideo
                        ? (controller != null &&
                                controller.value.isRecordingPaused
                            ? onResumeButtonPressed
                            : onPauseButtonPressed)
                        : null,
                  ),
        Spacer(
          flex: 1,
        ),
        takePhoto ||
                (!controller.value.isRecordingVideo &&
                    !controller.value.isRecordingPaused)
            ? IconButton(
                padding: EdgeInsets.only(left: 20),
                color: Colors.white,
                icon: Icon(Icons.switch_camera_outlined),
                onPressed: _onSwitchCamera,
              )
            : IconButton(
                padding: EdgeInsets.only(left: 20),
                icon: Icon(Icons.stop),
                color: Colors.red,
                onPressed: controller != null &&
                        controller.value.isInitialized &&
                        controller.value.isRecordingVideo
                    ? _onStopButtonPressed
                    : null,
              ),
        Spacer(
          flex: 2,
        ),
      ],
    );
  }

  Widget _cameraPreviewWidget() {
    if (isLoading) {
      return Center(
        child: Text(
          "Loading Preview...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    } else {
      // final size = MediaQuery.of(context).size;
      // var scale = size.aspectRatio * controller.value.aspectRatio;
      // if (scale < 1) scale = 1 / scale;

      // final size = MediaQuery.of(context).size;
      // var xScale = 1.0;
      // if(controller.value.isInitialized)xScale = controller.value.aspectRatio/ size.aspectRatio;
      // if(xScale<1)xScale = 1/xScale;
      // final yScale = 1.0;
      // scale: 1  (size.aspectRatio * controller.value.aspectRatio),
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child:  NativeDeviceOrientationReader(
          builder: (context){
            NativeDeviceOrientation orientation =
                NativeDeviceOrientationReader.orientation(context);

            int turns;

            switch(orientation){
              case NativeDeviceOrientation.landscapeLeft:
                turns = -1;
                break;
              case NativeDeviceOrientation.landscapeRight:
                turns = 1;
                break;
              case NativeDeviceOrientation.portraitDown:
                turns  = 2;
                break;
              default:
                turns = 0;
                break;
            }

            return  Center(
              child: CameraPreview(
                controller,
                child: LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      onTapDown: (details) =>
                          onViewFinderTap(details, constraints),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }


  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    print("Focus offset is ${offset} ");
    controller.setFocusPoint(offset);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    //When the are not exactly two fingers on the screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraNotAvailable) {
      final center = Center(
        //TODO: Add Lotti file if the camera is not available
        child: Text('Camera Not Available'),
      );
      if (widget.needScaffold) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(),
          body: center,
        );
      }
      return center;
    }
    final stack = Stack(
      children: [
        Center(
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: _cameraPreviewWidget())),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 45),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildTopControlBar(),
              // Spacer(),
              // _buildGalleryBar(),
              _buildControlBar(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child:
                    takePhoto ? Text('Tap for photo') : Text("Tap for Video"),
              )
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: stack,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    image = null;
    if (controller != null) {
      controller.dispose();
    }
  }
}
