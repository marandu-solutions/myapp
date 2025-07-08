// Arquivo: lib/screens/Gyms/ManageGym/manage_gym_screen.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/gym_model.dart';
import 'components/gym_court_tab.dart';
import 'components/gym_info_tab.dart'; // Aba de informações

class ManageGymScreen extends StatelessWidget {
  final GymModel gym;

  const ManageGymScreen({Key? key, required this.gym}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos o DefaultTabController para gerenciar o estado das abas
    return DefaultTabController(
      length: 3, // O número de abas
      child: Scaffold(
        appBar: AppBar(
          title: Text(gym.nome),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Informações'),
              Tab(icon: Icon(Icons.sports_soccer_outlined), text: 'Quadras'),
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'Funcionários'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Conteúdo de cada aba
            GymInfoTab(gym: gym),
            // CORREÇÃO: Substituído o placeholder pela aba funcional
            GymCourtsTab(gym: gym),
            const Center(child: Text('Gerenciamento de Funcionários (a ser implementado)')),
          ],
        ),
      ),
    );
  }
}
