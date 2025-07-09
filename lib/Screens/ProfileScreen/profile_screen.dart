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
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do perfil: $e");
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
      // Salva a imagem imediatamente para uma melhor UX
      _saveChanges(showSnackbar: false);
    }
  }

  Future<void> _saveChanges({bool showSnackbar = true}) async {
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

      if (mounted && showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
      }
      // Recarrega os dados para garantir que a UI esteja sincronizada
      await _loadUserData();
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar Perfil',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Cancelar Edição',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? const Center(child: Text('Não foi possível carregar o perfil.'))
          : RefreshIndicator(
        onRefresh: _loadUserData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 20),
            // --- Seção de Cabeçalho ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : (_currentUser!.fotoUrl.isNotEmpty
                        ? NetworkImage(_currentUser!.fotoUrl)
                        : null) as ImageProvider?,
                    child: _imageBytes == null && _currentUser!.fotoUrl.isEmpty
                        ? Text(
                      _currentUser!.nomeCompleto.isNotEmpty ? _currentUser!.nomeCompleto[0] : 'U',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _currentUser!.nomeCompleto,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                _currentUser!.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),

            // --- Seção de Informações Pessoais ---
            const SectionTitle(title: 'Informações Pessoais'),
            ProfileInfoCard(
              children: [
                EditableProfileField(
                  label: 'Nome Completo',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  isEditing: _isEditing,
                ),
                const Divider(height: 1),
                EditableProfileField(
                  label: 'Telefone',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Seção de Segurança ---
            const SectionTitle(title: 'Segurança'),
            ProfileInfoCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.blue),
                  title: const Text('Alterar Senha'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navegar para a tela de alteração de senha
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Botão de Salvar ou Sair ---
            if (_isEditing)
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sair da Conta', style: TextStyle(color: Colors.red)),
                onPressed: _performLogout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- Componentes Reutilizáveis ---

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final List<Widget> children;
  const ProfileInfoCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class EditableProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType? keyboardType;

  const EditableProfileField({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.isEditing,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500]),
          const SizedBox(width: 16),
          Expanded(
            child: isEditing
                ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 2),
                Text(controller.text, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
