// @dart=2.9
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:petziee/models/ScheduleModel.dart';
import 'package:petziee/widgets/UpdateCurrentUser.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    FlutterLocalNotificationsPlugin().cancel(inputData["id"]);
    print("Id is ${inputData["id"]}");
    return Future.value(true);
  });
}

class EditSchedulePage extends StatefulWidget {
  final bool isEdit;
  final ScheduleModel scheduleModel;

  const EditSchedulePage({
    Key key,
    this.isEdit,
    this.scheduleModel,
  }) : super(key: key);

  @override
  _EditSchedulePageState createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  double kFontSize = 18;
  String _selectedScheduleType = "Meal";
  String _selectedPet;
  bool _isTimeSelectedForMeal = false;
  bool _isTimeSelectedForVaccine = false;
  bool _isTimeSelectedForMedicine = false;

  bool _isDateSelectedForMedicineStart = false;
  bool _isDateSelectedForMedicineEnd = false;
  bool _isDateSelectedForVaccine = false;

  bool _isLoading = false;

  final dateFormat = new intl.DateFormat('dd/MM/yy');

  TimeOfDay selectedTimeForMeal = TimeOfDay.now();
  TimeOfDay selectedTimeForVaccine = TimeOfDay.now();
  TimeOfDay selectedTimeForMedicine = TimeOfDay.now();

  DateTime selectedDateForMedicineStart = DateTime.now();
  DateTime selectedDateForMedicineEnd = DateTime.now();
  DateTime selectedDateForVaccine = DateTime.now();

  TextEditingController messageController = TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  initialize() async {
    tz.initializeTimeZones();
    final String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
    //
    // await flutterLocalNotificationsPlugin.pendingNotificationRequests().then((value) {
    //   print("in");
    //   value.forEach((element) {
    //     print(element.id);
    //
    //   });
    // });
  }

