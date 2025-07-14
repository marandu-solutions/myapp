// Arquivo: lib/widgets/add_gym_sheet.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/gym_model.dart';
import 'dart:typed_data';

import '../../../../services/gyms_service.dart';
import '../../../../themes.dart';

class AddGymSheet extends StatefulWidget {
  final VoidCallback onGymAdded;
  const AddGymSheet({Key? key, required this.onGymAdded}) : super(key: key);

  @override
  _AddGymSheetState createState() => _AddGymSheetState();
}

class _AddGymSheetState extends State<AddGymSheet> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingTimeController = TextEditingController(text: '08:00');
  final _closingTimeController = TextEditingController(text: '22:00');

  final GymService _gymService = GymService();
  Uint8List? _imageBytes;
  XFile? _pickedImage;
  bool _isLoading = false;

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String imageUrl = '';

      final newGymData = GymModel(
        id: '',
        nome: _nameController.text.trim(),
        endereco: _addressController.text.trim(),
        fotoUrl: '',
        horarioAbertura: _openingTimeController.text.trim(),
        horarioFechamento: _closingTimeController.text.trim(),
        ativo: true,
      );

      DocumentReference docRef = await _gymService.createGym(newGymData);
      String gymId = docRef.id;

      if (_pickedImage != null) {
        final storageRef =
        FirebaseStorage.instance.ref().child('gym_photos').child('$gymId.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        imageUrl = await storageRef.getDownloadURL();
        await _gymService.updateGym(gymId, {'fotoUrl': imageUrl});
      }

      if (mounted) {
        _showFeedbackSnackbar('Ginásio adicionado com sucesso!');
        widget.onGymAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackSnackbar('Erro ao adicionar ginásio: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
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
            Text('Novo Ginásio',
                textAlign: TextAlign.center, style: textTheme.headlineSmall),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    image: _imageBytes != null
                        ? DecorationImage(
                        image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageBytes == null
                      ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            color: theme.colorScheme.onSecondaryContainer,
                            size: 40),
                        const SizedBox(height: 8),
                        Text('Adicionar Foto',
                            style: textTheme.bodyMedium?.copyWith(
                                color: theme
                                    .colorScheme.onSecondaryContainer)),
                      ])
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nome do Ginásio',
                    prefixIcon: Icon(Icons.sports_basketball_outlined)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: 'Endereço',
                    prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                        controller: _openingTimeController,
                        decoration: const InputDecoration(
                            labelText: 'Abre às',
                            prefixIcon: Icon(Icons.access_time_outlined)),
                        validator: (v) =>
                        v!.isEmpty ? 'Campo obrigatório' : null)),
                const SizedBox(width: 16),
                Expanded(
                    child: TextFormField(
                        controller: _closingTimeController,
                        decoration: const InputDecoration(
                            labelText: 'Fecha às',
                            prefixIcon: Icon(Icons.access_time_filled_outlined)),
                        validator: (v) =>
                        v!.isEmpty ? 'Campo obrigatório' : null)),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary))
                : ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Salvar Ginásio'),
            ),
          ],
        ),
      ),
    );
  }
}
