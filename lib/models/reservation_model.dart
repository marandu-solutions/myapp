// Arquivo: lib/Scheduling/Models/reservation_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String title;
  final String courtId;
  final String gymId; // <-- ADICIONADO: Essencial para buscas
  final String clientId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  // --- CAMPOS ADICIONADOS ---
  final double price;      // Preço final da reserva
  final bool isPaid;       // Status do pagamento
  final String notes;      // Observações ou notas sobre a reserva

  ReservationModel({
    required this.id,
    required this.title,
    required this.courtId,
    required this.gymId, // <-- ADICIONADO
    required this.clientId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.price = 0.0,
    this.isPaid = false,
    this.notes = '',
  });

  // Converte um documento do Firestore para um objeto ReservationModel
  factory ReservationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReservationModel(
      id: doc.id,
      title: data['title'] ?? '',
      courtId: data['courtId'] ?? '',
      gymId: data['gymId'] ?? '', // <-- ADICIONADO
      clientId: data['clientId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pendente',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      isPaid: data['isPaid'] ?? false,
      notes: data['notes'] ?? '',
    );
  }

  // Converte um objeto ReservationModel para um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'courtId': courtId,
      'gymId': gymId, // <-- ADICIONADO
      'clientId': clientId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
      'price': price,
      'isPaid': isPaid,
      'notes': notes,
    };
  }
}