  @override
  void initState() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initialize();
    if (widget.isEdit) {
      setState(() {
        _selectedPet = widget.scheduleModel.petName;
        _selectedScheduleType = widget.scheduleModel.type;
        messageController.text = (widget.scheduleModel.message);
      });

      switch (widget.scheduleModel.type) {
        case "Meal":
          setState(() {
            _isTimeSelectedForMeal = true;
            selectedTimeForMeal = TimeOfDay(
                hour: widget.scheduleModel.time.toDate().hour,
                minute: widget.scheduleModel.time.toDate().minute);
          });
          break;
        case "Vaccine":
          setState(() {
            _isDateSelectedForVaccine = true;
            _isTimeSelectedForVaccine = true;
            selectedDateForVaccine = widget.scheduleModel.startDate.toDate();
            selectedTimeForVaccine = TimeOfDay(
                hour: widget.scheduleModel.time.toDate().hour,
                minute: widget.scheduleModel.time.toDate().minute);
          });
          break;
        case "Medicine":
          setState(() {
            _isTimeSelectedForMedicine = true;
            _isDateSelectedForMedicineEnd = true;
            _isDateSelectedForMedicineStart = true;
            selectedTimeForMedicine = TimeOfDay(
                hour: widget.scheduleModel.time.toDate().hour,
                minute: widget.scheduleModel.time.toDate().minute);
            selectedDateForMedicineStart =
                widget.scheduleModel.startDate.toDate();
            selectedDateForMedicineEnd = widget.scheduleModel.endDate.toDate();
          });
          break;
      }
    } else {
      _selectedScheduleType = "Meal";
    }

    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? "Edit schedule" : "Create Schedule",
        ),
        backgroundColor: Color(0xFF2D2F41),
      ),
      backgroundColor: Color(0xFF2D2F41),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Form(
            child: Stack(
              children: [
                ListView(shrinkWrap: true, children: [
                  CustomDropdownButton<String>(
                    hint: widget.isEdit
                        ? Text(widget.scheduleModel.type)
                        : Text("Select the schedule type (Meal)"),
                    iconSize: 30,
                    style: TextStyle(fontWeight: FontWeight.w500),
                    value: _selectedScheduleType,
                    items: <String>['Meal', 'Vaccine', 'Medicine']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: new Text(
                          value,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                      );
                    }).toList(),
                    onChanged: (String val) {
                      setState(() {
                        _selectedScheduleType = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  CustomDropdownButton<String>(
                    hint: widget.isEdit
                        ? Text(widget.scheduleModel.petName)
                        : Text("Select the pet"),
                    iconSize: 30,
                    style: TextStyle(fontWeight: FontWeight.w500),
                    value: _selectedPet,
                    items: <String>['Hello', 'See', 'You', 'There']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: new Text(
                          value,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                      );
                    }).toList(),
                    onChanged: (String val) {
                      setState(() {
                        _selectedPet = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Message",
                    ),
                  ),
                  getTimeSelector(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => createSchedule(),
                        child: Container(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, right: 30, left: 30),
                            margin: EdgeInsets.only(top: 70),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                              ),
                            ),
                            child: Text(
                              widget.isEdit
                                  ? "Update Schedule"
                                  : "Create Schedule",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                  widget.isEdit
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => deleteSchedule(),
                              child: Container(
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, right: 20, left: 20),
                                  margin: EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Text(
                                    "Delete",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  )),
                            ),
                          ],
                        )
                      : Container(),
                ]),
                _isLoading
                    ? Align(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: LottieBuilder.network(
                            "https://assets3.lottiefiles.com/packages/lf20_nuvl0u2v.json",
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getTimeSelector() {
    switch (_selectedScheduleType) {
      case "Meal":
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _selectTime(context, selectedTimeForMeal).then((value) {
                  if (value != null) {
                    setState(() {
                      selectedTimeForMeal = value;
                      _isTimeSelectedForMeal = true;
                    });
                  }
                });
              },
              child: Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: _isTimeSelectedForMeal
                      ? Text(
                          selectedTimeForMeal.format(context),
                          style: TextStyle(
                              fontSize: kFontSize, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "Click here to select the time",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
            ),
          ],
        );
      case "Medicine":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () {
                  _selectDate(context, selectedDateForMedicineStart)
                      .then((value) {
                    if (value != null) {
                      setState(() {
                        selectedDateForMedicineStart = value;
                        _isDateSelectedForMedicineStart = true;
                      });
                    }
                  });
                },
                child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: _isDateSelectedForMedicineStart
                        ? Text(
                            dateFormat.format(selectedDateForMedicineStart),
                            style: TextStyle(
                                fontSize: kFontSize, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "Start",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )),
              ),
            ),

            Flexible(
              child: GestureDetector(
                onTap: () {
                  _selectDate(context, selectedDateForMedicineEnd).then((value) {
                    if (value != null) {
                      if(selectedDateForMedicineStart.isBefore(value)){
                        setState(() {
                          selectedDateForMedicineEnd = value;
                          _isDateSelectedForMedicineEnd = true;
                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select a proper range of dates"),
                            backgroundColor: Colors.red,
                            elevation: 5.0,
                            behavior: SnackBarBehavior.floating,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        );
                      }
                    }
                  });
                },
                child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: _isDateSelectedForMedicineEnd
                        ? Text(
                            dateFormat.format(selectedDateForMedicineEnd),
                            style: TextStyle(
                                fontSize: kFontSize, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "End",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  _selectTime(context, selectedTimeForMedicine).then((value) {
                    if (value != null) {
                      setState(() {
                        selectedTimeForMedicine = value;
                        _isTimeSelectedForMedicine = true;
                      });
                    }
                  });
                },
                child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: _isTimeSelectedForMedicine
                        ? Text(
                            selectedTimeForMedicine.format(context),
                            style: TextStyle(
                                fontSize: kFontSize, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "Time",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )),
              ),
            ),
          ],
        );
      case "Vaccine":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _selectDate(context, selectedDateForVaccine).then((value) {
                  if (value != null) {
                    setState(() {
                      selectedDateForVaccine = value;
                      _isDateSelectedForVaccine = true;
                    });
                  }
                });
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: _isDateSelectedForVaccine
                      ? Text(
                          dateFormat.format(selectedDateForVaccine),
                          style: TextStyle(
                              fontSize: kFontSize, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "Date",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
            ),
            GestureDetector(
              onTap: () {
                _selectTime(context, selectedTimeForVaccine).then((value) {
                  if (value != null) {
                    setState(() {
                      selectedTimeForVaccine = value;
                      _isTimeSelectedForVaccine = true;
                    });
                  }
                });
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: _isTimeSelectedForVaccine
                      ? Text(
                          selectedTimeForVaccine.format(context),
                          style: TextStyle(
                              fontSize: kFontSize, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "Time",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
            ),
          ],
        );
      default:
        return GestureDetector(
          onTap: () {
            _selectTime(context, selectedTimeForMeal).then((value) {
              if (value != null) {
                setState(() {
                  selectedTimeForMeal = value;
                  _isTimeSelectedForMeal = true;
                });
              }
            });
          },
          child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                ),
              ),
              child: _isTimeSelectedForMeal
                  ? Text(
                      selectedTimeForMeal.format(context),
                      style:
                          TextStyle(fontSize: kFontSize, color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      "Click here to select the time",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    )),
        );
    }
  }

  Future<DateTime> _selectDate(
      BuildContext context, DateTime givenDateTime) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: givenDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null && picked != givenDateTime) {
      return picked;
    }
    return null;
  }

  RepeatInterval repeatInterval(int id, int minute) {
    print("IN repetate");
    DateTime dt = DateTime.now();
    print("Date Time is ${dt.toString()}");
    if (minute == dt.minute) {
      print("In if statemate");
      flutterLocalNotificationsPlugin.cancel(id);
      return null;
    }
    return RepeatInterval.everyMinute;
  }

  createSchedule() async {
    // await flutterLocalNotificationsPlugin.cancelAll();
    //
    if(_selectedPet ==null || _selectedPet.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select pet."),
          backgroundColor: Colors.red,
          elevation: 5.0,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
     return;
    }

    setState(() {
      _isLoading = true;
    });
    //
    // print("TZ : ${tz.TZDateTime(tz.local,tz.TZDateTime.now(tz.local).year,tz.TZDateTime.now(tz.local).month,tz.TZDateTime.now(tz.local).day,tz.TZDateTime.now(tz.local).hour,tz.TZDateTime.now(tz.local).minute)}");
    // print("DateTime : ${DateTime.now()}");
    // print("TimeStamp : ${Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDate()}");
    // print("After edition");
    // print("TZ : ${tz.TZDateTime(tz.local,tz.TZDateTime.now(tz.local).year,tz.TZDateTime.now(tz.local).month,tz.TZDateTime.now(tz.local).day,selectedTimeForMeal.hour,selectedTimeForMeal.minute)}");
    // print("DateTime : ${DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,selectedTimeForMeal.hour,selectedTimeForMeal.minute)}");
    // print("TimeStamp : ${Timestamp.fromMillisecondsSinceEpoch(tz.TZDateTime(tz.local,tz.TZDateTime.now(tz.local).year,tz.TZDateTime.now(tz.local).month,tz.TZDateTime.now(tz.local).day,selectedTimeForMeal.hour,selectedTimeForMeal.minute).millisecondsSinceEpoch).toDate()}");


    var uuid = Uuid();
    String documentId = uuid.v4();

    // var scheduledNotificationDateTime = selectedTimeForMeal;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Schedule',
      "Schedule Notifications",
      "Here you will recive the notification regarding the schedules you have created",
      importance: Importance.high,
      color: Color(0xFFFFB463),
      ledOnMs: 100,
      ledOffMs: 100,
      enableLights: true,
      ledColor: Colors.red,
      // additionalFlags:  Int32List.fromList(<int>[android.colorized]),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //         documentId.hashCode,
    //         "Meal",
    //         messageController.text,
    //         _nextInstanceOfTime(),
    //         platformChannelSpecifics,
    //         uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.absoluteTime,
    //         androidAllowWhileIdle: true,
    //   matchDateTimeComponents: DateTimeComponents.time,
    //       );
    switch (_selectedScheduleType) {
      case "Meal":

        if(widget.isEdit){
         await FirebaseFirestore.instance
             .collection("schedule")
             .doc("userSchedules")
             .collection(currentUser.id)
             .doc(widget.scheduleModel.documentId)
             .update({
           "type": _selectedScheduleType,
           "time":DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,selectedTimeForMeal.hour,selectedTimeForMeal.minute),
           "petName": _selectedPet,
           "message": messageController.text,
           "startDate": null,
           "endDate": null,
           "notificationId": widget.scheduleModel.notificationId,
         });
         await flutterLocalNotificationsPlugin.cancel(widget.scheduleModel.notificationId);
         await flutterLocalNotificationsPlugin.zonedSchedule(
           widget.scheduleModel.notificationId,
           "Meal",
           messageController.text,
           _nextInstanceOfTime(),
           platformChannelSpecifics,
           uiLocalNotificationDateInterpretation:
           UILocalNotificationDateInterpretation.absoluteTime,
           androidAllowWhileIdle: true,
           matchDateTimeComponents: DateTimeComponents.time,
         );

       }else{
         await FirebaseFirestore.instance
             .collection("schedule")
             .doc("userSchedules")
             .collection(currentUser.id)
             .doc(documentId)
             .set({
           "type": _selectedScheduleType,
           "time":DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,selectedTimeForMeal.hour,selectedTimeForMeal.minute),
           "petName": _selectedPet,
           "message": messageController.text,
           "startDate": null,
           "endDate": null,
           "notificationId": documentId.hashCode,
         });
         await flutterLocalNotificationsPlugin.zonedSchedule(
           documentId.hashCode,
           "Meal",
           messageController.text,
           _nextInstanceOfTime(),
           platformChannelSpecifics,
           uiLocalNotificationDateInterpretation:
           UILocalNotificationDateInterpretation.absoluteTime,
           androidAllowWhileIdle: true,
           matchDateTimeComponents: DateTimeComponents.time,
         );

       }
        break;
      case "Medicine":

        if(widget.isEdit){
          await flutterLocalNotificationsPlugin.cancel(widget.scheduleModel.notificationId);

          await FirebaseFirestore.instance
              .collection("schedule")
              .doc("userSchedules")
              .collection(currentUser.id)
              .doc(widget.scheduleModel.documentId)
              .update({
            "type": _selectedScheduleType,
            "time": DateTime(selectedDateForMedicineStart.year,selectedDateForMedicineStart.month,selectedDateForMedicineStart.day,selectedTimeForMedicine.hour,selectedTimeForMedicine.minute),
            "petName": _selectedPet,
            "message": messageController.text,
            "startDate": selectedDateForMedicineStart,
            "endDate": selectedDateForMedicineEnd,
            "notificationId": widget.scheduleModel.notificationId,
          });
          await Workmanager().cancelByUniqueName(widget.scheduleModel.notificationId.toString());
          await Workmanager().registerOneOffTask(
            "${documentId.hashCode}",
            "Task",
            initialDelay: Duration(
                milliseconds: selectedDateForMedicineEnd.millisecondsSinceEpoch -
                    DateTime.now().millisecondsSinceEpoch),
            inputData: {
              "id": documentId.hashCode,
            },
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            widget.scheduleModel.notificationId,
            "Medicine",
            messageController.text,
            _nextInstanceOfTimeForMedicine(),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.time,
          );

        }else{
          await FirebaseFirestore.instance
              .collection("schedule")
              .doc("userSchedules")
              .collection(currentUser.id)
              .doc(documentId)
              .set({
            "type": _selectedScheduleType,
            "time": DateTime(selectedDateForMedicineStart.year,selectedDateForMedicineStart.month,selectedDateForMedicineStart.day,selectedTimeForMedicine.hour,selectedTimeForMedicine.minute),
            "petName": _selectedPet,
            "message": messageController.text,
            "startDate": selectedDateForMedicineStart,
            "endDate": selectedDateForMedicineEnd,
            "notificationId": documentId.hashCode,
          });
          await Workmanager().registerOneOffTask(
            "${documentId.hashCode}",
            "Task",
            initialDelay: Duration(
                milliseconds: selectedDateForMedicineEnd.millisecondsSinceEpoch -
                    DateTime.now().millisecondsSinceEpoch),
            inputData: {
              "id": documentId.hashCode,
            },
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            documentId.hashCode,
            "Medicine",
            messageController.text,
            _nextInstanceOfTimeForMedicine(),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.time,
          );

        }
        break;
      case "Vaccine":
        if(widget.isEdit){
          await flutterLocalNotificationsPlugin.cancel(widget.scheduleModel.notificationId);
          await FirebaseFirestore.instance
              .collection("schedule")
              .doc("userSchedules")
              .collection(currentUser.id)
              .doc(widget.scheduleModel.documentId)
              .set({
            "type": _selectedScheduleType,
            "time": DateTime(selectedDateForVaccine.year,selectedDateForVaccine.month,selectedDateForVaccine.day,selectedTimeForVaccine.hour,selectedTimeForVaccine.minute),
            "petName": _selectedPet,
            "message": messageController.text,
            "startDate": selectedDateForVaccine,
            "endDate": null,
            "notificationId": widget.scheduleModel.notificationId,
          });
          await flutterLocalNotificationsPlugin.zonedSchedule(
            widget.scheduleModel.notificationId,
            "Vaccine",
            messageController.text,
            tz.TZDateTime.from(
                DateTime(selectedDateForVaccine.year,selectedDateForVaccine.month,selectedDateForVaccine.day,selectedTimeForVaccine.hour,selectedTimeForVaccine.minute),tz.local),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }else{
          await FirebaseFirestore.instance
              .collection("schedule")
              .doc("userSchedules")
              .collection(currentUser.id)
              .doc(documentId)
              .set({
            "type": _selectedScheduleType,
            "time": DateTime(selectedDateForVaccine.year,selectedDateForVaccine.month,selectedDateForVaccine.day,selectedTimeForVaccine.hour,selectedTimeForVaccine.minute),
            "petName": _selectedPet,
            "message": messageController.text,
            "startDate": selectedDateForVaccine,
            "endDate": null,
            "notificationId": documentId.hashCode,
          });
          await flutterLocalNotificationsPlugin.zonedSchedule(
            documentId.hashCode,
            "Vaccine",
            messageController.text,
            tz.TZDateTime.from(DateTime(selectedDateForVaccine.year,selectedDateForVaccine.month,selectedDateForVaccine.day,selectedTimeForVaccine.hour,selectedTimeForVaccine.minute),
                tz.local),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
        break;
    }

    setState(() {
      _isLoading = false;
    });
    print("Done");
    // Navigator.of(context).pop();
  }

  deleteSchedule()async{
    setState(() {
      _isLoading = true;
    });
    bool isNotificationSchedulePresent = false;

    List<PendingNotificationRequest> _pendingNotificationRequest =await flutterLocalNotificationsPlugin.pendingNotificationRequests();

   if(widget.scheduleModel !=null){
     await _pendingNotificationRequest.forEach((element) {
       if(element.id==widget.scheduleModel.notificationId){
         isNotificationSchedulePresent = true;
       }
     });
     await FirebaseFirestore.instance
         .collection("schedule")
         .doc("userSchedules")
         .collection(currentUser.id)
         .doc(widget.scheduleModel.documentId).delete();
     if(isNotificationSchedulePresent){
       await flutterLocalNotificationsPlugin.cancel(widget.scheduleModel.notificationId);
     }
     switch (_selectedScheduleType){
       case "Meal":
         break;
       case "Medicine":
         await Workmanager().cancelByUniqueName(widget.scheduleModel.notificationId.toString());
         break;
       case "Vaccine":
         break;
     }
   }
   if(mounted)setState(() {
     _isLoading = false;
   });
   print("Deleted ${widget.scheduleModel.documentId}");
   Navigator.of(context).pop();
  }

  tz.TZDateTime _nextInstanceOfTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    // final DateTime now = DateTime.now();

    tz.TZDateTime scheduleDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, selectedTimeForMeal.hour, selectedTimeForMeal.minute,);
    // tz.TZDateTime scheduleDate = tz.TZDateTime(tz.UTC,now.year,now.month,now.day,selectedTimeForMeal.hour,selectedTimeForMeal.minute);
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  tz.TZDateTime _nextInstanceOfTimeForMedicine() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
        tz.local,
        selectedDateForMedicineStart.year,
        selectedDateForMedicineStart.month,
        selectedDateForMedicineStart.day,
        selectedTimeForMedicine.hour,
        selectedTimeForMeal.minute);
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<TimeOfDay> _selectTime(
      BuildContext context, TimeOfDay givenTime) async {
    final TimeOfDay picked_s = await showTimePicker(
      context: context,
      initialTime: givenTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    if (picked_s != null && picked_s != givenTime) {
      return picked_s;
    }
    return null;
  }
}

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);
const double _kMenuItemHeight = 48.0;
const double _kDenseButtonHeight = 24.0;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 16.0);
const EdgeInsetsGeometry _kAlignedButtonPadding =
    EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;
