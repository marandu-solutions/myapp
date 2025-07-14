// Arquivo: lib/screens/Gyms/ManageGym/components/gym_info_tab.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/gym_model.dart';
import 'dart:typed_data';

import '../../../../services/gyms_service.dart';
import '../../../../themes.dart';

class GymInfoTab extends StatefulWidget {
  final GymModel gym;

  const GymInfoTab({Key? key, required this.gym}) : super(key: key);

  @override
  _GymInfoTabState createState() => _GymInfoTabState();
}

class _GymInfoTabState extends State<GymInfoTab> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final _formKey = GlobalKey<FormState>();
  final GymService _gymService = GymService();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;

  bool _isEditing = false;
  bool _isLoading = false;
  Uint8List? _imageBytes;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gym.nome);
    _addressController = TextEditingController(text: widget.gym.endereco);
    _openingTimeController =
        TextEditingController(text: widget.gym.horarioAbertura);
    _closingTimeController =
        TextEditingController(text: widget.gym.horarioFechamento);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
  Future<void> _pickImage() async {
    if (!_isEditing) return;
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.gym.fotoUrl;
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('gym_photos')
            .child('${widget.gym.id}.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        imageUrl = await storageRef.getDownloadURL();
      }

      final updatedData = {
        'nome': _nameController.text,
        'endereco': _addressController.text,
        'fotoUrl': imageUrl,
        'horarioAbertura': _openingTimeController.text,
        'horarioFechamento': _closingTimeController.text,
      };

      await _gymService.updateGym(widget.gym.id, updatedData);

      if (mounted) {
        _showFeedbackSnackbar('Ginásio atualizado com sucesso!');
        setState(() {
          _isEditing = false;
          widget.gym.fotoUrl = imageUrl; // Atualiza a URL localmente
        });
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackSnackbar('Erro ao atualizar: $e', isError: true);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isEditing) {
            _saveChanges();
          } else {
            setState(() => _isEditing = true);
          }
        },
        label: Text(_isEditing ? 'Salvar' : 'Editar'),
        icon: _isLoading
            ? Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
        tooltip: _isEditing ? 'Salvar Alterações' : 'Editar Informações',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (_imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (widget.gym.fotoUrl.isNotEmpty
                          ? NetworkImage(widget.gym.fotoUrl)
                          : const AssetImage('assets/images/placeholder.png')))
                      as ImageProvider,
                    ),
                  ),
                  child: _isEditing
                      ? Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.camera_alt_outlined,
                          color: Colors.white),
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: 'Nome do Ginásio'),
                style: theme.textTheme.headlineSmall,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                    labelText: 'Endereço',
                    prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              Text('Horário de Funcionamento', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _openingTimeController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Abre às',
                              prefixIcon: Icon(Icons.access_time_outlined)))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                          controller: _closingTimeController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                              labelText: 'Fecha às',
                              prefixIcon:
                              Icon(Icons.access_time_filled_outlined)))),
                ],
              ),
              const SizedBox(height: 80), // Espaço para o FAB não cobrir
            ],
          ),
        ),
      ),
    );
  }
}
