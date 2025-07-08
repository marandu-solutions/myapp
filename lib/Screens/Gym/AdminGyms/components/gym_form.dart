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

class AddGymSheet extends StatefulWidget {
  final VoidCallback onGymAdded;
  const AddGymSheet({Key? key, required this.onGymAdded}) : super(key: key);

  @override
  _AddGymSheetState createState() => _AddGymSheetState();
}

class _AddGymSheetState extends State<AddGymSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingTimeController = TextEditingController(text: '08:00');
  final _closingTimeController = TextEditingController(text: '22:00');

  final GymService _gymService = GymService();
  Uint8List? _imageBytes;
  XFile? _pickedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String imageUrl = '';

      // Cria o modelo primeiro para ter um ID temporário para a foto
      final newGymData = GymModel(
        id: '', // O Firestore gerará o ID
        nome: _nameController.text.trim(),
        endereco: _addressController.text.trim(),
        fotoUrl: '', // Será atualizada depois
        horarioAbertura: _openingTimeController.text.trim(),
        horarioFechamento: _closingTimeController.text.trim(),
        ativo: true,
      );

      // Salva o ginásio no Firestore e obtém a referência do documento
      DocumentReference docRef = await _gymService.createGym(newGymData);
      String gymId = docRef.id;

      // Faz o upload da foto se uma foi selecionada
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('gym_photos').child('$gymId.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        imageUrl = await storageRef.getDownloadURL();

        // Atualiza o documento do ginásio com a URL da foto
        await _gymService.updateGym(gymId, {'fotoUrl': imageUrl});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ginásio adicionado com sucesso!'), backgroundColor: Colors.green),
        );
        widget.onGymAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar ginásio: $e'), backgroundColor: Colors.red),
        );
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
              Text('Novo Ginásio', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[400]!, width: 2),
                      image: _imageBytes != null ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) : null,
                    ),
                    child: _imageBytes == null
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.grey[600], size: 40),
                      const SizedBox(height: 8),
                      Text('Adicionar Foto', style: TextStyle(color: Colors.grey[700])),
                    ])
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Ginásio'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Endereço'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _openingTimeController, decoration: const InputDecoration(labelText: 'Abre às'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _closingTimeController, decoration: const InputDecoration(labelText: 'Fecha às'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null)),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Salvar Ginásio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
