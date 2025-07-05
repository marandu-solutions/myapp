import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String uid;
  final String nomeCompleto;
  final String email;
  final String cpf;
  final String telefone;
  final String fotoUrl;
  final bool ativo;

  EmployeeModel({
    required this.uid,
    required this.nomeCompleto,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.fotoUrl,
    required this.ativo,
  });

  // Método para converter os dados do Firestore (Map) para um objeto EmployeeModel
  factory EmployeeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return EmployeeModel(
      uid: snapshot.id,
      nomeCompleto: data?['nomeCompleto'] ?? '',
      email: data?['email'] ?? '',
      cpf: data?['cpf'] ?? '',
      telefone: data?['telefone'] ?? '',
      fotoUrl: data?['fotoUrl'] ?? '',
      ativo: data?['ativo'] ?? true,
    );
  }

  // Método para converter um objeto EmployeeModel para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'fotoUrl': fotoUrl,
      'ativo': ativo,
    };
  }
}
