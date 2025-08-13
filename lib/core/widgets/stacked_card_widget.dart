import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardDeckWidget<T> extends StatefulWidget {
  final RxList<T> items;
  final Widget Function(T item) itemBuilder;
  final int maxCards;

  const CardDeckWidget({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.maxCards = 9,
  }) : super(key: key);

  @override
  State<CardDeckWidget<T>> createState() => _CardDeckWidgetState<T>();
}

class _CardDeckWidgetState<T> extends State<CardDeckWidget<T>>
    with AutomaticKeepAliveClientMixin {
  late final List<_CardTransformData> transformDataList;

  final List<int> _rotationDegrees = [5, 10, 15, 20];
  final int _centerIndex = 0;

  @override
  void initState() {
    super.initState();

    final total = widget.maxCards;
    final random = Random();

    transformDataList = List.generate(total, (i) {
      double angle = 0;
      double horizontalOffset = 0;

      if (i != _centerIndex) {
        int offsetFromCenter = i - _centerIndex;
        int sideIndex = ((offsetFromCenter + 1) / 2).floor();
        int rotation =
            _rotationDegrees[random.nextInt(_rotationDegrees.length)];

        if (offsetFromCenter % 2 == 0) {
          // Right side
          angle = rotation * pi / 180;
          horizontalOffset = sideIndex * 10.0;
        } else {
          // Left side
          angle = -rotation * pi / 180;
          horizontalOffset = -sideIndex * 10.0;
        }
      }

      return _CardTransformData(angle: angle, offsetX: horizontalOffset);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final displayItems = widget.items.take(widget.maxCards).toList();
    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = displayItems.length - 1; i >= 0; i--)
            Positioned(
              left: transformDataList[i].offsetX == 0 ? null : null,
              child: Transform.rotate(
                angle: transformDataList[i].angle,
                child: widget.itemBuilder(displayItems[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardTransformData {
  final double angle;
  final double offsetX;

  _CardTransformData({required this.angle, required this.offsetX});
}
