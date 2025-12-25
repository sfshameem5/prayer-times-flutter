import 'package:flutter/material.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({super.key, required this.name, required this.time });

  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 3,
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.93,
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                         time,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
    // return Row(
    //   children: [Text("hello prayers", style: TextStyle(color: Colors.green))],
    // );
  }
}
