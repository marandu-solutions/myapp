// Arquivo: lib/Scheduling/SchedulingScreen/components/day_schedule_view.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/reservation_model.dart';
import 'time_indicator_column.dart';
import 'reservation_tile.dart';

class DayScheduleView extends StatelessWidget {
  final List<ReservationModel> reservations;
  final DateTime date;
  final double hourHeight;

  const DayScheduleView({
    Key? key,
    required this.reservations,
    required this.date,
    this.hourHeight = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // Fundo com as linhas do tempo e os horários
          TimeIndicatorColumn(hourHeight: hourHeight),

          // Posiciona os agendamentos sobre a timeline
          ...reservations.map((reservation) {
            final top = reservation.startTime.hour * hourHeight +
                reservation.startTime.minute;
            final height = reservation.endTime.difference(reservation.startTime).inMinutes.toDouble();

            return Positioned(
              top: top,
              left: 60.0, // Largura da coluna de horários
              right: 0,
              height: height,
              child: ReservationTile(
                reservation: reservation,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
