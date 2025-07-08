// Arquivo: lib/Scheduling/CreateReservation/create_reservation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/court_model.dart';
import '../../../models/gym_model.dart';
import '../../../models/reservation_model.dart';
import '../../../services/court_service.dart';
import '../../../services/gyms_service.dart';
import '../../../services/reservataion_service.dart';

// Supondo que você tenha um ID de cliente logado
// import 'package:firebase_auth/firebase_auth.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({Key? key}) : super(key: key);

  @override
  _CreateReservationScreenState createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Reserva');
  final _notesController = TextEditingController();

  final GymService _gymService = GymService();
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

  // Futuros para carregar os dados
  late Future<List<GymModel>> _gymsFuture;
  Future<List<CourtModel>>? _courtsFuture;

  // Estado do formulário
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (_selectedCourt == null || _selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos de data e hora.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startTime!.hour, _startTime!.minute);
      final endTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endTime!.hour, _endTime!.minute);
      // final String clientId = FirebaseAuth.instance.currentUser!.uid; // Obter o ID do cliente logado

      final newReservation = ReservationModel(
        id: '', // Firestore gerará o ID
        title: _titleController.text.trim(),
        courtId: _selectedCourt!.id,
        gymId: _selectedGym!.id,
        clientId: 'temp_client_id', // Substituir pelo ID real
        startTime: startTime,
        endTime: endTime,
        status: 'confirmada', // Ou 'pendente' se precisar de aprovação
        notes: _notesController.text.trim(),
        price: _selectedCourt!.pricePerHour * (endTime.difference(startTime).inMinutes / 60.0),
        isPaid: false,
      );

      await _reservationService.createReservation(newReservation);

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva criada com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar reserva: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted){
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título da Reserva'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              FutureBuilder<List<GymModel>>(
                future: _gymsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Carregando ginásios...');
                  return DropdownButtonFormField<GymModel>(
                    value: _selectedGym,
                    hint: const Text('Selecione um Ginásio'),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: snapshot.data!.map((gym) => DropdownMenuItem(value: gym, child: Text(gym.nome))).toList(),
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
                    if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('Nenhuma quadra para este ginásio.');
                    return DropdownButtonFormField<CourtModel>(
                      value: _selectedCourt,
                      hint: const Text('Selecione uma Quadra'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: snapshot.data!.map((court) => DropdownMenuItem(value: court, child: Text(court.name))).toList(),
                      onChanged: (court) => setState(() => _selectedCourt = court),
                      validator: (v) => v == null ? 'Campo obrigatório' : null,
                    );
                  },
                ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null ? 'Selecione uma data' : DateFormat("dd/MM/yyyy").format(_selectedDate!)),
                onTap: _pickDate,
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(_startTime == null ? 'Início' : _startTime!.format(context)),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time_filled),
                      title: Text(_endTime == null ? 'Fim' : _endTime!.format(context)),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Observações (opcional)')),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Agendamento'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
