// Arquivo: lib/Scheduling/SchedulingScreen/components/time_indicator_column.dart

import 'package:flutter/material.dart';

class TimeIndicatorColumn extends StatelessWidget {
  final double hourHeight;

  const TimeIndicatorColumn({Key? key, required this.hourHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(24, (index) {
        return Container(
          height: hourHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Center(
                  child: Text(
                    '${index.toString().padLeft(2, '0')}:00',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        );
      }),
    );
  }
}
