// Arquivo: lib/Screens/HomePage/components/side_bar.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:myapp/Screens/Auth/LoginScreen/login_screen.dart';
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

  // Itens de navegação adaptados para o nosso projeto
  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'label': 'Início'},
    {'icon': Icons.schedule_outlined, 'label': 'Agendamentos'},
    {'icon': Icons.person_outline, 'label': 'Perfil'},
  ];

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
      // Leva o usuário de volta para a tela de login e remove todas as outras rotas
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
                style: tt.headlineMedium?.copyWith(color: Colors.teal), // Cor do texto do avatar
              ),
            ),
            decoration: const BoxDecoration(color: Colors.teal), // Cor de fundo do header
          ),

          // Loop para criar os itens de navegação
          for (int i = 0; i < _navItems.length; i++)
            _buildNavItem(
              context: context,
              icon: _navItems[i]['icon'],
              title: _navItems[i]['label'],
              index: i,
            ),

          const Spacer(), // Empurra o botão de sair para o final

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
        selectedTileColor: Colors.teal.withOpacity(0.1), // Cor de fundo do item selecionado
        selectedColor: Colors.teal, // Cor do ícone e texto do item selecionado
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => widget.onItemSelected(index),
      ),
    );
  }
}
