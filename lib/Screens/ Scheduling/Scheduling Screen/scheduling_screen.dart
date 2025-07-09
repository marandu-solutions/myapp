// Arquivo: lib/Scheduling/SchedulingScreen/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/court_model.dart';
import '../../../models/gym_model.dart';
import '../../../models/reservation_model.dart';
import '../../../services/court_service.dart';
import '../../../services/gyms_service.dart';
import '../../../services/reservataion_service.dart';
import '../../Reservation/ReservationScreen/reservation_screen.dart';
import 'components/week_schedule_view.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final GymService _gymService = GymService();
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

  late Future<List<GymModel>> _gymsFuture;
  Future<List<CourtModel>>? _courtsFuture;
  Future<List<ReservationModel>>? _reservationsFuture;

  GymModel? _selectedGym;
  CourtModel? _selectedCourt;
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'pt_BR';
    _loadInitialData();
  }

  void _loadInitialData() {
    _gymsFuture = _gymService.getAllGyms();
    _gymsFuture.then((gyms) {
      if (gyms.isNotEmpty && mounted) {
        _onGymSelected(gyms.first);
      }
    });
  }

  void _onGymSelected(GymModel gym) {
    setState(() {
      _selectedGym = gym;
      _selectedCourt = null;
      _reservationsFuture = null;
      _courtsFuture = _courtService.getCourtsForGym(gym.id);
    });
  }

  void _onCourtSelected(CourtModel court) {
    setState(() {
      _selectedCourt = court;
      _fetchReservationsForWeek();
    });
  }

  void _fetchReservationsForWeek() {
    if (_selectedCourt == null) return;
    final startOfWeek = _getStartOfWeek(_focusedDate);
    setState(() {
      _reservationsFuture = _reservationService.getReservationsForWeek(
        _selectedCourt!.id,
        startOfWeek,
      );
    });
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _getWeekRangeTitle() {
    final startOfWeek = _getStartOfWeek(_focusedDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    if (startOfWeek.month == endOfWeek.month) {
      return '${startOfWeek.day} - ${endOfWeek.day} de ${DateFormat.MMMM('pt_BR').format(endOfWeek)}';
    }
    return '${DateFormat('d MMM', 'pt_BR').format(startOfWeek)} - ${DateFormat('d MMM', 'pt_BR').format(endOfWeek)}';
  }

  // CORREÇÃO: Método adicionado de volta à classe
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _focusedDate) {
      setState(() {
        _focusedDate = picked;
        _fetchReservationsForWeek(); // Busca reservas para a nova data
      });
    }
  }

  void _navigateAndCreateReservation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateReservationScreen(),
      ),
    ).then((_) {
      _fetchReservationsForWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Semanal'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FutureBuilder<List<GymModel>>(
                        future: _gymsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Carregando ginásios...');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Nenhum ginásio encontrado.');
                          }
                          return DropdownButtonFormField<GymModel>(
                            value: _selectedGym,
                            decoration: const InputDecoration(labelText: 'Ginásio', border: OutlineInputBorder()),
                            items: snapshot.data!.map((gym) => DropdownMenuItem(value: gym, child: Text(gym.nome))).toList(),
                            onChanged: (gym) {
                              if (gym != null) _onGymSelected(gym);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FutureBuilder<List<CourtModel>>(
                        future: _courtsFuture,
                        builder: (context, snapshot) {
                          if (_selectedGym == null) return const SizedBox.shrink();
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Nenhuma quadra.');
                          }
                          return DropdownButtonFormField<CourtModel>(
                            value: _selectedCourt,
                            hint: const Text('Selecione'),
                            decoration: const InputDecoration(labelText: 'Quadra', border: OutlineInputBorder()),
                            items: snapshot.data!.map((court) => DropdownMenuItem(value: court, child: Text(court.name))).toList(),
                            onChanged: (court) {
                              if (court != null) _onCourtSelected(court);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () { setState(() { _focusedDate = _focusedDate.subtract(const Duration(days: 7)); _fetchReservationsForWeek(); }); }),
                    InkWell(onTap: () => _selectDate(context), child: Text(_getWeekRangeTitle(), style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { setState(() { _focusedDate = _focusedDate.add(const Duration(days: 7)); _fetchReservationsForWeek(); }); }),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<ReservationModel>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (_selectedCourt == null) {
                  return const Center(child: Text('Selecione uma quadra para ver a agenda.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final reservations = snapshot.data ?? [];
                return WeekScheduleView(
                  reservations: reservations,
                  weekStartDate: _getStartOfWeek(_focusedDate),
                  onActionCompleted: _fetchReservationsForWeek,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndCreateReservation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Novo Agendamento',
      ),
    );
  }
}
