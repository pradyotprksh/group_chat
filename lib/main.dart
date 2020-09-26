import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';
import 'package:group_chat/src/core/controller/groups_controller.dart';
import 'package:group_chat/src/screens/auth_screen.dart';
import 'package:group_chat/src/screens/create_group.dart';
import 'package:group_chat/src/screens/games/chess/chess_game_list.dart';
import 'package:group_chat/src/screens/games/chess/chess_game_screen.dart';
import 'package:group_chat/src/screens/games/main_game_screen.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_list.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_screen.dart';
import 'package:group_chat/src/screens/group_chat/group_chat_screen.dart';
import 'package:group_chat/src/screens/group_list/group_invites/group_invites_screen.dart';
import 'package:group_chat/src/screens/group_list/group_list.dart';
import 'package:group_chat/src/screens/home/home_screen.dart';
import 'package:group_chat/src/screens/image_preview_screen.dart';
import 'package:group_chat/src/screens/razorpay_screen.dart';
import 'package:group_chat/src/util/string.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(GroupController());
  Get.put(GameController());
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstant.APP_NAME,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
        backgroundColor: Colors.black,
        accentColorBrightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? HomeScreen.route_name
          : AuthScreen.route_name,
      getPages: [
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
        GetPage(
          name: RazorPayScreen.route_name,
          page: () => RazorPayScreen(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: ImagePreviewScreen.route_name,
          page: () => ImagePreviewScreen(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: ChessGameScreen.route_name,
          page: () => ChessGameScreen(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: ChessGameList.route_name,
          page: () => ChessGameList(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: TicTacToeGameScreen.route_name,
          page: () => TicTacToeGameScreen(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: TicTacToeGameList.route_name,
          page: () => TicTacToeGameList(),
          fullscreenDialog: true,
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: MainGameScreen.route_name,
          page: () => MainGameScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: GroupInvitesScreen.route_name,
          page: () => GroupInvitesScreen(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