const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;
const EdgeInsetsGeometry _kUnalignedMenuMargin =
    EdgeInsetsDirectional.only(start: 16.0, end: 24.0);

class _DropdownMenuPainter extends CustomPainter {
  _DropdownMenuPainter({
    this.color,
    this.elevation,
    this.selectedIndex,
    this.resize,
  })  : _painter = new BoxDecoration(
                // If you add an image here, you must provide a real
                // configuration in the paint() function and you must provide some sort
                // of onChanged callback here.
                color: color,
                borderRadius: new BorderRadius.circular(2.0),
                boxShadow: kElevationToShadow[elevation])
            .createBoxPainter(),
        super(repaint: resize);

  final Color color;
  final int elevation;
  final int selectedIndex;
  final Animation<double> resize;

  final BoxPainter _painter;

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset =
        selectedIndex * _kMenuItemHeight + kMaterialListPadding.top;
    final Tween<double> top = new Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - _kMenuItemHeight),
      end: 0.0,
    );

    final Tween<double> bottom = new Tween<double>(
      begin:
          (top.begin + _kMenuItemHeight).clamp(_kMenuItemHeight, size.height),
      end: size.height,
    );

    final Rect rect = new Rect.fromLTRB(
        0.0, top.evaluate(resize), size.width, bottom.evaluate(resize));

    _painter.paint(
        canvas, rect.topLeft, new ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_DropdownMenuPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.elevation != elevation ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

// Do not use the platform-specific default scroll configuration.
// Dropdown menus should never overscroll or display an overscroll indicator.
class _DropdownScrollBehavior extends ScrollBehavior {
  const _DropdownScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      Theme.of(context).platform;

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class _DropdownMenu<T> extends StatefulWidget {
  const _DropdownMenu({
    Key key,
    this.padding,
    this.route,
  }) : super(key: key);

  final _DropdownRoute<T> route;
  final EdgeInsets padding;

  @override
  _DropdownMenuState<T> createState() => new _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  CurvedAnimation _fadeOpacity;
  CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();
    // We need to hold these animations as state because of their curve
    // direction. When the route's animation reverses, if we were to recreate
    // the CurvedAnimation objects in build, we'd lose
    // CurvedAnimation._curveDirection.
    _fadeOpacity = new CurvedAnimation(
      parent: widget.route.animation,
      curve: const Interval(0.0, 0.25),
      reverseCurve: const Interval(0.75, 1.0),
    );
    _resize = new CurvedAnimation(
      parent: widget.route.animation,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The menu is shown in three stages (unit timing in brackets):
    // [0s - 0.25s] - Fade in a rect-sized menu container with the selected item.
    // [0.25s - 0.5s] - Grow the otherwise empty menu container from the center
    //   until it's big enough for as many items as we're going to show.
    // [0.5s - 1.0s] Fade in the remaining visible items from top to bottom.
    //
    // When the menu is dismissed we just fade the entire thing out
    // in the first 0.25s.
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final _DropdownRoute<T> route = widget.route;
    final double unit = 0.5 / (route.items.length + 1.5);
    final List<Widget> children = <Widget>[];
    for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex) {
      CurvedAnimation opacity;
      if (itemIndex == route.selectedIndex) {
        opacity = new CurvedAnimation(
            parent: route.animation, curve: const Threshold(0.0));
      } else {
        final double start = (0.5 + (itemIndex + 1) * unit).clamp(0.0, 1.0);
        final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
        opacity = new CurvedAnimation(
            parent: route.animation, curve: new Interval(start, end));
      }
      children.add(new FadeTransition(
        opacity: opacity,
        child: new InkWell(
          child: new Container(
            padding: widget.padding,
            child: route.items[itemIndex],
          ),
          onTap: () => Navigator.pop(
            context,
            new _DropdownRouteResult<T>(route.items[itemIndex].value),
          ),
        ),
      ));
    }

    return new FadeTransition(
      opacity: _fadeOpacity,
      child: new CustomPaint(
        painter: new _DropdownMenuPainter(
          color: Theme.of(context).canvasColor,
          elevation: route.elevation,
          selectedIndex: route.selectedIndex,
          resize: _resize,
        ),
        child: new Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: localizations.popupMenuLabel,
          child: new Material(
            type: MaterialType.transparency,
            textStyle: route.style,
            child: new ScrollConfiguration(
              behavior: const _DropdownScrollBehavior(),
              child: new Scrollbar(
                child: new ListView(
                  controller: widget.route.scrollController,
                  padding: kMaterialListPadding,
                  itemExtent: _kMenuItemHeight,
                  shrinkWrap: true,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _DropdownMenuRouteLayout({
    @required this.buttonRect,
    @required this.menuTop,
    @required this.menuHeight,
    @required this.textDirection,
  });

  final Rect buttonRect;
  final double menuTop;
  final double menuHeight;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The maximum height of a simple menu should be one or more rows less than
    // the view height. This ensures a tappable area outside of the simple menu
    // with which to dismiss the menu.
    //   -- https://material.google.com/components/menus.html#menus-simple-menus
    final double maxHeight =
        math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);
    // The width of a menu should be at most the view width. This ensures that
    // the menu does not extend past the left and right edges of the screen.
    final double width = math.min(constraints.maxWidth, buttonRect.width);
    return new BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {
        // If the button was entirely on-screen, then verify
        // that the menu is also on-screen.
        // If the button was a bit off-screen, then, oh well.
        assert(menuTop >= 0.0);
        assert(menuTop + menuHeight <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    double left;
    switch (textDirection) {
      case TextDirection.rtl:
        left = buttonRect.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect.left.clamp(0.0, size.width - childSize.width);
        break;
    }
    return new Offset(left, menuTop);
  }

  @override
  bool shouldRelayout(_DropdownMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        menuTop != oldDelegate.menuTop ||
        menuHeight != oldDelegate.menuHeight ||
        textDirection != oldDelegate.textDirection;
  }
}

class _DropdownRouteResult<T> {
  const _DropdownRouteResult(this.result);

  final T result;

  @override
  bool operator ==(dynamic other) {
    if (other is! _DropdownRouteResult<T>) return false;
    final _DropdownRouteResult<T> typedOther = other;
    return result == typedOther.result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _DropdownRoute<T> extends PopupRoute<_DropdownRouteResult<T>> {
  _DropdownRoute({
    this.items,
    this.padding,
    this.buttonRect,
    this.selectedIndex,
    this.elevation = 8,
    this.theme,
    @required this.style,
    this.barrierLabel,
  }) : assert(style != null);

  final List<DropdownMenuItem<T>> items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final int elevation;
  final ThemeData theme;
  final TextStyle style;

  ScrollController scrollController;

  @override
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    assert(debugCheckHasDirectionality(context));
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxMenuHeight = screenHeight - 2.0 * _kMenuItemHeight;
    final double preferredMenuHeight =
        (items.length * _kMenuItemHeight) + kMaterialListPadding.vertical;
    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);

    final double buttonTop = buttonRect.top;
    final double selectedItemOffset =
        selectedIndex * _kMenuItemHeight + kMaterialListPadding.top;
    double menuTop = (buttonTop - selectedItemOffset) -
        (_kMenuItemHeight - buttonRect.height) / 2.0;
    const double topPreferredLimit = _kMenuItemHeight;
    if (menuTop < topPreferredLimit)
      menuTop = math.min(buttonTop, topPreferredLimit);
    double bottom = menuTop + menuHeight;
    final double bottomPreferredLimit = screenHeight - _kMenuItemHeight;
    if (bottom > bottomPreferredLimit) {
      bottom = math.max(buttonTop + _kMenuItemHeight, bottomPreferredLimit);
      menuTop = bottom - menuHeight;
    }

    if (scrollController == null) {
      double scrollOffset = 0.0;
      if (preferredMenuHeight > maxMenuHeight)
        scrollOffset = selectedItemOffset - (buttonTop - menuTop);
      scrollController =
          new ScrollController(initialScrollOffset: scrollOffset);
    }

    final TextDirection textDirection = Directionality.of(context);
    Widget menu = new _DropdownMenu<T>(
      route: this,
      padding: padding.resolve(textDirection),
    );

    if (theme != null) menu = new Theme(data: theme, child: menu);

    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: new Builder(
        builder: (BuildContext context) {
          return new CustomSingleChildLayout(
            delegate: new _DropdownMenuRouteLayout<T>(
              buttonRect: buttonRect,
              menuTop: menuTop,
              menuHeight: menuHeight,
              textDirection: textDirection,
            ),
            child: menu,
          );
        },
      ),
    );
  }

  void _dismiss() {
    navigator?.removeRoute(this);
  }
}

class CustomDropdownButton<T> extends StatefulWidget {
  /// Creates a dropdown button.
  ///
  /// The [items] must have distinct values and if [value] isn't null it must be among them.
  ///
  /// The [elevation] and [iconSize] arguments must not be null (they both have
  /// defaults, so do not need to be specified).
  CustomDropdownButton({
    Key key,
    @required this.items,
    this.value,
    this.hint,
    @required this.onChanged,
    this.elevation = 8,
    this.style,
    this.iconSize = 24.0,
    this.isDense = false,
  })  : assert(items != null),
        assert(value == null ||
            items
                    .where((DropdownMenuItem<T> item) => item.value == value)
                    .length ==
                1),
        super(key: key);

  /// The list of possible items to select among.
  final List<DropdownMenuItem<T>> items;

  /// The currently selected item, or null if no item has been selected. If
  /// value is null then the menu is popped up as if the first item was
  /// selected.
  final T value;

  /// Displayed if [value] is null.
  final Widget hint;

  /// Called when the user selects an item.
  final ValueChanged<T> onChanged;

  /// The z-coordinate at which to place the menu when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12, 16, 24
  ///
  /// Defaults to 8, the appropriate elevation for dropdown buttons.
  final int elevation;

  /// The text style to use for text in the dropdown button and the dropdown
  /// menu that appears when you tap the button.
  ///
  /// Defaults to the [TextTheme.subhead] value of the current
  /// [ThemeData.textTheme] of the current [Theme].
  final TextStyle style;

  /// The size to use for the drop-down button's down arrow icon button.
  ///
  /// Defaults to 24.0.
  final double iconSize;

  /// Reduce the button's height.
  ///
  /// By default this button's height is the same as its menu items' heights.
  /// If isDense is true, the button's height is reduced by about half. This
  /// can be useful when the button is embedded in a container that adds
  /// its own decorations, like [InputDecorator].
  final bool isDense;

  @override
  _DropdownButtonState<T> createState() => new _DropdownButtonState<T>();
}

class _DropdownButtonState<T> extends State<CustomDropdownButton<T>>
    with WidgetsBindingObserver {
  int _selectedIndex;
  _DropdownRoute<T> _dropdownRoute;

  @override
  void initState() {
    super.initState();
//    _updateSelectedIndex();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeDropdownRoute();
    super.dispose();
  }

  // Typically called because the device's orientation has changed.
  // Defined by WidgetsBindingObserver
  @override
  void didChangeMetrics() {
    _removeDropdownRoute();
  }

  void _removeDropdownRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
  }

  @override
  void didUpdateWidget(CustomDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    assert(widget.value == null ||
        widget.items
                .where((DropdownMenuItem<T> item) => item.value == widget.value)
                .length ==
            1);
    _selectedIndex = null;
    for (int itemIndex = 0; itemIndex < widget.items.length; itemIndex++) {
      if (widget.items[itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  TextStyle get _textStyle =>
      widget.style ?? Theme.of(context).textTheme.subhead;

  void _handleTap() {
    final RenderBox itemBox = context.findRenderObject();
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry menuMargin =
        ButtonTheme.of(context).alignedDropdown
            ? _kAlignedMenuMargin
            : _kUnalignedMenuMargin;

    assert(_dropdownRoute == null);
    _dropdownRoute = new _DropdownRoute<T>(
      items: widget.items,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: _kMenuItemPadding.resolve(textDirection),
      selectedIndex: -1,
      elevation: widget.elevation,
      theme: Theme.of(context),
      style: _textStyle,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );

    Navigator.push(context, _dropdownRoute)
        .then<void>((_DropdownRouteResult<T> newValue) {
      _dropdownRoute = null;
      if (!mounted || newValue == null) return;
      if (widget.onChanged != null) widget.onChanged(newValue.result);
    });
  }

  // When isDense is true, reduce the height of this button from _kMenuItemHeight to
  // _kDenseButtonHeight, but don't make it smaller than the text that it contains.
  // Similarly, we don't reduce the height of the button so much that its icon
  // would be clipped.
  double get _denseButtonHeight {
    return math.max(
        _textStyle.fontSize, math.max(widget.iconSize, _kDenseButtonHeight));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    // The width of the button and the menu are defined by the widest
    // item and the width of the hint.
    final List<Widget> items = new List<Widget>.from(widget.items);
    int hintIndex;
    if (widget.hint != null) {
      hintIndex = items.length;
      items.add(new DefaultTextStyle(
        style: _textStyle.copyWith(color: Theme.of(context).hintColor),
        child: new IgnorePointer(
          child: widget.hint,
          ignoringSemantics: false,
        ),
      ));
    }

    final EdgeInsetsGeometry padding = ButtonTheme.of(context).alignedDropdown
        ? _kAlignedButtonPadding
        : _kUnalignedButtonPadding;

    Widget result = new DefaultTextStyle(
      style: _textStyle,
      child: new Container(
        padding: padding.resolve(Directionality.of(context)),
        height: widget.isDense ? _denseButtonHeight : null,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // If value is null (then _selectedIndex is null) then we display
            // the hint or nothing at all.
            Expanded(
              child: new IndexedStack(
                index: _selectedIndex ?? hintIndex,
                alignment: AlignmentDirectional.centerStart,
                children: items,
              ),
            ),
            new Icon(Icons.arrow_drop_down,
                size: widget.iconSize,
                // These colors are not defined in the Material Design spec.
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );

    if (!DropdownButtonHideUnderline.at(context)) {
      final double bottom = widget.isDense ? 0.0 : 8.0;
      result = new Stack(
        children: <Widget>[
          result,
          new Positioned(
            left: 0.0,
            right: 0.0,
            bottom: bottom,
            child: new Container(
              height: 1.0,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Color(0xFFBDBDBD), width: 0.0))),
            ),
          ),
        ],
      );
    }

    return new Semantics(
      button: true,
      child: new GestureDetector(
          onTap: _handleTap, behavior: HitTestBehavior.opaque, child: result),
    );
  }
}
