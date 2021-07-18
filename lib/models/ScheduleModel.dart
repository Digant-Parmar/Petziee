// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:petziee/colors/Themes.dart';
import 'package:petziee/pages/Overview/Schedule/EditSchedulePage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ScheduleModel extends StatefulWidget {
  final String type;
  final String petName;
  final String message;
  final Timestamp time;
  final Timestamp startDate;
  final Timestamp endDate;
  final int notificationId;
  final int gradiantNumber;
  final String documentId;

  ScheduleModel(
      {this.type,
      this.petName,
      this.message,
      this.time,
      this.startDate,
      this.endDate,
      this.notificationId,
        this.documentId,
      this.gradiantNumber});

  factory ScheduleModel.fromDocument(DocumentSnapshot dox, int gradiantNumber) {
    return ScheduleModel(
      type: dox.get("type"),
      time: dox.get("time"),
      petName: dox.get("petName"),
      startDate: dox.get("startDate"),
      endDate: dox.get("endDate"),
      message: dox.get("message"),
      notificationId: dox.get("notificationId"),
      gradiantNumber: gradiantNumber,
      documentId: dox.id,
    );
  }

  @override
  _ScheduleModelState createState() => _ScheduleModelState();
}

class _ScheduleModelState extends State<ScheduleModel> {
  final d = new DateFormat('dd/MM/yy');
  final t = new DateFormat.Hm();

  List<Color> colors = [];

  initialize()async{
    tz.initializeTimeZones();
    final String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  @override
  void initState() {
    initialize();
    switch (widget.gradiantNumber) {
      case 1:
        setState(() {
          colors = GradientColors.sky;
        });
        break;
      case 2:
        setState(() {
          colors = GradientColors.sunset;
        });
        break;
      case 3:
        setState(() {
          colors = GradientColors.sea;
        });
        break;
      case 4:
        setState(() {
          colors = GradientColors.mango;
        });
        break;
      case 5:
        setState(() {
          colors = GradientColors.fire;
        });
        break;
      default:
        setState(() {
          colors = GradientColors.sunset;
        });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => sendToEditSchedulePage(),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints.expand(height: 110),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          // boxShadow: [
          //   BoxShadow(
          //     offset: const Offset(4.0, 4.0),
          //     color: colors.last.withOpacity(0.4),
          //     blurRadius: 8,
          //     spreadRadius: 0.2,
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Color(0xFF2D2F41),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    widget.type,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  widget.petName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 1.9),
                  child: Text(
                    widget.message,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: widget.type != "Vaccine"
                  ? Text(

                (DateFormat.jm().format(widget.time.toDate())).toString(),
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          d.format(widget.startDate.toDate()),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          (DateFormat.jm().format(widget.time.toDate())).toString(),

                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  sendToEditSchedulePage() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditSchedulePage(
              isEdit: true,
          scheduleModel: ScheduleModel(
            type: widget.type,
            time:widget.time,
            petName: widget.petName,
            startDate: widget.startDate,
            endDate: widget.endDate,
            message: widget.message,
            notificationId: widget.notificationId,
            gradiantNumber: widget.gradiantNumber,
            documentId: widget.documentId,
          ),
            )));
  }
}
