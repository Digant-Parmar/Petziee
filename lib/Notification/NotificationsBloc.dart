import 'package:rxdart/rxdart.dart';

class LocalNotification{
  final String type;
  final Map data;
  LocalNotification(this.type,this.data);
}

class NotificationBloc{

  //._internal() is just makeing the Notification bloc private to this class

  NotificationBloc._internal();

  static final NotificationBloc instance = NotificationBloc._internal();

  final BehaviorSubject<LocalNotification> _notificationStreamController = BehaviorSubject<LocalNotification>();

  Stream<LocalNotification> get notificationStream{
    return _notificationStreamController;
  }

  void newNotification(LocalNotification notification){
    _notificationStreamController.sink.add(notification);
  }

  void dispose(){
    _notificationStreamController.close();
  }

}