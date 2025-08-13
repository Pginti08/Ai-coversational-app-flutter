import 'package:flutter/material.dart';

class LowerClipPathClass extends CustomClipper<Path> {
  final double value;

  LowerClipPathClass(this.value);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - value);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - value);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
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