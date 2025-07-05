// Arquivo: lib/Scheduling/SchedulingScreen/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/models/reservation_model.dart';
import 'components/day_schedule_view.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  // Em um app real, você usaria seus services para buscar estes dados do Firestore
  final List<CourtModel> _courts = [
    CourtModel(id: '1', name: 'Quadra Poliesportiva A', sportType: 'Futsal', gymId: 'gym1', pricePerHour: 50.0, isActive: true),
    CourtModel(id: '2', name: 'Quadra de Tênis B', sportType: 'Tênis', gymId: 'gym1', pricePerHour: 70.0, isActive: true),
    CourtModel(id: '3', name: 'Campo de Society', sportType: 'Futebol', gymId: 'gym2', pricePerHour: 120.0, isActive: true),
  ];

  final List<ReservationModel> _reservations = [
    ReservationModel(id: 'r1', title: 'Reserva - João Silva', courtId: '1', clientId: 'c1', startTime: DateTime.now().copyWith(hour: 9, minute: 0), endTime: DateTime.now().copyWith(hour: 10, minute: 30), status: 'confirmada'),
    ReservationModel(id: 'r2', title: 'Aula de Tênis', courtId: '2', clientId: 'c2', startTime: DateTime.now().copyWith(hour: 11, minute: 0), endTime: DateTime.now().copyWith(hour: 12, minute: 0), status: 'confirmada'),
    ReservationModel(id: 'r3', title: 'Futebol - Amigos', courtId: '1', clientId: 'c3', startTime: DateTime.now().copyWith(hour: 14, minute: 30), endTime: DateTime.now().copyWith(hour: 16, minute: 0), status: 'pendente'),
    ReservationModel(id: 'r4', title: 'Manutenção', courtId: '3', clientId: 'admin', startTime: DateTime.now().copyWith(hour: 12, minute: 0), endTime: DateTime.now().copyWith(hour: 13, minute: 0), status: 'bloqueado'),
  ];

  late CourtModel _selectedCourt;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCourt = _courts.first;
    Intl.defaultLocale = 'pt_BR';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // TODO: Fazer nova busca no Firestore pelas reservas da nova data e quadra
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda da Quadra'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<CourtModel>(
                  value: _selectedCourt,
                  decoration: const InputDecoration(
                    labelText: 'Selecione a Quadra',
                    border: OutlineInputBorder(),
                  ),
                  items: _courts.map((CourtModel court) {
                    return DropdownMenuItem<CourtModel>(
                      value: court,
                      child: Text(court.name),
                    );
                  }).toList(),
                  onChanged: (CourtModel? newCourt) {
                    setState(() {
                      _selectedCourt = newCourt!;
                      // TODO: Fazer nova busca no Firestore
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Text(
                        DateFormat('dd \'de\' MMMM \'de\' yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: DayScheduleView(
              reservations: _reservations,
              date: _selectedDate,
            ),
          ),
        ],
      ),
    );
  }
}
