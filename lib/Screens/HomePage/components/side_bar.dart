// Arquivo: lib/Screens/HomePage/components/side_bar.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:myapp/Screens/Auth/LoginScreen/login_screen.dart';
import 'package:myapp/Screens/HomePage/homepage.dart'; // Importa o NavItem
import 'package:myapp/models/user_model.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItem> navItems;
  final UserModel? currentUser;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems,
    required this.currentUser,
  }) : super(key: key);

  // A lógica de logout foi mantida 100% intacta.
  void _performLogout(BuildContext context) async {
    await fb_auth.FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Proteção caso os dados do usuário ainda não tenham chegado.
    if (currentUser == null) {
      return Drawer(
        width: 280,
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final userName = currentUser!.nomeCompleto;
    final userEmail = currentUser!.email;

    return Drawer(
      // A cor de fundo do Drawer agora vem do tema.
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 2,
      width: 280,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              // A cor de fundo do avatar vem do tema.
              backgroundColor: colorScheme.onPrimary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: textTheme.headlineSmall?.copyWith(
                  // A cor do texto do avatar agora é a cor primária do tema.
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // A cor de fundo do header agora é a cor primária do tema.
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
          ),

          // O loop para construir os itens de navegação foi mantido.
          for (int i = 0; i < navItems.length; i++)
            _buildNavItem(
              context: context,
              icon: navItems[i].icon,
              title: navItems[i].title,
              index: i,
            ),

          const Spacer(), // Empurra o botão de sair para o final.

          // O botão de Sair agora usa as cores de erro do tema.
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Sair',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              hoverColor: colorScheme.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () => _performLogout(context),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Widget para construir cada item da lista de navegação.
  // Agora 100% integrado com o tema.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        // Cor de fundo do item selecionado usa a cor primária com opacidade.
        selectedTileColor: colorScheme.primary.withOpacity(0.1),
        // Cor do ícone e texto do item selecionado usa a cor primária.
        selectedColor: colorScheme.primary,
        // Cores dos itens não selecionados são herdadas do tema.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
