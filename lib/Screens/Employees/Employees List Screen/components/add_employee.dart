// Arquivo: lib/widgets/add_employee_sheet.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/services/employee_service.dart';
import 'dart:typed_data';

import '../../../../themes.dart';

class AddEmployeeSheet extends StatefulWidget {
  final VoidCallback onEmployeeAdded;
  const AddEmployeeSheet({Key? key, required this.onEmployeeAdded})
      : super(key: key);

  @override
  _AddEmployeeSheetState createState() => _AddEmployeeSheetState();
}

class _AddEmployeeSheetState extends State<AddEmployeeSheet> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final EmployeeService _employeeService = EmployeeService();

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

    String tempAppName =
        'temp_employee_creation_${DateTime.now().millisecondsSinceEpoch}';

    try {
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: tempAppName,
        options: Firebase.app().options,
      );
      FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      UserCredential userCredential =
      await tempAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;

      String imageUrl = '';
      if (_pickedImage != null) {
        final storageRef =
        FirebaseStorage.instance.ref().child('employee_photos').child('$uid.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        imageUrl = await storageRef.getDownloadURL();
      }

      final newEmployee = EmployeeModel(
        uid: uid,
        nomeCompleto: _nameController.text.trim(),
        email: _emailController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _phoneController.text.trim(),
        fotoUrl: imageUrl,
        ativo: true,
      );

      await _employeeService.createEmployee(newEmployee);
      await tempApp.delete();

      if (mounted) {
        _showSuccessSnackBar('Funcionário adicionado com sucesso!');
        widget.onEmployeeAdded();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro ao criar a conta.';
      if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso.';
      } else if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      }
      if (mounted) _showErrorSnackBar(message);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Erro ao adicionar funcionário: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            Text(
              'Novo Funcionário',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  backgroundImage:
                  _imageBytes != null ? MemoryImage(_imageBytes!) : null,
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
                              color: theme.colorScheme
                                  .onSecondaryContainer)),
                    ],
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person_outline)),
              validator: (value) =>
              value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
              value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                  labelText: 'Senha Provisória',
                  prefixIcon: Icon(Icons.lock_outline)),
              obscureText: true,
              validator: (value) => (value == null || value.length < 6)
                  ? 'Mínimo de 6 caracteres'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                  labelText: 'CPF', prefixIcon: Icon(Icons.badge_outlined)),
              keyboardType: TextInputType.number,
              validator: (value) =>
              value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
              validator: (value) =>
              value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? Center(
                child:
                CircularProgressIndicator(color: theme.colorScheme.primary))
                : ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Salvar Funcionário'),
            ),
          ],
        ),
      ),
    );
  }
}
