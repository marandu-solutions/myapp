// Arquivo: lib/Scheduling/SchedulingScreen/components/week_schedule_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Screens/%20Scheduling/Scheduling%20Screen/components/reservation_tile.dart';
import '../../../../models/reservation_model.dart';
import 'time_indicator_column.dart';

class WeekScheduleView extends StatefulWidget {
  final List<ReservationModel> reservations;
  final DateTime weekStartDate;
  final VoidCallback onActionCompleted; // Callback para atualizar a UI

  const WeekScheduleView({
    Key? key,
    required this.reservations,
    required this.weekStartDate,
    required this.onActionCompleted,
  }) : super(key: key);

  @override
  _WeekScheduleViewState createState() => _WeekScheduleViewState();
}

class _WeekScheduleViewState extends State<WeekScheduleView> {
  final ScrollController _timeController = ScrollController();
  final ScrollController _gridController = ScrollController();

  @override
  void initState() {
    super.initState();
    _timeController.addListener(() {
      if (_gridController.hasClients && _gridController.offset != _timeController.offset) {
        _gridController.jumpTo(_timeController.offset);
      }
    });
    _gridController.addListener(() {
      if (_timeController.hasClients && _timeController.offset != _gridController.offset) {
        _timeController.jumpTo(_gridController.offset);
      }
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double dayWidth = 200.0;
    const double hourHeight = 60.0;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 60),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final dayDate = widget.weekStartDate.add(Duration(days: index));
                    return DayHeader(date: dayDate, dayWidth: dayWidth);
                  }),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                child: TimeIndicatorColumn(
                  hourHeight: hourHeight,
                  controller: _timeController,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: dayWidth * 7,
                    child: ListView.builder(
                      controller: _gridController,
                      itemCount: 1,
                      itemBuilder: (context, _) {
                        return SizedBox(
                          height: hourHeight * 24,
                          child: Stack(
                            children: [
                              for (int dayIndex = 0; dayIndex < 7; dayIndex++)
                                for (int hourIndex = 0; hourIndex < 24; hourIndex++)
                                  Positioned(
                                    top: hourIndex * hourHeight,
                                    left: dayIndex * dayWidth,
                                    child: Container(
                                      width: dayWidth,
                                      height: hourHeight,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: Colors.grey.shade200),
                                          left: BorderSide(color: Colors.grey.shade300),
                                        ),
                                      ),
                                    ),
                                  ),
                              for (final reservation in widget.reservations)
                                ..._buildReservation(reservation, dayWidth, hourHeight)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildReservation(ReservationModel reservation, double dayWidth, double hourHeight) {
    if (reservation.startTime.isBefore(widget.weekStartDate) ||
        reservation.startTime.isAfter(widget.weekStartDate.add(const Duration(days: 7)))) {
      return [];
    }
    final dayIndex = reservation.startTime.weekday - 1;
    final top = reservation.startTime.hour * hourHeight + reservation.startTime.minute;
    final height = reservation.endTime.difference(reservation.startTime).inMinutes.toDouble();
    final left = dayIndex * dayWidth;

    return [
      Positioned(
        top: top,
        left: left,
        width: dayWidth,
        height: height,
        child: ReservationTile(
          reservation: reservation,
          onActionCompleted: widget.onActionCompleted, // Passa o callback
        ),
      )
    ];
  }
}

class DayHeader extends StatelessWidget {
  final DateTime date;
  final double dayWidth;
  const DayHeader({Key? key, required this.date, required this.dayWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    return Container(
      width: dayWidth,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            DateFormat('E', 'pt_BR').format(date).toUpperCase(),
            style: TextStyle(color: isToday ? Colors.blue : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 16,
            backgroundColor: isToday ? Colors.blue : Colors.transparent,
            child: Text(
              date.day.toString(),
              style: TextStyle(color: isToday ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
