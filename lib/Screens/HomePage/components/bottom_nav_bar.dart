// Arquivo: lib/Screens/HomePage/components/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final UserService _userService = UserService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: A lógica de construção da lista foi ajustada
    // para garantir a ordem correta dos itens.
    final List<GButton> tabs = [
      const GButton(icon: Icons.home_outlined, text: 'Início'),
      const GButton(icon: Icons.schedule_outlined, text: 'Agendamentos'),
    ];

    // Adiciona a aba de admin na posição correta, antes do Perfil
    if (_currentUser?.tipoUsuario == 'admin') {
      tabs.add(
        const GButton(icon: Icons.admin_panel_settings_outlined, text: 'Funcionários'),
      );
    }
    
    // A aba de Perfil é sempre a última
    tabs.add(
        const GButton(icon: Icons.person_outline, text: 'Perfil'),
    );


    // Enquanto os dados não carregam, mostra uma barra vazia para evitar erros
    if (_currentUser == null) {
      return const SizedBox(height: 60); // Retorna um placeholder com altura similar
    }

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
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.blue, // Cor atualizada
            color: Colors.black,
            tabs: tabs, // Usa a lista de abas construída dinamicamente
            selectedIndex: widget.selectedIndex,
            onTabChange: widget.onItemSelected,
          ),
        ),
      ),
    );
  }
}
