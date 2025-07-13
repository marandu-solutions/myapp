import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart'; // Importe para formatação de data

// --- IMPORTAÇÕES DO SEU PROJETO ---
import '../../../models/court_model.dart';
import '../../../models/gym_model.dart';
import '../../../models/reservation_model.dart';
import '../../../services/court_service.dart';
import '../../../services/gyms_service.dart';
import '../../../services/reservataion_service.dart';
import '../../Reservation/ReservationDetails/reservation_details.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  // --- SERVICES ---
  final GymService _gymService = GymService();
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

  // --- STATE MANAGEMENT ---
  List<GymModel> _gyms = [];
  List<CourtModel> _courts = [];
  GymModel? _selectedGym;
  CourtModel? _selectedCourt;
  bool _isLoadingGyms = true;
  bool _isLoadingCourts = false;
  bool _isCalendarLoading = false;

  final Map<String, List<ReservationModel>> _cachedReservations = {};
  final CalendarController _calendarController = CalendarController();
  late DateTime _currentWeekStartDate;

  // --- NOVO: Variáveis para seleção de Mês e Ano ---
  int? _selectedMonth;
  int? _selectedYear;

  // Listas para os Dropdowns
  final List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  final List<int> _years = List.generate(5, (index) => DateTime.now().year - 2 + index); // Gera 5 anos (2 passados, atual, 2 futuros)


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStartDate = _getStartOfWeek(now);

    // Define a seleção inicial para o mês e ano atuais
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _loadGyms();
  }

  // --- LÓGICA DE DADOS ---

  Future<void> _loadGyms() async {
    try {
      final gyms = await _gymService.getAllGyms();
      if (mounted) {
        setState(() {
          _gyms = gyms;
          _isLoadingGyms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGyms = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar ginásios: $e')),
        );
      }
    }
  }

  Future<void> _onGymSelected(GymModel? selectedGym) async {
    if (selectedGym == null) return;
    setState(() {
      _selectedGym = selectedGym;
      _selectedCourt = null;
      _courts = [];
      _isLoadingCourts = true;
      _cachedReservations.clear();
    });

    try {
      final courts = await _courtService.getCourtsForGym(selectedGym.id);
      if (mounted) {
        setState(() {
          _courts = courts;
          _isLoadingCourts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCourts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar quadras: $e')),
        );
      }
    }
  }

  void _onCourtSelected(CourtModel? selectedCourt) {
    setState(() {
      _selectedCourt = selectedCourt;
      _cachedReservations.clear();
      if (selectedCourt != null) {
        // Ao selecionar uma quadra, vai para a data selecionada nos dropdowns
        _updateCalendarDisplayDate();
        _fetchReservationsForWeek(_currentWeekStartDate);
      }
    });
  }

  // --- NOVOS MÉTODOS para Mês e Ano ---
  void _onMonthSelected(int? month) {
    if (month == null) return;
    setState(() {
      _selectedMonth = month;
    });
    _updateCalendarDisplayDate();
  }

  void _onYearSelected(int? year) {
    if (year == null) return;
    setState(() {
      _selectedYear = year;
    });
    _updateCalendarDisplayDate();
  }

  // Centraliza a lógica para atualizar a data de exibição do calendário
  void _updateCalendarDisplayDate() {
    if (_selectedYear != null && _selectedMonth != null) {
      final newDate = DateTime(_selectedYear!, _selectedMonth!);
      _calendarController.displayDate = newDate;
    }
  }

  Future<void> _fetchReservationsForWeek(DateTime weekDate) async {
    if (_selectedCourt == null || _isCalendarLoading) return;
    final courtId = _selectedCourt!.id;
    final cacheKey = '$courtId-${weekDate.toIso8601String()}';
    if (_cachedReservations.containsKey(cacheKey)) return;

    setState(() => _isCalendarLoading = true);
    try {
      final reservations = await _reservationService.getReservationsForWeek(courtId, weekDate);
      if (mounted) {
        setState(() {
          _cachedReservations[cacheKey] = reservations;
        });
      }
    } catch (e) {
      // Tratar erro
    } finally {
      if (mounted) {
        setState(() => _isCalendarLoading = false);
      }
    }
  }

  void _onViewChanged(ViewChangedDetails details) {
    final newWeekStartDate = _getStartOfWeek(details.visibleDates.first);

    if (newWeekStartDate != _currentWeekStartDate) {
      _currentWeekStartDate = newWeekStartDate;
      // Atualiza os seletores de mês e ano para refletir a navegação
      final displayDate = details.visibleDates.first.add(const Duration(days: 3));
      if(displayDate.month != _selectedMonth || displayDate.year != _selectedYear){
        setState(() {
          _selectedMonth = displayDate.month;
          _selectedYear = displayDate.year;
        });
      }
      _fetchReservationsForWeek(newWeekStartDate);
    }
  }

  void _onReservationTapped(CalendarTapDetails details) {
    if (details.appointments == null || details.appointments!.isEmpty) return;
    final ReservationModel reservation = details.appointments!.first.resourceIds!.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReservationDetailsSheet(
        reservation: reservation,
        onActionCompleted: () {
          final cacheKey = '${_selectedCourt!.id}-${_currentWeekStartDate.toIso8601String()}';
          _cachedReservations.remove(cacheKey);
          _fetchReservationsForWeek(_currentWeekStartDate);
        },
      ),
    );
  }

  // --- MÉTODOS DE BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          if (_selectedCourt != null)
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                // O botão 'Hoje' agora também reseta os seletores
                setState(() {
                  _selectedMonth = DateTime.now().month;
                  _selectedYear = DateTime.now().year;
                });
                _calendarController.displayDate = DateTime.now();
              },
            )
        ],
      ),
      body: Column(
        children: [
          _buildSelectorsPanel(),
          const Divider(height: 1, thickness: 1.5),
          Expanded(
            child: _buildCalendarView(),
          ),
        ],
      ),
    );
  }

  // --- MÉTODO ATUALIZADO para incluir os novos seletores ---
  Widget _buildSelectorsPanel() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column( // Envolvido em uma Coluna
        children: [
          Row( // Linha 1: Ginásio e Quadra
            children: [
              Expanded(
                child: DropdownButtonFormField<GymModel>(
                  value: _selectedGym,
                  hint: const Text('Ginásio'),
                  isExpanded: true,
                  onChanged: _onGymSelected,
                  items: _gyms.map((gym) => DropdownMenuItem(value: gym, child: Text(gym.nome, overflow: TextOverflow.ellipsis))).toList(),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  disabledHint: _isLoadingGyms ? const Text('Carregando...') : const Text('Nenhum ginásio'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<CourtModel>(
                  value: _selectedCourt,
                  hint: const Text('Quadra'),
                  isExpanded: true,
                  onChanged: _onCourtSelected,
                  items: _courts.map((court) => DropdownMenuItem(value: court, child: Text(court.name, overflow: TextOverflow.ellipsis))).toList(),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  disabledHint: _isLoadingCourts ? const Text('Carregando...') : const Text('Selecione um ginásio'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Espaçamento entre as linhas
          Row( // Linha 2: Mês e Ano
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  hint: const Text('Mês'),
                  isExpanded: true,
                  onChanged: _onMonthSelected,
                  items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_months[index]))),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  hint: const Text('Ano'),
                  isExpanded: true,
                  onChanged: _onYearSelected,
                  items: _years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))).toList(),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    if (_selectedCourt == null) {
      return const Center(
        child: Text(
          'Selecione um ginásio e uma quadra para ver a agenda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final cacheKey = '${_selectedCourt!.id}-${_currentWeekStartDate.toIso8601String()}';
    final reservations = _cachedReservations[cacheKey] ?? [];

    return Stack(
      children: [
        SfCalendar(
          controller: _calendarController,
          view: CalendarView.week,
          firstDayOfWeek: 1, // Segunda-feira
          dataSource: _ReservationDataSource(reservations),
          onViewChanged: _onViewChanged,
          onTap: _onReservationTapped,
          headerDateFormat: 'MMMM yyyy',
          timeSlotViewSettings: const TimeSlotViewSettings(
            timeIntervalHeight: 60,
            startHour: 0,
            endHour: 24,
            timeFormat: 'HH:mm',
          ),
        ),
        if (_isCalendarLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // Corrigido para semanas que começam na segunda-feira (firstDayOfWeek: 1)
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}

class _ReservationDataSource extends CalendarDataSource {
  _ReservationDataSource(List<ReservationModel> source) {
    appointments = source.map((reservation) {
      return Appointment(
        startTime: reservation.startTime,
        endTime: reservation.endTime,
        subject: reservation.title,
        color: _getReservationColor(reservation.status),
        resourceIds: [reservation],
      );
    }).toList();
  }

  @override
  Object? getResource(int index) => appointments![index].resourceIds?.first;

  Color _getReservationColor(String status) {
    switch (status) {
      case 'confirmada': return Colors.blue.shade400;
      case 'pendente': return Colors.orange.shade400;
      case 'bloqueado': return Colors.grey.shade500;
      case 'cancelada': return Colors.red.shade300;
      default: return Colors.blue.shade300;
    }
  }
}