// Arquivo: lib/Screens/HomePage/components/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos um Container para adicionar um padding e uma sombra sutil,
    // dando um aspecto mais moderno à barra de navegação.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            // Estilização da barra
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8, // Espaço entre o ícone e o texto
            activeColor: Colors.white, // Cor do ícone e texto ativos
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.teal, // Cor de fundo da aba ativa
            color: Colors.black, // Cor dos ícones e textos inativos

            // Mapeia nossa lista de itens para os botões da GNav
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Início',
              ),
              GButton(
                icon: Icons.schedule_outlined,
                text: 'Agendamentos',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Perfil',
              ),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onItemSelected, // Usa o callback da HomePage
          ),
        ),
      ),
    );
  }
}
