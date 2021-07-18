// @dart=2.9
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:petziee/colors/Themes.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';

import 'SchedulePage.dart';

class TimeScheduler extends StatefulWidget {
  final String title;

  const TimeScheduler({Key key, this.title}) : super(key: key);

  @override
  _TimeSchedulerState createState() => _TimeSchedulerState();
}

class _TimeSchedulerState extends State<TimeScheduler> with TickerProviderStateMixin{

  // AnimationController _controller;

  final Shader linearGradientSea = LinearGradient(colors: GradientColors.sea).createShader(Rect.fromLTWH(0.0, 0.0, 150, 50));
  final Shader linearGradientSky = LinearGradient(colors: GradientColors.sunset).createShader(Rect.fromLTWH(0.0, 0.0, 140, 200));

  bool _showFrontSide;
  bool _flipXAxis;

  Timer timer;
  bool _isSchedulePresent = false;
  String _type = "Meal";

  int endTime =DateTime.now().add(Duration(minutes: 36)).millisecondsSinceEpoch;

  Future<void>getTIme()async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("schedule").doc("userSchedules").collection(currentUser.id).orderBy("time",descending: true).get();
    if(querySnapshot.docs !=null && querySnapshot.docs.isNotEmpty){
      Timestamp min = querySnapshot.docs.first.get("time");
      String temp = "Meal";
      for(DocumentSnapshot element in querySnapshot.docs){
        Timestamp value = element.get("time");
        if(value.toDate().isAfter(DateTime.now()) && value.toDate().isBefore(min.toDate())){
          min = value;
          temp = element.get("type");
        }
      }
      DateTime _time = min.toDate();
      print(querySnapshot.docs.first.get("type"));
      print(querySnapshot.docs.first.get("time"));
      if(_time.isBefore(DateTime.now())){
        setState(() {
          _isSchedulePresent = true;
          _type = temp;
          endTime = _time.add(Duration(days: 1)).millisecondsSinceEpoch;
          print("${DateTime.fromMillisecondsSinceEpoch(endTime)} Time");
        });
      }else{
        setState(() {
          _isSchedulePresent = true;
          _type = temp;
          endTime = _time.millisecondsSinceEpoch;
          print("${DateTime.fromMillisecondsSinceEpoch(endTime)} Time");
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _showFrontSide = true;
    _flipXAxis = true;
    Future.wait([getTIme()]).then((value){
      timer = Timer.periodic(Duration(seconds: 3), (timer)=>_switchCard());
    });
    // _controller = AnimationController(vsync: this,duration: Duration(days: 5));
    // _controller.forward();
  }

  @override
  void dispose() {
    if(timer!=null){
      timer.cancel();
    }
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/timeScheduler.jpg"), context);
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints.tight(Size.square(200.0)),
          child: _buildFlipAnimation(),
        ),
      ),
    );
  }

  void _changeRotationAxis() {
    setState(() {
      _flipXAxis = !_flipXAxis;
    });
  }

  void _switchCard() {
    setState(() {
      _showFrontSide = !_showFrontSide;
    });
  }


  sendToSchedulePage(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SchedulePage()));
  }

  Widget _buildFlipAnimation() {
    return GestureDetector(
      onTap: (){
        print("Pressed");
        sendToSchedulePage();
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        transitionBuilder: __transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget, ...list]),
        child: _showFrontSide ? _buildFront() : _buildRear(),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
      ),
    );
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_showFrontSide) != widget.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: _flipXAxis
              ? (Matrix4.rotationY(value)..setEntry(3, 0, tilt))
              : (Matrix4.rotationX(value)..setEntry(3, 1, tilt)),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  Widget _buildFront() {
    return  Container(
      key: ValueKey(true),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color:  Color(0xFF2D2F41),
        borderRadius: BorderRadius.circular(20.0),

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Center(
          child: Image.asset("assets/timeScheduler.jpg",fit: BoxFit.contain,),
        ),
      ),
    );
  }

  Widget _buildRear() {

    return Container(
      key: ValueKey(false),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        color:  Color(0xFF2D2F41),
      ),
      child: Center(
        child: CountdownTimer(
          endTime: endTime,
          textStyle: TextStyle(
            fontSize: 20
          ),
          widgetBuilder:(context, time) {
            if (time == null) {
              return endWidget();
            }
            String value = '';
            String daysString;
            if (time.days != null) {
              var days = _getNumberAddZero(time.days);
              daysString = '$days';
            }
            var hours = _getNumberAddZero(time.hours ?? 0);
            value = '$value$hours : ';
            var min = _getNumberAddZero(time.min ?? 0);
            value = '$value$min : ';
            var sec = _getNumberAddZero(time.sec ?? 0);
            value = '$value$sec';
            return time.days!=null?Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('$daysString Days',
                  style: TextStyle(
                      foreground: Paint()..shader = linearGradientSky,
                    fontSize: 18
                  ),
                ),
                Divider(),
                Text(
                  value,
                  style: TextStyle(
                      foreground: Paint()..shader = linearGradientSea,
                      fontSize: 18

                  ),
                ),
              ],
            ):Text(
              value,
              style: TextStyle(
                foreground: Paint()..shader = linearGradientSea,
                  fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
    );
    // return __buildLayout(
    //   key: ValueKey(false),
    //   backgroundColor: Colors.blue.shade700,
    //   faceName: "",
    //   child: Padding(
    //     padding: EdgeInsets.all(20.0),
    //     child: ColorFiltered(
    //       colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
    //       child: Center(child: Text("Flutter", style: TextStyle(fontSize: 50.0))),
    //     ),
    //   ),
    // );
  }

  Widget endWidget(){
    return _isSchedulePresent?Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Time for',
          style: TextStyle(
              foreground: Paint()..shader = linearGradientSky,
              fontSize: 18
          ),
        ),
        Divider(),
        Text(
          _type,
          style: TextStyle(
              foreground: Paint()..shader = linearGradientSea,
              fontSize: 18
          ),
        ),
      ],
    ):Text(
      "Create new",
      style: TextStyle(
        foreground: Paint()..shader = linearGradientSea,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget __buildLayout({Key key, Widget child, String faceName, Color backgroundColor}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(faceName, style: TextStyle(fontSize: 80.0)),
      ),
    );
    // return Container(
    //   key: key,
    //   decoration: BoxDecoration(
    //     color: backgroundColor,
    //     borderRadius: BorderRadius.circular(12.0),
    //   ),
    //   child: Stack(
    //     fit: StackFit.expand,
    //     children: [
    //       child,
    //       Positioned(
    //         bottom: 8.0,
    //         right: 8.0,
    //         child: Text(faceName),
    //       ),
    //     ],
    //   ),
    // );
  }
  String _getNumberAddZero(int number) {
    if (number < 10) {
      return "0" + number.toString();
    }
    return number.toString();
  }
}



class Countdown extends AnimatedWidget{
  Countdown({this.animation, Key key}):super(key: key,listenable: animation);
  Animation<int> animation;

  @override
  Widget build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);



    String timerText = clockTimer.toString()
        .split('.').first.padLeft(8, "0");

    if(clockTimer.inDays>0 && clockTimer.inDays<31){

    }
    else if(clockTimer.inDays > 30){
      int months = clockTimer.inDays~/30;
      int days = clockTimer.inDays - (30*months);
      timerText = '$months:$days';
    }

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 20,
      ),
    );
  }
}