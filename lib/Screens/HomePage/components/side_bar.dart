// Arquivo: lib/Screens/HomePage/components/side_bar.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:myapp/Screens/Auth/LoginScreen/login_screen.dart'; // Ajuste o caminho se necessário
import 'package:myapp/models/user_model.dart';      // Ajuste o caminho se necessário
import 'package:myapp/services/user_service.dart';    // Ajuste o caminho se necessário

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final UserService _userService = UserService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados do usuário logado do Firestore
  Future<void> _loadUserData() async {
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final userModel = await _userService.getUser(firebaseUser.uid);
      if (mounted) {
        setState(() {
          _currentUser = userModel;
        });
      }
    }
  }

  // Realiza o logout do usuário
  void _performLogout(BuildContext context) async {
    await fb_auth.FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Se os dados do usuário ainda não carregaram, mostra um loader
    if (_currentUser == null) {
      return const Drawer(
        width: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    // CORREÇÃO: A lógica de construção da lista foi ajustada
    // para garantir a ordem correta dos itens.
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_outlined, 'label': 'Início'},
      {'icon': Icons.schedule_outlined, 'label': 'Agendamentos'},
    ];

    if (_currentUser?.tipoUsuario == 'admin') {
      navItems.add(
        {'icon': Icons.admin_panel_settings_outlined, 'label': 'Funcionários'},
      );
    }
    
    // O item de Perfil é sempre o último a ser adicionado.
    navItems.add(
      {'icon': Icons.person_outline, 'label': 'Perfil'},
    );

    final userName = _currentUser!.nomeCompleto;
    final userEmail = _currentUser!.email;
    final tt = theme.textTheme;

    return Drawer(
      backgroundColor: cs.surface,
      elevation: 2,
      width: 280,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onPrimary)),
            accountEmail: Text(userEmail, style: tt.bodyMedium?.copyWith(color: cs.onPrimary.withOpacity(0.8))),
            currentAccountPicture: CircleAvatar(
              backgroundColor: cs.onPrimary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: tt.headlineMedium?.copyWith(color: Colors.blue), // Cor atualizada
              ),
            ),
            decoration: const BoxDecoration(color: Colors.blue), // Cor atualizada
          ),

          // Loop para criar os itens de navegação dinamicamente
          for (int i = 0; i < navItems.length; i++)
            _buildNavItem(
              context: context,
              icon: navItems[i]['icon'],
              title: navItems[i]['label'],
              index: i,
            ),

          const Spacer(),

          // Botão de Sair
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Sair', style: tt.labelLarge?.copyWith(color: cs.error, fontWeight: FontWeight.bold)),
              hoverColor: cs.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () => _performLogout(context),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Constrói cada item da lista de navegação.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blue.withOpacity(0.1), // Cor atualizada
        selectedColor: Colors.blue, // Cor atualizada
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => widget.onItemSelected(index),
      ),
    );
  }
}
