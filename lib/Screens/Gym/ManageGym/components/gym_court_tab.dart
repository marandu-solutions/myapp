// Arquivo: lib/screens/Gyms/ManageGym/components/gym_courts_tab.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/court_model.dart';
import 'package:myapp/models/gym_model.dart';
import 'package:myapp/services/court_service.dart';

import '../../../Court/EditCourt/edit_court.dart';


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
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddCourtSheet(
          gymId: widget.gym.id,
          onCourtAdded: _refreshCourtList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CourtModel>>(
        future: _courtsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar quadras: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma quadra cadastrada para este ginásio.'));
          }

          final courts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courts.length,
            itemBuilder: (context, index) {
              final court = courts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.sports_soccer, color: Colors.blue),
                  title: Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${court.sportType} - R\$ ${court.pricePerHour.toStringAsFixed(2)}/hora'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () {
                    // TODO: Lógica para editar a quadra
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourtSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Adicionar Quadra',
      ),
    );
  }
}
