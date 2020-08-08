import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 0;

  updateCurrentIndex(selectedIndex) {
    currentIndex = selectedIndex;
    update();
  }
}