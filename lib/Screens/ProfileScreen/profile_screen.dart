// Arquivo: lib/screens/Profile/profile_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/screens/Auth/LoginScreen/login_screen.dart';
import 'dart:typed_data';

import '../../themes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final UserService _userService = UserService();
  final _auth = FirebaseAuth.instance;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Uint8List? _imageBytes;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE LÓGICA (NENHUMA ALTERAÇÃO) ---
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userModel = await _userService.getUser(user.uid);
        if (mounted) {
          setState(() {
            _currentUser = userModel;
            _nameController.text = _currentUser?.nomeCompleto ?? '';
            _phoneController.text = _currentUser?.telefone ?? '';
            _pickedImage = null;
            _imageBytes = null;
          });
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Erro ao carregar dados: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      _saveChanges(showSnackbar: false);
    }
  }

  Future<void> _saveChanges({bool showSnackbar = true}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      String imageUrl = _currentUser?.fotoUrl ?? '';
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child('${_currentUser!.uid}.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        imageUrl = await storageRef.getDownloadURL();
      }

      final updatedData = {
        'nomeCompleto': _nameController.text,
        'telefone': _phoneController.text,
        'fotoUrl': imageUrl,
      };

      await _userService.updateUser(_currentUser!.uid, updatedData);
      await _loadUserData();

      if (mounted && showSnackbar) {
        _showSuccessSnackBar('Perfil atualizado com sucesso!');
      }
      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Erro ao atualizar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _performLogout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          if (!_isLoading && _currentUser != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
              onPressed: () => setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _nameController.text = _currentUser?.nomeCompleto ?? '';
                  _phoneController.text = _currentUser?.telefone ?? '';
                }
              }),
              tooltip: _isEditing ? 'Cancelar Edição' : 'Editar Perfil',
            )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : _currentUser == null
          ? Center(
          child: TextButton(
              onPressed: _loadUserData,
              child: const Text(
                  'Não foi possível carregar o perfil. Tentar novamente.')))
          : LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 768) {
            return _buildMobileLayout();
          } else {
            return _buildWebLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: Theme.of(context).colorScheme.primary,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Informações Pessoais'),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Segurança'),
            _buildSecurityCard(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const Spacer(),
                          if (!_isEditing) _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.all(32.0),
                      child: ListView(
                        children: [
                          _buildSectionTitle('Informações Pessoais'),
                          _buildInfoCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Segurança'),
                          _buildSecurityCard(),
                          const SizedBox(height: 40),
                          if (_isEditing) _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : (_currentUser!.fotoUrl.isNotEmpty
                  ? NetworkImage(_currentUser!.fotoUrl)
                  : null) as ImageProvider?,
              child: _imageBytes == null && _currentUser!.fotoUrl.isEmpty
                  ? Text(
                _currentUser!.nomeCompleto.isNotEmpty
                    ? _currentUser!.nomeCompleto[0].toUpperCase()
                    : 'U',
                style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
              )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: theme.cardColor,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt,
                        color: theme.colorScheme.onPrimary, size: 20),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentUser!.nomeCompleto,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser!.email,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _EditableProfileField(
            label: 'Nome Completo',
            icon: Icons.person_outline,
            controller: _nameController,
            isEditing: _isEditing,
          ),
          const Divider(height: 1),
          _EditableProfileField(
            label: 'Telefone',
            icon: Icons.phone_outlined,
            controller: _phoneController,
            isEditing: _isEditing,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
        title: const Text('Alterar Senha'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navegação para alterar senha (a implementar)')));
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return _isEditing ? _buildSaveButton() : _buildLogoutButton();
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar Alterações'),
        onPressed: _saveChanges,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Sair da Conta'),
        onPressed: _performLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType? keyboardType;

  const _EditableProfileField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.isEditing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          validator: (value) =>
          (value == null || value.isEmpty) ? 'Este campo não pode ser vazio' : null,
        ),
      );
    } else {
      return ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Text(
          controller.text.isNotEmpty ? controller.text : 'Não informado',
          style: theme.textTheme.titleMedium,
        ),
      );
    }
  }
}
