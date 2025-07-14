// Arquivo: lib/screens/Gyms/ManageGym/components/gym_employees_tab.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/models/gym_model.dart';
import 'package:myapp/models/shift_model.dart';
import 'package:myapp/services/employee_service.dart';
import 'package:myapp/services/shift_service.dart';

import '../../../themes.dart';
import 'components/add_shift.dart'; // Ajuste o caminho

class GymEmployeesTab extends StatefulWidget {
  final GymModel gym;
  const GymEmployeesTab({Key? key, required this.gym}) : super(key: key);

  @override
  _GymEmployeesTabState createState() => _GymEmployeesTabState();
}

class _GymEmployeesTabState extends State<GymEmployeesTab> {
  final ShiftService _shiftService = ShiftService();
  late Future<List<ShiftModel>> _shiftsFuture;

  @override
  void initState() {
    super.initState();
    _refreshShiftList();
  }

  void _refreshShiftList() {
    setState(() {
      _shiftsFuture = _shiftService.getShiftsForGym(widget.gym.id);
    });
  }

  void _showAddShiftSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // O AddShiftSheet já foi estilizado, apenas o invocamos
        return AddShiftSheet(
          gymId: widget.gym.id,
          onShiftAdded: _refreshShiftList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<List<ShiftModel>>(
        future: _shiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar turnos: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_outlined,
                      size: 60,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum funcionário atribuído.',
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atribua um funcionário no botão +',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final shifts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              final shift = shifts[index];
              return ShiftCard(
                shift: shift,
                onShiftDeleted: _refreshShiftList,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddShiftSheet,
        child: const Icon(Icons.add),
        tooltip: 'Atribuir Funcionário',
      ),
    );
  }
}

// Widget para exibir cada turno/atribuição
class ShiftCard extends StatelessWidget {
  final ShiftModel shift;
  final VoidCallback onShiftDeleted;
  final EmployeeService _employeeService = EmployeeService();
  final ShiftService _shiftService = ShiftService();

  ShiftCard({Key? key, required this.shift, required this.onShiftDeleted})
      : super(key: key);

  Future<void> _deleteShift(BuildContext context) async {
    final theme = Theme.of(context);
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
        title: const Text('Remover Atribuição'),
        content: const Text(
            'Você tem certeza que deseja remover este funcionário do turno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Sim, Remover'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _shiftService.deleteShift(shift.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atribuição removida com sucesso.'),
            backgroundColor: AppTheme.colorSuccess,
          ),
        );
        onShiftDeleted();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover atribuição: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return FutureBuilder<EmployeeModel?>(
      future: _employeeService.getEmployee(shift.employeeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: ListTile(title: Text('Carregando...')));
        }
        final employee = snapshot.data;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              backgroundImage: (employee?.fotoUrl ?? '').isNotEmpty
                  ? NetworkImage(employee!.fotoUrl)
                  : null,
              child: (employee?.fotoUrl ?? '').isEmpty
                  ? Text(
                employee?.nomeCompleto[0] ?? 'F',
                style: textTheme.titleLarge
                    ?.copyWith(color: colorScheme.primary),
              )
                  : null,
            ),
            title: Text(
                employee?.nomeCompleto ?? 'Funcionário não encontrado',
                style: textTheme.titleMedium),
            subtitle: Text(
                'Expediente: ${TimeOfDay.fromDateTime(shift.startTime.toDate()).format(context)} - ${TimeOfDay.fromDateTime(shift.endTime.toDate()).format(context)}'),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () => _deleteShift(context),
              tooltip: 'Remover Atribuição',
            ),
          ),
        );
      },
    );
  }
}
