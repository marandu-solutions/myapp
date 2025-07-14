// lib/Screens/Scheduling/Scheduling Screen/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

// --- IMPORTAÇÕES DO SEU PROJETO ---
import '../../../models/court_model.dart';
import '../../../models/gym_model.dart';
import '../../../models/reservation_model.dart';
import '../../../services/court_service.dart';
import '../../../services/gyms_service.dart';
import '../../../services/reservataion_service.dart';
// --- IMPORTAÇÕES DAS TELAS ---
import '../../../themes.dart';
import '../../Reservation/ReservationDetails/reservation_details.dart';
import '../../Reservation/ReservationScreen/reservation_screen.dart'; // <<< TELA DE CRIAR RESERVA

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final GymService _gymService = GymService();
  final CourtService _courtService = CourtService();
  final ReservationService _reservationService = ReservationService();

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

  int? _selectedMonth;
  int? _selectedYear;

  final List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  final List<int> _years =
  List.generate(5, (index) => DateTime.now().year - 2 + index);

  // --- NENHUMA MUDANÇA NO INITSTATE OU MÉTODOS DE DADOS ---
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStartDate = _getStartOfWeek(now);
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadGyms();
  }

  void _refreshCalendar() {
    // Limpa o cache da semana atual para forçar o recarregamento
    if (_selectedCourt != null) {
      final cacheKey =
          '${_selectedCourt!.id}-${_currentWeekStartDate.toIso8601String()}';
      _cachedReservations.remove(cacheKey);
      _fetchReservationsForWeek(_currentWeekStartDate);
    }
  }

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
          SnackBar(
            content: Text('Erro ao carregar ginásios: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
          SnackBar(
              content: Text('Erro ao carregar quadras: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  void _onCourtSelected(CourtModel? selectedCourt) {
    setState(() {
      _selectedCourt = selectedCourt;
      _cachedReservations.clear();
      if (selectedCourt != null) {
        _updateCalendarDisplayDate();
        _fetchReservationsForWeek(_currentWeekStartDate);
      }
    });
  }

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
      final reservations =
      await _reservationService.getReservationsForWeek(courtId, weekDate);
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
      final displayDate = details.visibleDates.first.add(const Duration(days: 3));
      if (displayDate.month != _selectedMonth ||
          displayDate.year != _selectedYear) {
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
    final ReservationModel reservation =
        details.appointments!.first.resourceIds!.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReservationDetailsSheet(
        reservation: reservation,
        onActionCompleted: _refreshCalendar,
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // --- MÉTODOS DE BUILD (AQUI ESTÃO AS MUDANÇAS DE DESIGN) ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          if (_selectedCourt != null)
            IconButton(
              icon: Icon(Icons.today, color: theme.colorScheme.primary),
              tooltip: 'Ir para Hoje',
              onPressed: () {
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
          Divider(height: 1, thickness: 1, color: theme.dividerColor),
          Expanded(
            child: _buildCalendarView(),
          ),
        ],
      ),
      // <<< BOTÃO ADICIONADO AQUI >>>
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navega para a tela de criação de reserva
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateReservationScreen(),
            ),
          ).then((_) {
            // Quando a tela de criação for fechada, atualiza o calendário
            if (_selectedCourt != null) {
              _refreshCalendar();
            }
          });
        },
        label: const Text('Agendar'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSelectorsPanel() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<GymModel>(
                  value: _selectedGym,
                  hint: const Text('Ginásio'),
                  isExpanded: true,
                  onChanged: _onGymSelected,
                  items: _gyms.map((gym) => DropdownMenuItem(value: gym, child: Text(gym.nome, overflow: TextOverflow.ellipsis))).toList(),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.sports_basketball_outlined)),
                  disabledHint: _isLoadingGyms
                      ? const Text('Carregando...')
                      : const Text('Nenhum ginásio'),
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
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.sports_soccer_outlined)),
                  disabledHint: _isLoadingCourts
                      ? const Text('Carregando...')
                      : const Text('Selecione um ginásio'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  hint: const Text('Mês'),
                  isExpanded: true,
                  onChanged: _onMonthSelected,
                  items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_months[index]))),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_month_outlined)),
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
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_view_day_outlined)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_selectedCourt == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ballot_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'Selecione um ginásio e uma quadra para ver a agenda.',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)
                ),
              ),
            ],
          ),
        ),
      );
    }

    final cacheKey =
        '${_selectedCourt!.id}-${_currentWeekStartDate.toIso8601String()}';
    final reservations = _cachedReservations[cacheKey] ?? [];

    return Stack(
      children: [
        SfCalendar(
          controller: _calendarController,
          view: CalendarView.week,
          firstDayOfWeek: 1,
          dataSource: _ReservationDataSource(reservations),
          onViewChanged: _onViewChanged,
          onTap: _onReservationTapped,
          headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: textTheme.titleLarge,
          ),
          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            dateTextStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          timeSlotViewSettings: TimeSlotViewSettings(
            timeIntervalHeight: 60,
            startHour: 0,
            endHour: 24,
            timeFormat: 'HH:mm',
            timeTextStyle: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7)
            ),
          ),
        ),
        if (_isCalendarLoading)
          Container(
            color: theme.scaffoldBackgroundColor.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
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
      // CORREÇÃO: Removida a opacidade para deixar a cor sólida
        return AppTheme.colorSuccess;
    }
  }
}
