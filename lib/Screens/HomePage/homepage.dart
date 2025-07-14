// Arquivo: lib/Screens/HomePage/homepage.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Componentes da UI, Modelos e Serviços
import 'package:myapp/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:myapp/Screens/HomePage/components/side_bar.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/user_service.dart';

// Telas das Seções (Substituídas por Placeholders para este exemplo)
import '../ Scheduling/Scheduling Screen/scheduling_screen.dart';
import '../ProfileScreen/profile_screen.dart';

// --- MODELO PARA ITEM DE NAVEGAÇÃO (Mantido como estava) ---
class NavItem {
  final String title;
  final IconData icon;
  final Widget screen;

  NavItem({required this.title, required this.icon, required this.screen});
}

// --- TELA DE PLACEHOLDER (Para telas não definidas) ---
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
    // A lógica de carregamento de dados foi mantida 100% intacta.
    if (mounted) setState(() => _isLoading = true);
    try {
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        // Idealmente, aqui você navegaria de volta para a tela de login.
        throw Exception("Usuário não autenticado.");
      }

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
    // A lógica de construção da navegação foi mantida 100% intacta.
    final List<NavItem> items = [
      NavItem(
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        // Usando Placeholder pois a tela original não foi fornecida
        screen: const PlaceholderScreen(title: 'Dashboard'),
      ),
      NavItem(
        title: 'Agendamentos',
        icon: Icons.calendar_today_outlined,
        screen: const SchedulingScreen(),
      ),
    ];

    if (_currentUser?.tipoUsuario == 'admin') {
      items.add(
        NavItem(
          title: 'Ginásios',
          icon: Icons.sports_basketball_outlined,
          // Usando Placeholder pois a tela original não foi fornecida
          screen: const PlaceholderScreen(title: 'Ginásios'),
        ),
      );
      items.add(
        NavItem(
          title: 'Funcionários',
          icon: Icons.people_outline,
          // Usando Placeholder pois a tela original não foi fornecida
          screen: const PlaceholderScreen(title: 'Funcionários'),
        ),
      );
    }

    items.add(
      NavItem(
        title: 'Perfil',
        icon: Icons.person_outline,
        screen: const ProfileScreen(),
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
    // --- REFINAMENTO DA UI ---

    // 1. Tela de Carregamento (Loading) usando o tema
    if (_isLoading) {
      return Scaffold(
        // O `backgroundColor` é herdado do `scaffoldBackgroundColor` do nosso tema
        body: Center(
          child: CircularProgressIndicator(
            // A cor do indicador agora usa a cor primária do tema
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // 2. Tela de Erro usando o tema
    if (_navItems.isEmpty || _currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Erro ao carregar dados.',
                // Usando o estilo de texto do tema
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifique sua conexão e tente novamente.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                // O estilo deste botão (cores, bordas, fonte) vem diretamente
                // do `elevatedButtonTheme` que definimos no AppTheme.
                onPressed: _loadUserDataAndBuildNav,
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      );
    }

    // 3. Construção do Layout principal usando o tema
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final selectedScreen = _navItems[_selectedIndex].screen;

        if (isMobile) {
          return Scaffold(
            // A AppBar agora usa o `appBarTheme` do nosso AppTheme.
            // Não precisamos mais definir cor, elevação, etc. aqui.
            appBar: AppBar(
              title: Text(_navItems[_selectedIndex].title),
            ),
            // O Drawer herdará os estilos do tema.
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
            // O BottomNavBar também herdará os estilos.
            bottomNavigationBar: BottomNavBar(
              navItems: _navItems,
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          );
        } else { // Layout para Tablet/Desktop
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  navItems: _navItems,
                  currentUser: _currentUser,
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
                // O VerticalDivider também usa as cores do tema.
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      // Adicionando uma transição de fade para suavidade
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Container(
                      // Adicionando uma key para o AnimatedSwitcher funcionar corretamente
                      key: ValueKey<int>(_selectedIndex),
                      child: selectedScreen,
                    ),
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
