// Arquivo: lib/screens/Gyms/ManageGym/components/gym_employees_tab.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/models/gym_model.dart';
import 'package:myapp/models/shift_model.dart';
import 'package:myapp/services/employee_service.dart';
import 'package:myapp/services/shift_service.dart';

import 'components/add_shift.dart';

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
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddShiftSheet(
          gymId: widget.gym.id,
          onShiftAdded: _refreshShiftList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ShiftModel>>(
        future: _shiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar turnos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum funcionário atribuído a este ginásio.'));
          }

          final shifts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              final shift = shifts[index];
              return ShiftCard(shift: shift);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddShiftSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Atribuir Funcionário',
      ),
    );
  }
}

// Widget para exibir cada turno/atribuição
class ShiftCard extends StatelessWidget {
  final ShiftModel shift;
  final EmployeeService _employeeService = EmployeeService();

  ShiftCard({Key? key, required this.shift}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Busca os dados do funcionário para exibir nome e foto
    return FutureBuilder<EmployeeModel?>(
      future: _employeeService.getEmployee(shift.employeeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('Carregando...')));
        }
        final employee = snapshot.data;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              backgroundImage: (employee?.fotoUrl ?? '').isNotEmpty ? NetworkImage(employee!.fotoUrl) : null,
              child: (employee?.fotoUrl ?? '').isEmpty
                  ? Text(employee?.nomeCompleto[0] ?? 'F')
                  : null,
            ),
            title: Text(employee?.nomeCompleto ?? 'Funcionário não encontrado', style: const TextStyle(fontWeight: FontWeight.bold)),
            // CORREÇÃO: Converte o Timestamp para DateTime usando .toDate()
            subtitle: Text('Expediente: ${TimeOfDay.fromDateTime(shift.startTime.toDate()).format(context)} - ${TimeOfDay.fromDateTime(shift.endTime.toDate()).format(context)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                // TODO: Lógica para confirmar e deletar o turno
              },
            ),
          ),
        );
      },
    );
  }
}
