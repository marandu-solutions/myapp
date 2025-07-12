import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import 'package:myapp/models/employee_model.dart'; // Ajuste o caminho se necessário
import 'package:myapp/services/employee_service.dart'; // Ajuste o caminho se necessário

// NOTA: Para esta tela funcionar, adicione as seguintes dependências ao seu pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   image_picker: ^1.0.4
//   firebase_storage: ^11.5.3
//   path: ^1.8.3

class EmployeeInfoScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeInfoScreen({super.key, required this.employee});

  @override
  State<EmployeeInfoScreen> createState() => _EmployeeInfoScreenState();
}

class _EmployeeInfoScreenState extends State<EmployeeInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();

  late TextEditingController _nameController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  late bool _isActive;

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.employee.nomeCompleto);
    _cpfController = TextEditingController(text: widget.employee.cpf);
    _phoneController = TextEditingController(text: widget.employee.telefone);
    _isActive = widget.employee.ativo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String employeeId) async {
    if (_imageFile == null) return null;

    try {
      final fileExtension = p.extension(_imageFile!.path);
      final ref = FirebaseStorage.instance
          .ref('profile_pictures')
          .child('$employeeId$fileExtension');

      await ref.putFile(_imageFile!);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? newImageUrl;
      if (_imageFile != null) {
        newImageUrl = await _uploadImage(widget.employee.uid);
      }

      final updatedData = {
        'nomeCompleto': _nameController.text,
        'cpf': _cpfController.text,
        'telefone': _phoneController.text,
        'ativo': _isActive,
        if (newImageUrl != null) 'fotoUrl': newImageUrl,
      };

      await _employeeService.updateEmployee(widget.employee.uid, updatedData);

      // Atualiza o objeto local para refletir as mudanças imediatamente
      widget.employee.nomeCompleto = _nameController.text;
      widget.employee.cpf = _cpfController.text;
      widget.employee.telefone = _phoneController.text;
      widget.employee.ativo = _isActive;
      if (newImageUrl != null) {
        widget.employee.fotoUrl = newImageUrl;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Funcionário atualizado com sucesso!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao atualizar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEmployee() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _employeeService.deleteEmployee(widget.employee.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Funcionário deletado.'),
              backgroundColor: Colors.blueGrey),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao deletar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Você tem certeza que deseja deletar este funcionário? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Fundo um pouco cinza para web
      appBar: AppBar(
        title: const Text('Editar Funcionário', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            // LayoutBuilder decide qual layout usar com base na largura da tela
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  return _buildWebLayout(); // Layout para telas largas
                } else {
                  return _buildMobileLayout(); // Layout para telas estreitas
                }
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Layout para Mobile
  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      children: [
        _buildProfilePicture(),
        const SizedBox(height: 16),
        Text(
          widget.employee.email,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        _buildFormFields(),
        const SizedBox(height: 40),
        _buildActionButtons(),
      ],
    );
  }

  // Layout para Web/Desktop
  Widget _buildWebLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna da Esquerda
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfilePicture(),
                        const SizedBox(height: 16),
                        Text(
                          widget.employee.email,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
                // Coluna da Direita
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(32.0),
                    child: SingleChildScrollView(
                      child: _buildFormFields(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets compartilhados entre os layouts
  Widget _buildFormFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(
            controller: _nameController,
            label: 'Nome Completo',
            icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _cpfController,
            label: 'CPF',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _phoneController,
            label: 'Telefone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 24),
        _buildStatusSwitch(),
      ],
    );
  }

  Widget _buildProfilePicture() {
    ImageProvider<Object> imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.employee.fotoUrl.isNotEmpty) {
      imageProvider = NetworkImage(widget.employee.fotoUrl);
    } else {
      // É uma boa prática ter um placeholder nos seus assets
      // Ex: assets/images/placeholder.png
      // Por enquanto, usaremos um fallback de cor.
      imageProvider = const AssetImage('assets/placeholder.png');
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: imageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              // Trata erro de carregamento da imagem de rede
            },
            child: widget.employee.fotoUrl.isEmpty && _imageFile == null
                ? Text(
              widget.employee.nomeCompleto.isNotEmpty ? widget.employee.nomeCompleto[0].toUpperCase() : 'F',
              style: TextStyle(fontSize: 50, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
            )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo não pode ser vazio';
        }
        return null;
      },
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isActive ? Icons.check_circle_outline : Icons.highlight_off_outlined,
                color: _isActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              const Text('Funcionário Ativo', style: TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saveChanges,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Salvar Alterações'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('Deletar Funcionário', style: TextStyle(color: Colors.red)),
          onPressed: _deleteEmployee,
        ),
      ],
    );
  }
}
