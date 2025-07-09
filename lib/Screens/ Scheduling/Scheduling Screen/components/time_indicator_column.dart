// Arquivo: lib/Scheduling/SchedulingScreen/components/time_indicator_column.dart

import 'package:flutter/material.dart';

class TimeIndicatorColumn extends StatelessWidget {
  final double hourHeight;
  final ScrollController controller;

  const TimeIndicatorColumn({
    Key? key,
    required this.hourHeight,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usa um ListView para ser rolável e evitar o overflow vertical.
    return ListView.builder(
      controller: controller,
      // Impede que esta lista seja rolada independentemente,
      // pois a rolagem é controlada pelo widget pai (WeekScheduleView).
      // Isso garante a sincronização do scroll.
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 24,
      itemBuilder: (context, index) {
        return Container(
          height: hourHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Center(
            child: Text(
              // Formata a hora para ter sempre dois dígitos (ex: 08:00)
              '${index.toString().padLeft(2, '0')}:00',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
