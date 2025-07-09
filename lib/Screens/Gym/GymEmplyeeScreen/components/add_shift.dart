// Arquivo: lib/screens/Gyms/ManageGym/components/add_shift_sheet.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/models/shift_model.dart';
import 'package:myapp/services/employee_service.dart';
import 'package:myapp/services/shift_service.dart';

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
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();
  final ShiftService _shiftService = ShiftService();

  EmployeeModel? _selectedEmployee;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha todos os campos.')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      // Combina a data de hoje com a hora selecionada para criar um objeto DateTime completo
      final startDateTime = DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
      final endDateTime = DateTime(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

      // CORREÇÃO: Converte os objetos DateTime para o tipo Timestamp antes de criar o modelo.
      final newShift = ShiftModel(
        id: '', // Firestore gerará
        employeeId: _selectedEmployee!.uid,
        gymId: widget.gymId,
        startTime: Timestamp.fromDate(startDateTime),
        endTime: Timestamp.fromDate(endDateTime),
        diasDaSemana: [], // TODO: Implementar seletor de dias
      );

      await _shiftService.createShift(newShift);

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionário atribuído com sucesso!'), backgroundColor: Colors.green));
        widget.onShiftAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Atribuir Funcionário', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              FutureBuilder<List<EmployeeModel>>(
                future: _employeeService.getAllEmployees(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return DropdownButtonFormField<EmployeeModel>(
                    value: _selectedEmployee,
                    hint: const Text('Selecione um Funcionário'),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: snapshot.data!.map((employee) => DropdownMenuItem(value: employee, child: Text(employee.nomeCompleto))).toList(),
                    onChanged: (employee) => setState(() => _selectedEmployee = employee),
                    validator: (v) => v == null ? 'Campo obrigatório' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Horário do Expediente', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Início'),
                        child: Text(_startTime?.format(context) ?? 'HH:MM'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Fim'),
                        child: Text(_endTime?.format(context) ?? 'HH:MM'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Salvar Atribuição', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
