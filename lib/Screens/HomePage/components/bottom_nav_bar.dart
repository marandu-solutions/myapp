// Arquivo: lib/Screens/HomePage/components/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:myapp/Screens/HomePage/homepage.dart'; // Importa o NavItem

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItem> navItems;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Acessando as cores e estilos do nosso AppTheme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Constrói a lista de botões a partir dos navItems recebidos
    final tabs = navItems
        .map((item) => GButton(
      icon: item.icon,
      text: item.title,
      // Usando o estilo de texto do tema para consistência
      textStyle: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
    ))
        .toList();

    return Container(
      // A decoração agora usa as cores do tema
      decoration: BoxDecoration(
        // No tema claro será branco, no escuro será um cinza escuro.
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            // A sombra também se adapta ao tema
            blurRadius: 20,
            color: theme.shadowColor.withOpacity(0.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            // Cores de efeito usando o tema
            rippleColor: colorScheme.primary.withOpacity(0.1),
            hoverColor: colorScheme.primary.withOpacity(0.05),

            gap: 8,

            // Cor do ícone e texto do item ATIVO.
            // O texto usará o `textStyle` definido no GButton.
            activeColor: colorScheme.onPrimary,

            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),

            // Cor de fundo do item ATIVO. Usando a cor primária do tema.
            tabBackgroundColor: colorScheme.primary,

            // Cor do ícone e texto dos itens INATIVOS.
            color: colorScheme.onSurface.withOpacity(0.6),

            tabs: tabs,
            selectedIndex: selectedIndex,
            onTabChange: onItemSelected,
          ),
        ),
      ),
    );
  }
}
