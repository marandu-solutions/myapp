// Arquivo: lib/screens/Profile/profile_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/screens/Auth/LoginScreen/login_screen.dart'; // Ajuste o caminho se necessário
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _imageBytes = bytes;
      });
      // Para uma UX mais fluida, a imagem é salva imediatamente.
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
        final storageRef = FirebaseStorage.instance.ref().child('user_photos').child('${_currentUser!.uid}.jpg');
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
      await _loadUserData(); // Recarrega os dados para garantir consistência

      if (mounted && showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
      }

      setState(() => _isEditing = false);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red));
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          if (!_isLoading && _currentUser != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
              onPressed: () => setState(() {
                _isEditing = !_isEditing;
                // Reseta os campos se o usuário cancelar a edição
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
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? Center(child: TextButton(onPressed: _loadUserData, child: const Text('Não foi possível carregar o perfil. Tentar novamente.')))
          : LayoutBuilder(
        builder: (context, constraints) {
          // Define um breakpoint para alternar entre os layouts
          if (constraints.maxWidth < 768) {
            return _buildMobileLayout();
          } else {
            return _buildWebLayout();
          }
        },
      ),
    );
  }

  // Layout para Telas Estreitas (Mobile)
  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
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

  // Layout para Telas Largas (Web/Desktop)
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
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coluna da Esquerda: Identidade
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const Spacer(),
                          if (!_isEditing)
                            _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                  // Coluna da Direita: Formulário e Ações
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.grey.shade50,
                      padding: const EdgeInsets.all(32.0),
                      child: ListView(
                        children: [
                          _buildSectionTitle('Informações Pessoais'),
                          _buildInfoCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Segurança'),
                          _buildSecurityCard(),
                          const SizedBox(height: 40),
                          if (_isEditing)
                            _buildSaveButton(),
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


  // --- Widgets Componentizados ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : (_currentUser!.fotoUrl.isNotEmpty
                  ? NetworkImage(_currentUser!.fotoUrl)
                  : null) as ImageProvider?,
              child: _imageBytes == null && _currentUser!.fotoUrl.isEmpty
                  ? Text(
                _currentUser!.nomeCompleto.isNotEmpty ? _currentUser!.nomeCompleto[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade700,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser!.email,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Column(
        children: [
          _EditableProfileField(
            label: 'Nome Completo',
            icon: Icons.person_outline,
            controller: _nameController,
            isEditing: _isEditing,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
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
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: ListTile(
        leading: Icon(Icons.lock_outline, color: Colors.blue.shade700),
        title: const Text('Alterar Senha'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Implementar navegação para tela de alteração de senha
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegação para alterar senha (a implementar)')));
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
      child: FilledButton.icon(
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar Alterações'),
        onPressed: _saveChanges,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.shade200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blue.shade700, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo não pode ser vazio';
            }
            return null;
          },
        ),
      );
    } else {
      return ListTile(
        leading: Icon(icon, color: Colors.grey.shade500),
        title: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        subtitle: Text(
          controller.text.isNotEmpty ? controller.text : 'Não informado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      );
    }
  }
}
