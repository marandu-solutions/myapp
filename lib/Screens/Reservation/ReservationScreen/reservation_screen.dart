// Arquivo: lib/Scheduling/CreateReservation/create_reservation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/court_model.dart';
import '../../../models/gym_model.dart';
import '../../../models/reservation_model.dart';
import '../../../services/court_service.dart';
import '../../../services/gyms_service.dart';
import '../../../services/reservataion_service.dart';
import '../../../themes.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({Key? key}) : super(key: key);

  @override
  _CreateReservationScreenState createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Reserva');
  final _notesController = TextEditingController();

  final GymService _gymService = GymService();
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

  late Future<List<GymModel>> _gymsFuture;
  Future<List<CourtModel>>? _courtsFuture;

  GymModel? _selectedGym;
  CourtModel? _selectedCourt;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gymsFuture = _gymService.getAllGyms();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
  void _onGymSelected(GymModel? gym) {
    if (gym == null) return;
    setState(() {
      _selectedGym = gym;
      _selectedCourt = null;
      _courtsFuture = _courtService.getCourtsForGym(gym.id);
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // O DatePicker herdará o tema do MaterialApp
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // O TimePicker herdará o tema do MaterialApp
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    if (_selectedCourt == null ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      _showFeedbackSnackbar(
          'Por favor, preencha todos os campos de data e hora.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startTime = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _startTime!.hour, _startTime!.minute);
      final endTime = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _endTime!.hour, _endTime!.minute);

      final newReservation = ReservationModel(
        id: '',
        title: _titleController.text.trim(),
        courtId: _selectedCourt!.id,
        gymId: _selectedGym!.id,
        clientId: 'temp_client_id',
        startTime: startTime,
        endTime: endTime,
        status: 'confirmada',
        notes: _notesController.text.trim(),
        price: _selectedCourt!.pricePerHour *
            (endTime.difference(startTime).inMinutes / 60.0),
        isPaid: false,
      );

      await _reservationService.createReservation(newReservation);

      if (mounted) {
        _showFeedbackSnackbar('Reserva criada com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackSnackbar('Erro ao criar reserva: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- MÉTODOS DE UI (AQUI ESTÃO AS MUDANÇAS DE DESIGN) ---

  void _showFeedbackSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Theme.of(context).colorScheme.error : AppTheme.colorSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Título da Reserva',
                    prefixIcon: Icon(Icons.label_outline)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<GymModel>>(
                future: _gymsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  return DropdownButtonFormField<GymModel>(
                    value: _selectedGym,
                    hint: const Text('Selecione um Ginásio'),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.sports_basketball_outlined)),
                    items: snapshot.data
                        ?.map((gym) =>
                        DropdownMenuItem(value: gym, child: Text(gym.nome)))
                        .toList(),
                    onChanged: _onGymSelected,
                    validator: (v) => v == null ? 'Campo obrigatório' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_selectedGym != null)
                FutureBuilder<List<CourtModel>>(
                  future: _courtsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Nenhuma quadra para este ginásio.');
                    }
                    return DropdownButtonFormField<CourtModel>(
                      value: _selectedCourt,
                      hint: const Text('Selecione uma Quadra'),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.sports_soccer_outlined)),
                      items: snapshot.data
                          ?.map((court) => DropdownMenuItem(
                          value: court, child: Text(court.name)))
                          .toList(),
                      onChanged: (court) => setState(() => _selectedCourt = court),
                      validator: (v) => v == null ? 'Campo obrigatório' : null,
                    );
                  },
                ),
              const SizedBox(height: 24),
              _buildPickerTile(
                icon: Icons.calendar_today,
                label: 'Data',
                value: _selectedDate == null
                    ? 'Selecione uma data'
                    : DateFormat("dd/MM/yyyy").format(_selectedDate!),
                onTap: _pickDate,
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerTile(
                      icon: Icons.access_time,
                      label: 'Início',
                      value: _startTime == null
                          ? 'Hora'
                          : _startTime!.format(context),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(
                      height: 50,
                      child: VerticalDivider(
                        width: 1,
                      )),
                  Expanded(
                    child: _buildPickerTile(
                      icon: Icons.access_time_filled,
                      label: 'Fim',
                      value:
                      _endTime == null ? 'Hora' : _endTime!.format(context),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      prefixIcon: Icon(Icons.notes_outlined))),
              const SizedBox(height: 32),
              _isLoading
                  ? Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary))
                  : ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Agendamento'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os seletores de data e hora
  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
