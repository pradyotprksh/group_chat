import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:group_chat/src/screens/auth_screen.dart';
import 'package:group_chat/src/screens/create_group.dart';
import 'package:group_chat/src/screens/group_chat/group_chat_screen.dart';
import 'package:group_chat/src/screens/group_list/group_list.dart';
import 'package:group_chat/src/screens/home/home_screen.dart';
import 'package:group_chat/src/screens/splash_screen.dart';
import 'package:group_chat/src/util/string.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    return GetMaterialApp(
      title: StringConstant.APP_NAME,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
        backgroundColor: Colors.black,
        accentColorBrightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => SplashScreen(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: AuthScreen.route_name,
          page: () => AuthScreen(),
          transition: Transition.upToDown,
        ),
        GetPage(
          name: HomeScreen.route_name,
          page: () => HomeScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: CreateGroup.route_name,
          page: () => CreateGroup(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: GroupList.route_name,
          page: () => GroupList(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: GroupChatScreen.route_name,
          page: () => GroupChatScreen(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
