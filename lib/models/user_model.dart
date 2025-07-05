import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nomeCompleto;
  final String email;
  final String cpf; // <-- Adicionado aqui
  final String telefone;
  final String tipoUsuario; // 'admin', 'porteiro', 'cliente'
  final String? ginasioId; // Nulo para admin e cliente
  final bool ativo;

  UserModel({
    required this.uid,
    required this.nomeCompleto,
    required this.email,
    required this.cpf, // <-- Adicionado aqui
    required this.telefone,
    required this.tipoUsuario,
    this.ginasioId,
    required this.ativo,
  });

  // Método para converter os dados do Firestore (Map) para um objeto UserModel
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      uid: snapshot.id,
      nomeCompleto: data?['nomeCompleto'] ?? '',
      email: data?['email'] ?? '',
      cpf: data?['cpf'] ?? '', // <-- Adicionado aqui
      telefone: data?['telefone'] ?? '',
      tipoUsuario: data?['tipoUsuario'] ?? 'cliente',
      ginasioId: data?['ginasioId'],
      ativo: data?['ativo'] ?? true,
    );
  }

  // Método para converter um objeto UserModel para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'cpf': cpf, // <-- Adicionado aqui
      'telefone': telefone,
      'tipoUsuario': tipoUsuario,
      'ginasioId': ginasioId,
      'ativo': ativo,
    };
  }
}