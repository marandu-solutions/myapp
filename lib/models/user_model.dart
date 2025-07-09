import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nomeCompleto;
  final String email;
  final String cpf;
  final String telefone;
  final String tipoUsuario; // 'admin', 'employee', 'client'
  final String fotoUrl; // <-- ADICIONADO
  final bool ativo;

  UserModel({
    required this.uid,
    required this.nomeCompleto,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.tipoUsuario,
    required this.fotoUrl, // <-- ADICIONADO
    required this.ativo,
  });

  // Método para converter os dados do Firestore (Map) para um objeto UserModel
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      uid: snapshot.id,
      nomeCompleto: data?['nomeCompleto'] ?? '',
      email: data?['email'] ?? '',
      cpf: data?['cpf'] ?? '',
      telefone: data?['telefone'] ?? '',
      tipoUsuario: data?['tipoUsuario'] ?? 'client',
      fotoUrl: data?['fotoUrl'] ?? '', // <-- ADICIONADO
      ativo: data?['ativo'] ?? true,
    );
  }

  // Método para converter um objeto UserModel para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'tipoUsuario': tipoUsuario,
      'fotoUrl': fotoUrl, // <-- ADICIONADO
      'ativo': ativo,
    };
  }
}
