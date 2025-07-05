// Arquivo: lib/Scheduling/SchedulingScreen/components/reservation_tile.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/reservation_model.dart';

class ReservationTile extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationTile({Key? key, required this.reservation}) : super(key: key);
  
  // Define cores com base no status da reserva para uma melhor UX
  Color _getReservationColor(String status) {
    switch (status) {
      case 'confirmada':
        return Colors.blue.shade400;
      case 'pendente':
        return Colors.orange.shade400;
      case 'bloqueado':
        return Colors.grey.shade500;
      case 'cancelada':
        return Colors.red.shade300;
      default:
        return Colors.blue.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 2.0, bottom: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: _getReservationColor(reservation.status),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            reservation.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
