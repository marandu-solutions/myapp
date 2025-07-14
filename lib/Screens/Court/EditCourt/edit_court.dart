// Arquivo: lib/screens/Gyms/ManageGym/components/add_court_sheet.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/services/court_service.dart';

import '../../../themes.dart';

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
  // A lógica de negócio e estado foi mantida 100% intacta.
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
          SnackBar(
            content: const Text('Quadra adicionada com sucesso!'),
            // Usando a cor de sucesso do nosso tema
            backgroundColor: AppTheme.colorSuccess,
          ),
        );
        widget.onCourtAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar quadra: $e'),
            // Usando a cor de erro do nosso tema
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // O padding inferior é ajustado para considerar o teclado
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
            Text(
              'Nova Quadra',
              textAlign: TextAlign.center,
              // Usando o estilo de texto do tema
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              // A decoração do input vem do inputDecorationTheme.
              decoration: const InputDecoration(
                labelText: 'Nome da Quadra',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sportTypeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Esporte (Ex: Futsal)',
                prefixIcon: Icon(Icons.sports_soccer_outlined),
              ),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço por Hora',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // O estilo do botão vem do elevatedButtonTheme.
                onPressed: _submitForm,
                child: const Text('Salvar Quadra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
