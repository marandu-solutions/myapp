// Arquivo: lib/screens/Gyms/ManageGym/manage_gym_screen.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/gym_model.dart';
import '../GymEmplyeeScreen/gym_employee.dart';
import 'components/gym_court_tab.dart';
import 'components/gym_info_tab.dart';

class ManageGymScreen extends StatelessWidget {
  final GymModel gym;

  const ManageGymScreen({Key? key, required this.gym}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usamos o DefaultTabController para gerenciar o estado das abas
    return DefaultTabController(
      length: 3, // O número de abas
      child: Scaffold(
        appBar: AppBar(
          title: Text(gym.nome),
          // A estilização da AppBar (cor, elevação, etc.) é herdada do AppTheme
          bottom: TabBar(
            // As cores da TabBar agora vêm do nosso tema
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
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
            GymCourtsTab(gym: gym),
            GymEmployeesTab(gym: gym),
          ],
        ),
      ),
    );
  }
}
