// Arquivo: lib/Scheduling/SchedulingScreen/components/reservation_details_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/reservation_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/services/user_service.dart';

import '../../../services/reservataion_service.dart';


// CORREÇÃO: Convertido para StatefulWidget para gerenciar o estado dos botões
class ReservationDetailsSheet extends StatefulWidget {
  final ReservationModel reservation;
  final VoidCallback onActionCompleted; // Callback para atualizar a tela anterior

  const ReservationDetailsSheet({
    Key? key,
    required this.reservation,
    required this.onActionCompleted,
  }) : super(key: key);

  @override
  State<ReservationDetailsSheet> createState() => _ReservationDetailsSheetState();
}

class _ReservationDetailsSheetState extends State<ReservationDetailsSheet> {
  final ReservationService _reservationService = ReservationService();
  bool _isLoading = false;

  // --- LÓGICA PARA AS AÇÕES DOS BOTÕES ---

  void _confirmReservation() async {
    setState(() => _isLoading = true);
    try {
      await _reservationService.updateReservationStatus(widget.reservation.id, 'confirmada');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva confirmada!'), backgroundColor: Colors.green));
        widget.onActionCompleted(); // Atualiza a lista na tela anterior
        Navigator.pop(context);
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao confirmar: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _cancelReservation() async {
    // Mostra um diálogo de confirmação antes de cancelar
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('Você tem certeza que deseja cancelar este agendamento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Manter')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim, Cancelar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldCancel != true) return;

    setState(() => _isLoading = true);
    try {
      await _reservationService.deleteReservation(widget.reservation.id);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva cancelada com sucesso.'), backgroundColor: Colors.blue));
        widget.onActionCompleted(); // Atualiza a lista na tela anterior
        Navigator.pop(context);
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cancelar: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    // final CourtService courtService = CourtService();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Wrap(
        runSpacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.reservation.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              StatusChip(status: widget.reservation.status),
            ],
          ),
          const Divider(),
          FutureBuilder<UserModel?>(
            future: userService.getUser(widget.reservation.clientId),
            builder: (context, snapshot) {
              return InfoRow(
                icon: Icons.person_outline,
                label: 'Cliente',
                value: snapshot.hasData ? snapshot.data!.nomeCompleto : 'Carregando...',
              );
            },
          ),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Data',
            value: DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(widget.reservation.startTime),
          ),
          InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Horário',
            value: '${TimeOfDay.fromDateTime(widget.reservation.startTime).format(context)} - ${TimeOfDay.fromDateTime(widget.reservation.endTime).format(context)}',
          ),
          InfoRow(
            icon: Icons.attach_money_outlined,
            label: 'Preço',
            value: 'R\$ ${widget.reservation.price.toStringAsFixed(2)}',
          ),
          if (widget.reservation.notes.isNotEmpty)
            InfoRow(
              icon: Icons.notes_outlined,
              label: 'Observações',
              value: widget.reservation.notes,
            ),

          const SizedBox(height: 16),

          // --- Botões de Ação ---
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                  onPressed: _cancelReservation,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmar'),
                  onPressed: widget.reservation.status == 'confirmada' ? null : _confirmReservation,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Componentes Auxiliares ---

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRow({Key? key, required this.icon, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({Key? key, required this.status}) : super(key: key);

  Color _getColor() {
    switch (status) {
      case 'confirmada': return Colors.blue;
      case 'pendente': return Colors.orange;
      case 'bloqueado': return Colors.grey;
      case 'cancelada': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'confirmada': return Icons.check_circle;
      case 'pendente': return Icons.hourglass_empty;
      case 'bloqueado': return Icons.block;
      case 'cancelada': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_getIcon(), color: Colors.white, size: 16),
      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
      backgroundColor: _getColor(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
