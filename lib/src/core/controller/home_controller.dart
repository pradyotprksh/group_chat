import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

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

  }

  void disableNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
