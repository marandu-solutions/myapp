// Arquivo: lib/Screens/HomePage/homepage.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Componentes da UI, Modelos e Serviços
import 'package:myapp/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:myapp/Screens/HomePage/components/side_bar.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';

import '../ Scheduling/Scheduling Screen/scheduling_screen.dart';
import '../Employees/Employees List Screen/employees_screen.dart';
import '../Gym/AdminGyms/admin_gyms.dart';

// Telas das Seções

// --- MODELO PARA ITEM DE NAVEGAÇÃO ---
class NavItem {
  final String title;
  final IconData icon;
  final Widget screen;

  NavItem({required this.title, required this.icon, required this.screen});
}

// --- TELA DE PLACEHOLDER ---
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

// --- HOMEPAGE STATEFUL WIDGET ---
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
  List<NavItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndBuildNav();
  }

  Future<void> _loadUserDataAndBuildNav() async {
    if (!_isLoading) setState(() => _isLoading = true);
    try {
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) throw Exception("Usuário não autenticado.");

      final userModel = await _userService.getUser(firebaseUser.uid);
      _currentUser = userModel;
      _buildNavigationItems();

    } catch (e) {
      print("Erro ao carregar dados da homepage: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _buildNavigationItems() {
    final List<NavItem> items = [
      NavItem(
        title: 'Início',
        icon: Icons.home_outlined,
        screen: const PlaceholderScreen(title: 'Início'),
      ),
      NavItem(
        title: 'Agendamentos',
        icon: Icons.calendar_today_outlined,
        screen: const SchedulingScreen(),
      ),
    ];

    // CORREÇÃO: Adiciona ambas as telas de admin se o usuário for do tipo 'admin'
    if (_currentUser?.tipoUsuario == 'admin') {
      items.add(
        NavItem(
          title: 'Ginásios',
          icon: Icons.sports_basketball_outlined,
          screen: const AdminGymsScreen(),
        ),
      );
      items.add(
        NavItem(
          title: 'Funcionários',
          icon: Icons.people_outline,
          screen: const AdminEmployeesScreen(),
        ),
      );
    }

    items.add(
      NavItem(
        title: 'Perfil',
        icon: Icons.person_outline,
        screen: const PlaceholderScreen(title: 'Meu Perfil'),
      ),
    );

    _navItems = items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_navItems.isEmpty || _currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Erro ao carregar dados do usuário.'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadUserDataAndBuildNav,
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final selectedScreen = _navItems[_selectedIndex].screen;

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_navItems[_selectedIndex].title),
              backgroundColor: Colors.blue,
            ),
            drawer: Sidebar(
              navItems: _navItems,
              currentUser: _currentUser,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                _onItemTapped(index);
                Navigator.pop(context);
              },
            ),
            body: selectedScreen,
            bottomNavigationBar: BottomNavBar(
              navItems: _navItems,
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  navItems: _navItems,
                  currentUser: _currentUser,
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: selectedScreen,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
