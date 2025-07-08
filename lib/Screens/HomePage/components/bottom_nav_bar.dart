// Arquivo: lib/Screens/HomePage/components/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:myapp/Screens/HomePage/homepage.dart'; // Importa o NavItem

class BottomNavBar extends StatelessWidget { // <<< ALTERADO para StatelessWidget
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItem> navItems; // <<< NOVO: Recebe a lista de itens pronta

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems, // <<< NOVO
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // <<< ALTERADO: Constrói os botões a partir da lista de navItems recebida
    final tabs = navItems
        .map((item) => GButton(icon: item.icon, text: item.title))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.blue,
            color: Colors.black,
            tabs: tabs, // <<< USA A LISTA GERADA
            selectedIndex: selectedIndex,
            onTabChange: onItemSelected,
          ),
        ),
      ),
    );
  }
}