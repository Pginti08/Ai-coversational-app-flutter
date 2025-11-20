import 'package:flutter/material.dart';
import 'package:vousvous/core/constants/state_cities.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';

class StateListBottomSheet extends StatelessWidget {
  StateListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
          .copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "State".toUpperCase(),
            style: style700S12.copyWith(
              letterSpacing: 0.96,
              color: const Color(0xFFCCCCCC),
            ),
          ),
          hSizedBox30,
          Expanded(
            child: ListView.separated(
              itemCount: stateCitiesMap.length,
              separatorBuilder: (context, index) => Divider(
                thickness: 0.5,
                color: Colors.white24,
              ),
              itemBuilder: (context, index) {
                final stateName = stateCitiesMap.keys.elementAt(index);

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, stateName);
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      stateName,
                      style: style500S16.copyWith(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
