// Arquivo: lib/Scheduling/Models/court_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CourtModel {
  final String id;
  final String name;      // Ex: "Quadra Poliesportiva 1"
  final String sportType; // Ex: "Futsal", "Tênis", "Vôlei"
  final String gymId;     // ID do ginásio ao qual esta quadra pertence
  final double pricePerHour; // Preço por hora para esta quadra específica
  final bool isActive;

  CourtModel({
    required this.id,
    required this.name,
    required this.sportType,
    required this.gymId,
    required this.pricePerHour,
    required this.isActive,
  });

  // Converte dados do Firestore para um objeto CourtModel
  factory CourtModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return CourtModel(
      id: snapshot.id,
      name: data?['name'] ?? '',
      sportType: data?['sportType'] ?? '',
      gymId: data?['gymId'] ?? '',
      pricePerHour: (data?['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      isActive: data?['isActive'] ?? true,
    );
  }

  // Converte um objeto CourtModel para um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'sportType': sportType,
      'gymId': gymId,
      'pricePerHour': pricePerHour,
      'isActive': isActive,
    };
  }
}
