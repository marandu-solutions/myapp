// Arquivo: lib/screens/Gyms/ManageGym/components/gym_info_tab.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/gym_model.dart';
import 'dart:typed_data';

import '../../../../services/gyms_service.dart';

class GymInfoTab extends StatefulWidget {
  final GymModel gym;

  const GymInfoTab({Key? key, required this.gym}) : super(key: key);

  @override
  _GymInfoTabState createState() => _GymInfoTabState();
}

class _GymInfoTabState extends State<GymInfoTab> {
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
    _openingTimeController = TextEditingController(text: widget.gym.horarioAbertura);
    _closingTimeController = TextEditingController(text: widget.gym.horarioFechamento);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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
      // Faz o upload da nova foto se uma foi selecionada
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('gym_photos').child('${widget.gym.id}.jpg');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ginásio atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _saveChanges();
          } else {
            setState(() => _isEditing = true);
          }
        },
        backgroundColor: Colors.blue,
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined, color: Colors.white),
        tooltip: _isEditing ? 'Salvar' : 'Editar',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção da Imagem
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (_imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (widget.gym.fotoUrl.isNotEmpty
                          ? NetworkImage(widget.gym.fotoUrl)
                          : const AssetImage('assets/placeholder.png'))) // Fallback para um asset local
                      as ImageProvider,
                    ),
                  ),
                  child: _isEditing
                      ? const Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Campos de Informação Editáveis
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: 'Nome do Ginásio'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: 'Endereço'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              Text('Horário de Funcionamento', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _openingTimeController, enabled: _isEditing, decoration: const InputDecoration(labelText: 'Abre às'))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _closingTimeController, enabled: _isEditing, decoration: const InputDecoration(labelText: 'Fecha às'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
