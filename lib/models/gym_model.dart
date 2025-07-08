// Arquivo: lib/models/gym_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GymModel {
  final String id;
  final String nome;
  final String endereco;
  final String fotoUrl;
  final String horarioAbertura; // Ex: "08:00"
  final String horarioFechamento; // Ex: "22:00"
  final bool ativo;

  GymModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.fotoUrl,
    required this.horarioAbertura,
    required this.horarioFechamento,
    required this.ativo,
  });

  // Converte dados do Firestore para um objeto GymModel
  factory GymModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return GymModel(
      id: snapshot.id,
      nome: data?['nome'] ?? '',
      endereco: data?['endereco'] ?? '',
      fotoUrl: data?['fotoUrl'] ?? '',
      horarioAbertura: data?['horarioAbertura'] ?? '08:00',
      horarioFechamento: data?['horarioFechamento'] ?? '22:00',
      ativo: data?['ativo'] ?? true,
    );
  }

  // Converte um objeto GymModel para um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'endereco': endereco,
      'fotoUrl': fotoUrl,
      'horarioAbertura': horarioAbertura,
      'horarioFechamento': horarioFechamento,
      'ativo': ativo,
    };
  }
}
