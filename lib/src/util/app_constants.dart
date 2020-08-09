import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppConstants {
  static RxInt groupOwner = 0.obs;
  static RxInt groupJoined = 0.obs;

  static const Map<int, Color> primaryColor = {
    50: Color.fromRGBO(248, 186, 26, .1),
    100: Color.fromRGBO(248, 186, 26, .2),
    200: Color.fromRGBO(248, 186, 26, .3),
    300: Color.fromRGBO(248, 186, 26, .4),
    400: Color.fromRGBO(248, 186, 26, .5),
    500: Color.fromRGBO(248, 186, 26, .6),
    600: Color.fromRGBO(248, 186, 26, .7),
    700: Color.fromRGBO(248, 186, 26, .8),
    800: Color.fromRGBO(248, 186, 26, .9),
    900: Color.fromRGBO(248, 186, 26, 1),
  };

}