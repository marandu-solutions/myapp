// Arquivo: lib/screens/Gyms/ManageGym/components/add_shift_sheet.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/models/shift_model.dart';
import 'package:myapp/services/employee_service.dart';
import 'package:myapp/services/shift_service.dart';

import '../../../../themes.dart';

class AddShiftSheet extends StatefulWidget {
  final String gymId;
  final VoidCallback onShiftAdded;

  const AddShiftSheet({
    Key? key,
    required this.gymId,
    required this.onShiftAdded,
  }) : super(key: key);

  @override
  _AddShiftSheetState createState() => _AddShiftSheetState();
}

class _AddShiftSheetState extends State<AddShiftSheet> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();
  final ShiftService _shiftService = ShiftService();

  EmployeeModel? _selectedEmployee;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployee == null || _startTime == null || _endTime == null) {
      _showFeedbackSnackbar('Por favor, preencha todos os campos.',
          isError: true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final startDateTime = DateTime(
          now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
      final endDateTime = DateTime(
          now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

      final newShift = ShiftModel(
        id: '',
        employeeId: _selectedEmployee!.uid,
        gymId: widget.gymId,
        startTime: Timestamp.fromDate(startDateTime),
        endTime: Timestamp.fromDate(endDateTime),
        diasDaSemana: [], // TODO: Implementar seletor de dias
      );

      await _shiftService.createShift(newShift);

      if (mounted) {
        _showFeedbackSnackbar('Funcionário atribuído com sucesso!');
        widget.onShiftAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackSnackbar('Erro: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final textTheme = theme.textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomPadding + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Atribuir Funcionário',
                textAlign: TextAlign.center, style: textTheme.headlineSmall),
            const SizedBox(height: 32),
            FutureBuilder<List<EmployeeModel>>(
              future: _employeeService.getAllEmployees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                return DropdownButtonFormField<EmployeeModel>(
                  value: _selectedEmployee,
                  hint: const Text('Selecione um Funcionário'),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline)),
                  items: snapshot.data
                      ?.map((employee) => DropdownMenuItem(
                      value: employee, child: Text(employee.nomeCompleto)))
                      .toList(),
                  onChanged: (employee) =>
                      setState(() => _selectedEmployee = employee),
                  validator: (v) => v == null ? 'Campo obrigatório' : null,
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Horário do Expediente', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Início',
                        prefixIcon: Icon(Icons.access_time_outlined),
                      ),
                      child: Text(
                        _startTime?.format(context) ?? 'HH:MM',
                        style: textTheme.titleMedium?.copyWith(
                            color: _startTime == null
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fim',
                        prefixIcon: Icon(Icons.access_time_filled_outlined),
                      ),
                      child: Text(
                        _endTime?.format(context) ?? 'HH:MM',
                        style: textTheme.titleMedium?.copyWith(
                            color: _endTime == null
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary))
                : ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Salvar Atribuição'),
            ),
          ],
        ),
      ),
    );
  }
}
