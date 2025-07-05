import 'package:cloud_firestore/cloud_firestore.dart';

class GymModel {
  final String id;
  final String nome;
  final String endereco;
  final String fotoUrl;
  final bool ativo;

  GymModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.fotoUrl,
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
      ativo: data?['ativo'] ?? true,
    );
  }

  // Converte um objeto GymModel para um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'endereco': endereco,
      'fotoUrl': fotoUrl,
      'ativo': ativo,
    };
  }
}
