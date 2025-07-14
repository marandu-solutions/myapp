// Arquivo: lib/Scheduling/SchedulingScreen/components/reservation_details_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/reservation_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/services/reservataion_service.dart';

import '../../../themes.dart';

class ReservationDetailsSheet extends StatefulWidget {
  final ReservationModel reservation;
  final VoidCallback onActionCompleted;

  const ReservationDetailsSheet({
    Key? key,
    required this.reservation,
    required this.onActionCompleted,
  }) : super(key: key);

  @override
  State<ReservationDetailsSheet> createState() =>
      _ReservationDetailsSheetState();
}

class _ReservationDetailsSheetState extends State<ReservationDetailsSheet> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final ReservationService _reservationService = ReservationService();
  bool _isLoading = false;

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
  void _confirmReservation() async {
    setState(() => _isLoading = true);
    try {
      await _reservationService.updateReservationStatus(
          widget.reservation.id, 'confirmada');
      if (mounted) {
        _showFeedbackSnackbar('Reserva confirmada!');
        widget.onActionCompleted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showFeedbackSnackbar('Erro ao confirmar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _cancelReservation() async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
          title: const Text('Cancelar Reserva'),
          content: const Text(
              'Você tem certeza que deseja cancelar este agendamento? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Manter'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Sim, Cancelar'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    setState(() => _isLoading = true);
    try {
      await _reservationService.deleteReservation(widget.reservation.id);
      if (mounted) {
        _showFeedbackSnackbar('Reserva cancelada com sucesso.');
        widget.onActionCompleted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showFeedbackSnackbar('Erro ao cancelar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- MÉTODOS DE UI (AQUI ESTÃO AS MUDANÇAS DE DESIGN) ---

  void _showFeedbackSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : AppTheme.colorSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final UserService userService = UserService();

    return Padding(
      // Padding para o teclado
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: 16),
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
                value: snapshot.hasData
                    ? snapshot.data!.nomeCompleto
                    : 'Carregando...',
              );
            },
          ),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Data',
            value: DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
                .format(widget.reservation.startTime),
          ),
          InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Horário',
            value:
            '${TimeOfDay.fromDateTime(widget.reservation.startTime).format(context)} - ${TimeOfDay.fromDateTime(widget.reservation.endTime).format(context)}',
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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                  onPressed: _cancelReservation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                        color: theme.colorScheme.error.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmar'),
                  onPressed: widget.reservation.status == 'confirmada'
                      ? null
                      : _confirmReservation,
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
  const InfoRow(
      {Key? key, required this.icon, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.titleMedium),
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
    switch (status.toLowerCase()) {
      case 'confirmada':
        return AppTheme.colorSuccess;
      case 'pendente':
        return AppTheme.colorWarning;
      case 'bloqueado':
        return AppTheme.colorError.withOpacity(0.7);
      case 'cancelada':
        return AppTheme.colorError;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return Icons.check_circle;
      case 'pendente':
        return Icons.hourglass_empty;
      case 'bloqueado':
        return Icons.block;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor();
    return Chip(
      avatar: Icon(_getIcon(), color: theme.colorScheme.onPrimary, size: 16),
      label: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onPrimary),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
