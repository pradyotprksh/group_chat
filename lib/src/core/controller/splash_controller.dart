import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/screens/auth_screen.dart';
import 'package:group_chat/src/screens/home/home_screen.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    if (currentUser != null) {
      Get.offNamed(HomeScreen.route_name);
    } else {
      Get.offNamed(AuthScreen.route_name);
    }
    super.onInit();
  }
}
