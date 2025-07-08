// Arquivo: lib/screens/Gyms/admin_gyms_screen.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/gym_model.dart';

import '../../../services/gyms_service.dart';
import 'components/gym_form.dart';

class AdminGymsScreen extends StatefulWidget {
  const AdminGymsScreen({Key? key}) : super(key: key);

  @override
  _AdminGymsScreenState createState() => _AdminGymsScreenState();
}

class _AdminGymsScreenState extends State<AdminGymsScreen> {
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

  void _showAddGymSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddGymSheet(onGymAdded: _refreshGymList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Ginásios'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: FutureBuilder<List<GymModel>>(
        future: _gymsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar ginásios: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum ginásio encontrado.'));
          }

          final gyms = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: gyms.length,
            itemBuilder: (context, index) {
              final gym = gyms[index];
              return GymCard(gym: gym);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGymSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Adicionar Ginásio',
      ),
    );
  }
}

class GymCard extends StatelessWidget {
  final GymModel gym;
  const GymCard({Key? key, required this.gym}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias, // Garante que a imagem respeite as bordas
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          // TODO: Navegar para a tela de gerenciamento detalhado do ginásio
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ManageGymScreen(gym: gym)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Ginásio
            SizedBox(
              height: 150,
              width: double.infinity,
              child: gym.fotoUrl.isNotEmpty
                  ? Image.network(
                gym.fotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Icon(Icons.sports_kabaddi, size: 60, color: Colors.grey),
              )
                  : Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.sports_kabaddi, size: 60, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym.nome,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          gym.endereco,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
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
