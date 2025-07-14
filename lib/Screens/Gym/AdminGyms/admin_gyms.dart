// Arquivo: lib/screens/Gyms/admin_gyms_screen.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/gym_model.dart';

import '../../../services/gyms_service.dart';
import '../ManageGym/manage_gym.dart';
import 'components/gym_form.dart';

class AdminGymsScreen extends StatefulWidget {
  const AdminGymsScreen({Key? key}) : super(key: key);

  @override
  _AdminGymsScreenState createState() => _AdminGymsScreenState();
}

class _AdminGymsScreenState extends State<AdminGymsScreen> {
  // --- TODA A LÓGICA DE ESTADO E SERVIÇOS FOI MANTIDA INTOCADA ---
  final GymService _gymService = GymService();
  late Future<List<GymModel>> _gymsFuture;

  @override
  void initState() {
    super.initState();
    _refreshGymList();
  }

  void _refreshGymList() {
    setState(() {
      _gymsFuture = _gymService.getAllGyms();
    });
  }

  // --- MÉTODOS DE UI (AQUI ESTÃO AS MUDANÇAS DE DESIGN) ---

  void _showAddGymSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // O AddGymSheet já está estilizado, apenas o invocamos.
        return AddGymSheet(onGymAdded: _refreshGymList);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Ginásios'),
        // A estilização da AppBar é herdada do appBarTheme.
      ),
      body: FutureBuilder<List<GymModel>>(
        future: _gymsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar ginásios: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city_outlined,
                      size: 60,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum ginásio encontrado.',
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione um novo ginásio no botão +',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final gyms = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: gyms.length,
            itemBuilder: (context, index) {
              final gym = gyms[index];
              return GymCard(gym: gym, onRefresh: _refreshGymList);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGymSheet,
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Ginásio',
      ),
    );
  }
}

class GymCard extends StatelessWidget {
  final GymModel gym;
  final VoidCallback onRefresh; // Callback para atualizar a lista

  const GymCard({Key? key, required this.gym, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManageGymScreen(gym: gym),
            ),
          );
          // Atualiza a lista quando voltar da tela de gerenciamento
          onRefresh();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: gym.fotoUrl.isNotEmpty
                  ? Image.network(
                gym.fotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: colorScheme.secondaryContainer,
                  child: Icon(Icons.sports_kabaddi,
                      size: 60,
                      color: colorScheme.onSecondaryContainer),
                ),
              )
                  : Container(
                color: colorScheme.secondaryContainer,
                child: Center(
                    child: Icon(Icons.sports_kabaddi,
                        size: 60,
                        color: colorScheme.onSecondaryContainer)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym.nome,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: colorScheme.onSurfaceVariant, size: 16),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          gym.endereco,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
