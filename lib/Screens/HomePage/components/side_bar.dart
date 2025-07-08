// Arquivo: lib/Screens/HomePage/components/side_bar.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:myapp/Screens/Auth/LoginScreen/login_screen.dart';
import 'package:myapp/Screens/HomePage/homepage.dart'; // Importa o NavItem
import 'package:myapp/models/user_model.dart';

class Sidebar extends StatelessWidget { // <<< ALTERADO para StatelessWidget
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItem> navItems;   // <<< NOVO: Recebe a lista de itens pronta
  final UserModel? currentUser;   // <<< NOVO: Recebe o usuário pronto

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems,      // <<< NOVO
    required this.currentUser,   // <<< NOVO
  }) : super(key: key);

  // Realiza o logout do usuário
  void _performLogout(BuildContext context) async {
    await fb_auth.FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se os dados do usuário ainda não chegaram, mostra um loader.
    // Isso é uma proteção extra, pois a HomePage já deve garantir isso.
    if (currentUser == null) {
      return const Drawer(
        width: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final userName = currentUser!.nomeCompleto;
    final userEmail = currentUser!.email;

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
                style: tt.headlineMedium?.copyWith(color: Colors.blue),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),

          // <<< ALTERADO: Loop usa a lista de navItems recebida por parâmetro
          for (int i = 0; i < navItems.length; i++)
            _buildNavItem(
              context: context,
              icon: navItems[i].icon,
              title: navItems[i].title,
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

  // O método _buildNavItem permanece o mesmo, mas agora é chamado com dados externos
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        selectedTileColor: Colors.blue.withOpacity(0.1),
        selectedColor: Colors.blue,
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}