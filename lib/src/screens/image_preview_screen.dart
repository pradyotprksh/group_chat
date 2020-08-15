import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewScreen extends StatelessWidget {
  static const route_name = "image_preview_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(
            Get.arguments,
          ),
        ),
      ),
    );
  }
}
