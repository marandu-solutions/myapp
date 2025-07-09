// Arquivo: lib/Scheduling/SchedulingScreen/components/reservation_tile.dart

import 'package:flutter/material.dart';

import '../../../../models/reservation_model.dart';
import '../../../Reservation/ReservationDetails/reservation_details.dart';

class ReservationTile extends StatelessWidget {
  final ReservationModel reservation;
  // Callback para notificar a tela principal que uma ação foi concluída
  final VoidCallback onActionCompleted;

  const ReservationTile({
    Key? key,
    required this.reservation,
    required this.onActionCompleted,
  }) : super(key: key);

  Color _getReservationColor(String status) {
    switch (status) {
      case 'confirmada': return Colors.blue.shade400;
      case 'pendente': return Colors.orange.shade400;
      case 'bloqueado': return Colors.grey.shade500;
      case 'cancelada': return Colors.red.shade300;
      default: return Colors.blue.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 2.0, bottom: 2.0),
      // Envolvido com Material e InkWell para dar o efeito de clique
      child: Material(
        color: _getReservationColor(reservation.status),
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          // --- AÇÃO DE CLIQUE IMPLEMENTADA ---
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ReservationDetailsSheet(
                reservation: reservation,
                onActionCompleted: onActionCompleted, // Passa o callback para a janela
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
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
      ),
    );
  }
}
