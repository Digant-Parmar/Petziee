// @dart=2.9

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petziee/widgets/phoneDatabase.dart';

import 'EditImage.dart';


Canvas mainCanvas;

class DrawingWidget extends StatefulWidget {

  final String filePath;

  DrawingWidget({this.filePath});

  @override
  _DrawingWidgetState createState() => _DrawingWidgetState();
}

class _DrawingWidgetState extends State<DrawingWidget> {

  String filePath;
  String path;
  int c;
  int counter;

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];
  bool showBar = true;

  getData()async{
    Directory d  = await getApplicationDocumentsDirectory();
    int z =  await PhoneDatabase.getDrawingImageCounter();
    setState(() {
      counter =z;
      c = z;
      path = d.path;
    });
    print("List is: ${d.list().toList()}");
  }

  @override
  void initState() {
    setState(() {
      filePath = widget.filePath;
    });
    getData();

    super.initState();
  }

  Future<bool>_onWillPop()async{
    return false;
  }

  undo()async{
    if((c-1)>0) {
      int y = c - 1;
      setState(() {
        filePath = '$path/DrawingImage$y';
        c = y;
      });
    }
  }
  redo()async{
    if((c+1)<counter) {
      int y = c + 1;
      setState(() {
        filePath = '$path/DrawingImage$y';
        c = y;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar:showBar? AppBar(
          leading: Container(
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: Colors.white,),
              onPressed: (){
                setState(() {
                  Navigator.pop(
                    context,widget.filePath );
                });
              },
            ),
          ),
          backgroundColor: Colors.transparent,
          // toolbarOpacity: 0,
          // bottomOpacity: 0,
          actions: [

            IconButton(
              alignment: Alignment.center,
              icon: Icon(Icons.undo_rounded),
              onPressed: undo,
            ),
            IconButton(
              alignment: Alignment.center,
              icon: Icon(Icons.redo_rounded),
              onPressed: redo,
            ),

            IconButton(
              alignment: Alignment.centerRight,
              icon: Icon(Icons.done_rounded),
              onPressed: (){
                _capturePng().then((value){
                  print("FilePath is $value");
                  Navigator.pop(
                    context,value);
                });
              },
            ),
          ],

        ):null,
        extendBodyBehindAppBar: true,
        extendBody: true,
        bottomNavigationBar:showBar? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.album),
                            onPressed: () {
                              setState(() {
                                selectedMode = SelectedMode.StrokeWidth;

                                if (selectedMode == SelectedMode.StrokeWidth)
                                  showBottomList = !showBottomList;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.opacity),
                            onPressed: () {
                              setState(() {
                                selectedMode = SelectedMode.Opacity;

                                if (selectedMode == SelectedMode.Opacity)
                                  showBottomList = !showBottomList;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.color_lens),
                            onPressed: () {
                              setState(() {
                                selectedMode = SelectedMode.Color;

                                if (selectedMode == SelectedMode.Color)
                                  showBottomList = !showBottomList;
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.clear),
                            onPressed:
                            // _capturePng
                                () {
                              setState(() {
                                showBottomList = false;
                                points.clear();
                              });
                            }
                        ),
                      ],
                    ),
                    Visibility(
                      child: (selectedMode == SelectedMode.Color)
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getColorList(),
                      )
                          : Slider(
                          value: (selectedMode == SelectedMode.StrokeWidth)
                              ? strokeWidth
                              : opacity,
                          max: (selectedMode == SelectedMode.StrokeWidth)
                              ? 50.0
                              : 1.0,
                          min: 0.0,
                          onChanged: (val) {
                            setState(() {
                              if (selectedMode == SelectedMode.StrokeWidth)
                                strokeWidth = val;
                              else
                                opacity = val;
                            });
                          }),
                      visible: showBottomList,
                    ),
                  ],
                ),
              )),
        ):null,
        body: GestureDetector(
          onPanDown: (details) {
            setState(() {
              showBar = false;
              RenderBox renderBox = context.findRenderObject();
              points.add(DrawingPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = selectedColor.withOpacity(opacity)
                    ..strokeWidth = strokeWidth));
            });
          },
          onPanUpdate: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject();
              points.add(DrawingPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = selectedColor.withOpacity(opacity)
                    ..strokeWidth = strokeWidth));
            });
          },
          onPanStart: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject();
              points.add(DrawingPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = selectedColor.withOpacity(opacity)
                    ..strokeWidth = strokeWidth));
            });
          },
          onPanEnd: (details) {
            setState(() {
              showBar = true;
              points.add(null);
            });
          },
          child: RepaintBoundary(
            key: _globalKey,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Image(image: FileImage(File(filePath)),),
                ),
                CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: DrawingPainter(
                    pointsList: points,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool inside = false;

  GlobalKey _globalKey = new GlobalKey();

  Future<String> _capturePng() async {
    String editedFilePath;
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      int i = await PhoneDatabase.getDrawingImageCounter();
//      String bs64 = base64Encode(pngBytes);
//      print(pngBytes);
//      print(bs64);
      print('png done');
      editedFilePath = '$path/DrawingImage$i';
      setState(() {
        File(editedFilePath).writeAsBytesSync(pngBytes);
        inside = false;
      });
      await PhoneDatabase.saveDrawingImageCounter(i+1);
      return editedFilePath;
    } catch (e) {
      print(e);
    }
    return editedFilePath;

  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          builder: (context){
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    pickerColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() => selectedColor = pickerColor);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
          context: context,

        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                 // [Colors.red, Colors.green, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.green, Colors.blue],
                // colors,
              )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}



class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;


  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [pointsList[i].points], pointsList[i].paint);
      }
    }
    mainCanvas = canvas;

  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;

}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }

