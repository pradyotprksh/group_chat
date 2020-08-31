import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';

class HomeController extends GetxController {
  var currentIndex = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void onInit() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    setupNotification();
    super.onInit();
  }

  updateCurrentIndex(selectedIndex) {
    currentIndex = selectedIndex;
    update();
  }

  void setupNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseFirestore.instance
        .collection(FirestoreConstants.USER)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      if (value.get(FirestoreConstants.GET_DAILY_NOTIFICATION)) {
        var time = Time(22, 0, 0);
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            StringConstant.APP_NAME,
            StringConstant.APP_NAME,
            StringConstant.APP_NAME);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        flutterLocalNotificationsPlugin.showDailyAtTime(
            0,
            'Daily Game',
            'Join others for playing the daily game and rise into the leader board.',
            time,
            platformChannelSpecifics);
      }
    });
  }

  void disableNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}