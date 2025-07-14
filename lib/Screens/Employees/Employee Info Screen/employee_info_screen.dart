// Arquivo: lib/screens/Employees/EmployeeInfo/employee_info_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

// --- IMPORTAÇÕES DO SEU PROJETO ---
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/services/employee_service.dart';

import '../../../themes.dart';

// NOTA: Para esta tela funcionar, adicione as seguintes dependências ao seu pubspec.yaml:
// dependencies:
//   image_picker: ^1.0.4
//   firebase_storage: ^11.5.3
//   path: ^1.8.3
// E adicione uma imagem placeholder em: assets/images/placeholder.png

class EmployeeInfoScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeInfoScreen({super.key, required this.employee});

  @override
  State<EmployeeInfoScreen> createState() => _EmployeeInfoScreenState();
}

class _EmployeeInfoScreenState extends State<EmployeeInfoScreen> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
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

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
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
      return await ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro ao fazer upload da imagem: $e');
      }
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
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

      widget.employee.nomeCompleto = _nameController.text;
      widget.employee.cpf = _cpfController.text;
      widget.employee.telefone = _phoneController.text;
      widget.employee.ativo = _isActive;
      if (newImageUrl != null) widget.employee.fotoUrl = newImageUrl;

      if (mounted) {
        _showSuccessSnackBar('Funcionário atualizado com sucesso!');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Erro ao atualizar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEmployee() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _employeeService.deleteEmployee(widget.employee.uid);
      if (mounted) {
        _showInfoSnackBar('Funcionário deletado.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Erro ao deletar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- MÉTODOS DE UI (AQUI ESTÃO AS MUDANÇAS DE DESIGN) ---

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.colorSuccess,
    ));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.blueGrey,
    ));
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Você tem certeza que deseja deletar este funcionário? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Editar Funcionário')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  return _buildWebLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildProfilePicture(),
        const SizedBox(height: 16),
        Text(
          widget.employee.email,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        _buildFormFields(),
        const SizedBox(height: 40),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildWebLayout() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: theme.cardColor,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildProfilePicture(),
                        const SizedBox(height: 16),
                        Text(
                          widget.employee.email,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(32.0),
                    child: SingleChildScrollView(child: _buildFormFields()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    final theme = Theme.of(context);
    ImageProvider<Object> imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.employee.fotoUrl.isNotEmpty) {
      imageProvider = NetworkImage(widget.employee.fotoUrl);
    } else {
      imageProvider = const AssetImage('assets/images/placeholder.png');
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: imageProvider,
            onBackgroundImageError: (exception, stackTrace) {},
            child: widget.employee.fotoUrl.isEmpty && _imageFile == null
                ? Text(
              widget.employee.nomeCompleto.isNotEmpty
                  ? widget.employee.nomeCompleto[0].toUpperCase()
                  : 'F',
              style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold),
            )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: theme.cardColor,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.camera_alt,
                      color: theme.colorScheme.onPrimary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) =>
      (value == null || value.isEmpty) ? 'Este campo não pode ser vazio' : null,
    );
  }

  Widget _buildStatusSwitch() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isActive
                    ? Icons.check_circle_outline
                    : Icons.highlight_off_outlined,
                color: _isActive ? AppTheme.colorSuccess : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text('Funcionário Ativo', style: theme.textTheme.titleMedium),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeColor: AppTheme.colorSuccess,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Salvar Alterações'),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          label: Text('Deletar Funcionário',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          onPressed: _deleteEmployee,
        ),
      ],
    );
  }
}
