// Arquivo: lib/Scheduling/SchedulingScreen/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/court_model.dart';
import '../../../models/gym_model.dart';
import '../../../models/reservation_model.dart';
import '../../../services/court_service.dart';
import '../../../services/gyms_service.dart';
import '../../../services/reservataion_service.dart';
import 'components/day_schedule_view.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final GymService _gymService = GymService();
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

  // Futuros para carregar os dados dos dropdowns
  late Future<List<GymModel>> _gymsFuture;
  Future<List<CourtModel>>? _courtsFuture;

  // Futuro para carregar os agendamentos da agenda
  Future<List<ReservationModel>>? _reservationsFuture;

  // Itens selecionados
  GymModel? _selectedGym;
  CourtModel? _selectedCourt;
  DateTime _selectedDate = DateTime.now();

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
        // Seleciona o primeiro ginásio da lista e busca suas quadras
        _onGymSelected(gyms.first);
      }
    });
  }

  // Chamado quando um ginásio é selecionado
  void _onGymSelected(GymModel gym) {
    setState(() {
      _selectedGym = gym;
      _selectedCourt = null; // Reseta a quadra selecionada
      _reservationsFuture = null; // Limpa os agendamentos antigos
      // Busca as quadras para o novo ginásio selecionado
      _courtsFuture = _courtService.getCourtsForGym(gym.id);
    });
  }

  // Chamado quando uma quadra é selecionada
  void _onCourtSelected(CourtModel court) {
    setState(() {
      _selectedCourt = court;
      _fetchReservations(); // Busca os agendamentos para a nova quadra
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
        _fetchReservations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- SELETORES DE GINÁSIO E QUADRA ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown de Ginásios
                    Expanded(
                      child: FutureBuilder<List<GymModel>>(
                        future: _gymsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('A carregar ginásios...');
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
                    // Dropdown de Quadras
                    Expanded(
                      child: FutureBuilder<List<CourtModel>>(
                        future: _courtsFuture,
                        builder: (context, snapshot) {
                          if (_selectedGym == null) return const SizedBox.shrink();
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: LinearProgressIndicator());
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
                // Seletor de Data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() { _selectedDate = _selectedDate.subtract(const Duration(days: 1)); _fetchReservations(); })),
                    InkWell(onTap: () => _selectDate(context), child: Text(DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(_selectedDate), style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() { _selectedDate = _selectedDate.add(const Duration(days: 1)); _fetchReservations(); })),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Visualização da Agenda
          Expanded(
            child: FutureBuilder<List<ReservationModel>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (_selectedCourt == null) return const Center(child: Text('Selecione uma quadra para ver a agenda.'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));

                final reservations = snapshot.data ?? [];
                return DayScheduleView(reservations: reservations, date: _selectedDate);
              },
            ),
          ),
        ],
      ),
    );
  }
}
