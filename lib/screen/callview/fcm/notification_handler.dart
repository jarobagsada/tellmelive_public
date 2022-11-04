/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationHandler{
  static final flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  static  BuildContext myContext;

  static void initNotification({BuildContext context, var selectNotificationCallback}){ //customize
    myContext = context;
    var initAndroid = const AndroidInitializationSettings("@drawable/ic_notify");
   */
/* const IOSInitializationSettings initializationSettingsIOS =
     IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );*//*

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var initSetting = InitializationSettings(android: initAndroid,iOS: initializationSettingsIOS);
    flutterLocalNotificationPlugin.initialize(initSetting,
       // onSelectNotification: selectNotificationCallback,
        onDidReceiveNotificationResponse: selectNotificationCallback,
    );
    flutterLocalNotificationPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // ...
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

  }


  static Future onDidReceiveLocalNotification(int id,String title,String body,String payload) async{
    showDialog(context: myContext, builder: (context)=> CupertinoAlertDialog(title: Text(title),
    content: Text(body),
    actions: [
      CupertinoDialogAction(
        isDefaultAction: true,
        child: const Text('OK'),
        onPressed: ()=> Navigator.of(context,rootNavigator: true,).pop(),
      )
    ],));
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    // handle action
  }
}
*/
