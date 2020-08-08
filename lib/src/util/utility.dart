import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utility {
  static showSnackBar(message, backgroundColor) {
    Get.rawSnackbar(
      dismissDirection: SnackDismissDirection.HORIZONTAL,
      backgroundColor: backgroundColor,
      message: message,
      margin: EdgeInsets.all(
        15.0,
      ),
      borderRadius: 15.0,
    );
  }
}
