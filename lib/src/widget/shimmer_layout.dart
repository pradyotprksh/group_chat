import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: ListTile(
        leading: CircleAvatar(),
        title: Container(
          height: 10,
          color: Colors.white,
        ),
        subtitle: Container(
          height: 5,
          color: Colors.white,
        ),
        trailing: Icon(
          Icons.arrow_right,
        ),
      ),
      baseColor: Colors.black,
      highlightColor: Colors.white,
    );
  }
}
