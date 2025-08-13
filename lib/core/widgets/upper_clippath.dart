import 'package:flutter/material.dart';

class UpperClipPathClass extends CustomClipper<Path> {
  final double value;

  UpperClipPathClass(this.value);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0.0, value);

    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, value);
    path.quadraticBezierTo(size.width / 2, -value, -value, value);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


    // path.moveTo(0.0, value);

    // path.lineTo(0.0, size.height);
    // path.lineTo(size.width, size.height);
    // path.lineTo(size.width, value);

    // path.quadraticBezierTo(
    //     size.width - (size.width / 4), value / 2, size.width / 2, 0);
    // path.quadraticBezierTo(
    //     size.width / 4, value / 2, 0, value);
    // path.moveTo(0.0, 0.0);
    // path.close();


    // path.moveTo(0.0, value);

    // path.lineTo(0.0, size.height);
    // path.lineTo(size.width, size.height);
    // path.lineTo(size.width, value);

    // path.quadraticBezierTo(size.width / 2, 0.0, 0.0, value);

    // path.close();