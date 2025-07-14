// Arquivo: lib/screens/Gyms/ManageGym/components/gym_courts_tab.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/models/gym_model.dart';
import 'package:myapp/services/court_service.dart';

import '../../../Court/EditCourt/edit_court.dart'; // Ajuste o caminho

class GymCourtsTab extends StatefulWidget {
  final GymModel gym;
  const GymCourtsTab({Key? key, required this.gym}) : super(key: key);

  @override
  _GymCourtsTabState createState() => _GymCourtsTabState();
}

class _GymCourtsTabState extends State<GymCourtsTab> {
  final CourtService _courtService = CourtService();
  late Future<List<CourtModel>> _courtsFuture;

  @override
  void initState() {
    super.initState();
    _refreshCourtList();
  }

  void _refreshCourtList() {
    setState(() {
      _courtsFuture = _courtService.getCourtsForGym(widget.gym.id);
    });
  }

  void _showAddCourtSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // O AddCourtSheet já foi estilizado, apenas o invocamos
        return AddCourtSheet(
          gymId: widget.gym.id,
          onCourtAdded: _refreshCourtList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<List<CourtModel>>(
        future: _courtsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar quadras: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer_outlined,
                      size: 60,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma quadra cadastrada.',
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione uma nova quadra no botão +',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final courts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courts.length,
            itemBuilder: (context, index) {
              final court = courts[index];
              return CourtCard(
                court: court,
                onRefresh: _refreshCourtList,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourtSheet,
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Quadra',
      ),
    );
  }
}

// Widget para exibir cada quadra
class CourtCard extends StatelessWidget {
  final CourtModel court;
  final VoidCallback onRefresh;

  const CourtCard({Key? key, required this.court, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(Icons.sports_soccer,
              color: colorScheme.onSecondaryContainer),
        ),
        title: Text(court.name, style: textTheme.titleMedium),
        subtitle: Text(
            '${court.sportType} - R\$ ${court.pricePerHour.toStringAsFixed(2)}/hora'),
        trailing: Icon(Icons.edit_outlined, color: colorScheme.primary),
        onTap: () async {
          // A navegação para a tela de edição (a ser criada)
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => EditCourtScreen(court: court),
          //   ),
          // );
          // onRefresh(); // Atualiza a lista ao voltar
        },
      ),
    );
  }
}
