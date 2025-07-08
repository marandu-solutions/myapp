// Arquivo: lib/screens/Gyms/ManageGym/components/add_court_sheet.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/services/court_service.dart';

class AddCourtSheet extends StatefulWidget {
  final String gymId;
  final VoidCallback onCourtAdded;

  const AddCourtSheet({
    Key? key,
    required this.gymId,
    required this.onCourtAdded,
  }) : super(key: key);

  @override
  _AddCourtSheetState createState() => _AddCourtSheetState();
}

class _AddCourtSheetState extends State<AddCourtSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sportTypeController = TextEditingController();
  final _priceController = TextEditingController();

  final CourtService _courtService = CourtService();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newCourt = CourtModel(
        id: '', // Firestore gerará o ID
        name: _nameController.text.trim(),
        sportType: _sportTypeController.text.trim(),
        gymId: widget.gymId,
        pricePerHour: double.tryParse(_priceController.text) ?? 0.0,
        isActive: true,
      );

      await _courtService.createCourt(newCourt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quadra adicionada com sucesso!'), backgroundColor: Colors.green),
        );
        widget.onCourtAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar quadra: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportTypeController.dispose();
    _priceController.dispose();
    super.dispose();
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
              Text('Nova Quadra', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome da Quadra'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _sportTypeController, decoration: const InputDecoration(labelText: 'Tipo de Esporte (Ex: Futsal, Tênis)'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Preço por Hora'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Salvar Quadra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
