// Arquivo: lib/Screens/HomePage/homepage.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:myapp/Screens/%20Scheduling/Scheduling%20Screen/scheduling_screen.dart';
import 'package:myapp/Screens/Employees/Employees%20List%20Screen/employees_screen.dart';
import 'package:myapp/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:myapp/Screens/HomePage/components/side_bar.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';

// Classe de exemplo para representar as telas que você irá criar
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;

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
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // CORREÇÃO: A lista de páginas agora é construída dinamicamente,
    // espelhando a lógica da Sidebar e BottomNavBar.
    final List<Widget> pages = [
      const PlaceholderScreen(title: 'Início'),
      SchedulingScreen(),
    ];

    if (_currentUser?.tipoUsuario == 'admin') {
      pages.add(const AdminEmployeesScreen());
    }
    
    // A página de Perfil é sempre a última
    pages.add(const PlaceholderScreen(title: 'Perfil'));


    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          // --- LAYOUT MOBILE ---
          return Scaffold(
            appBar: AppBar(
              title: const Text('SIGA'),
              backgroundColor: Colors.blue, // Cor atualizada
            ),
            drawer: Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                _onItemTapped(index);
                Navigator.pop(context);
              },
            ),
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          );
        } else {
          // --- LAYOUT DESKTOP / WEB ---
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
                Expanded(
                  child: pages[_selectedIndex],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
