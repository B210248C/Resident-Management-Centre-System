import 'package:flutter/material.dart';
import 'package:dcdg/dcdg.dart';

class StarWidget extends StatelessWidget {
  final double? left;
  final double? top;
  final double? right;
  final double width;
  final double height;

  const StarWidget({
    super.key,
    this.left,
    this.top,
    this.right,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      child: Opacity(
        opacity: 1,
        child: Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: AssetImage('images/star1.png'),
            ),
          ),
        ),
      ),
    );
  }
}
