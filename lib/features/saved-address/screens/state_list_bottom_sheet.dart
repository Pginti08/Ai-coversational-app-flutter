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
              itemCount: stateCitiesMap.keys
                  .where((key) =>
                      key.toLowerCase() == "delhi" ||
                      key.toLowerCase() == "chandigarh")
                  .length,
              separatorBuilder: (context, index) => Divider(
                thickness: 0.5,
                color: Colors.white24,
              ),
              itemBuilder: (context, index) {
                final filteredStates = stateCitiesMap.keys
                    .where((key) =>
                        key.toLowerCase() == "delhi" ||
                        key.toLowerCase() == "chandigarh")
                    .toList();
                final stateName = filteredStates[index];

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              child: Text(
                "We are serviceable for Chandigarh and Delhi only",
                textAlign: TextAlign.center,
                style: style400S12.copyWith(
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
