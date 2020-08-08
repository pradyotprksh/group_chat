import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/core/controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: GetBuilder<SplashController>(
        init: SplashController(),
        builder: (_) => Container(),
      ),
    );
  }
}
