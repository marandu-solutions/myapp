import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftModel {
  final String id;
  final String employeeId; // ID do funcionário
  final String gymId;      // ID do ginásio
  final Timestamp startTime; // Data e hora de início do turno
  final Timestamp endTime;   // Data e hora de fim do turno
  final List<String> diasDaSemana; // Ex: ['segunda', 'quarta', 'sexta']

  ShiftModel({
    required this.id,
    required this.employeeId,
    required this.gymId,
    required this.startTime,
    required this.endTime,
    required this.diasDaSemana,
  });

  // Converte dados do Firestore para um objeto ShiftModel
  factory ShiftModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ShiftModel(
      id: snapshot.id,
      employeeId: data?['employeeId'] ?? '',
      gymId: data?['gymId'] ?? '',
      startTime: data?['startTime'] ?? Timestamp.now(),
      endTime: data?['endTime'] ?? Timestamp.now(),
      diasDaSemana: List<String>.from(data?['diasDaSemana'] ?? []),
    );
  }

  // Converte um objeto ShiftModel para um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'gymId': gymId,
      'startTime': startTime,
      'endTime': endTime,
      'diasDaSemana': diasDaSemana,
    };
  }
}
