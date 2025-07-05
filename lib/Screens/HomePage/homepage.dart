// Arquivo: lib/Screens/HomePage/homepage.dart

import 'package:flutter/material.dart';
import 'package:myapp/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:myapp/Screens/HomePage/components/side_bar.dart';

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
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    PlaceholderScreen(title: 'Início'),
    PlaceholderScreen(title: 'Agendamentos'),
    PlaceholderScreen(title: 'Perfil'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Usando LayoutBuilder para detectar o tamanho da tela dinamicamente
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define um ponto de quebra. Se a largura for menor que 768, é mobile.
        final bool isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SIGA'),
              backgroundColor: Colors.teal,
            ),
            // O Drawer continua usando a Sidebar
            drawer: Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                _onItemTapped(index);
                Navigator.pop(context); 
              },
            ),
            body: _pages[_selectedIndex],
            // A BottomNavBar é usada no layout mobile
            bottomNavigationBar: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
                // O conteúdo principal ocupa o restante da tela
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
