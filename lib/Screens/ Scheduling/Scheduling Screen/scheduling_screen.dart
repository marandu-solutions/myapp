// Arquivo: lib/Scheduling/SchedulingScreen/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/models/reservation_model.dart';
import 'package:myapp/services/court_service.dart';
import 'package:myapp/services/reservataion_service.dart';
import 'components/day_schedule_view.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

  late Future<List<CourtModel>> _courtsFuture;
  Future<List<ReservationModel>>? _reservationsFuture;

  CourtModel? _selectedCourt;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'pt_BR';
    _loadInitialData();
  }

  // Carrega os dados iniciais (quadras e depois as reservas da primeira quadra)
  void _loadInitialData() {
    _courtsFuture = _courtService.getAllCourts();
    _courtsFuture.then((courts) {
      if (courts.isNotEmpty && mounted) {
        setState(() {
          _selectedCourt = courts.first;
          _fetchReservations(); // Busca as reservas para a primeira quadra
        });
      }
    });
  }

  // Busca as reservas para a quadra e data atualmente selecionadas
  void _fetchReservations() {
    if (_selectedCourt == null) return;
    setState(() {
      _reservationsFuture = _reservationService.getReservationsForCourtByDate(
        _selectedCourt!.id,
        _selectedDate,
      );
    });
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
        _fetchReservations(); // Busca reservas para a nova data
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
                // FutureBuilder para carregar o Dropdown de quadras
                FutureBuilder<List<CourtModel>>(
                  future: _courtsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar quadras.');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Nenhuma quadra encontrada.');
                    }
                    
                    final courts = snapshot.data!;
                    return DropdownButtonFormField<CourtModel>(
                      value: _selectedCourt,
                      decoration: const InputDecoration(
                        labelText: 'Selecione a Quadra',
                        border: OutlineInputBorder(),
                      ),
                      items: courts.map((CourtModel court) {
                        return DropdownMenuItem<CourtModel>(
                          value: court,
                          child: Text(court.name),
                        );
                      }).toList(),
                      onChanged: (CourtModel? newCourt) {
                        setState(() {
                          _selectedCourt = newCourt!;
                          _fetchReservations(); // Busca reservas para a nova quadra
                        });
                      },
                    );
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
                          _fetchReservations();
                        });
                      },
                    ),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Text(
                        DateFormat("dd 'de' MMMM 'de' yyyy").format(_selectedDate),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                          _fetchReservations();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // FutureBuilder para carregar a visualização da agenda
          Expanded(
            child: FutureBuilder<List<ReservationModel>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                // Mostra o loader apenas se uma busca estiver em andamento
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar agendamentos: ${snapshot.error}'));
                }
                final reservations = snapshot.data ?? [];
                if (reservations.isEmpty && _selectedCourt != null) {
                    return const Center(child: Text('Nenhum agendamento para este dia.'));
                }
                return DayScheduleView(
                  reservations: reservations,
                  date: _selectedDate,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
