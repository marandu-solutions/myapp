// Arquivo: lib/Scheduling/Models/reservation_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modelo para representar uma Reserva
class ReservationModel {
  final String id;
  final String title;
  final String courtId;
  final String clientId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // Ex: 'confirmada', 'pendente', 'cancelada'
  
  ReservationModel({
    required this.id,
    required this.title,
    required this.courtId,
    required this.clientId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  // Converte um documento do Firestore para um objeto ReservationModel
  factory ReservationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReservationModel(
      id: doc.id,
      title: data['title'] ?? '',
      courtId: data['courtId'] ?? '',
      clientId: data['clientId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pendente',
    );
  }

  // Converte um objeto ReservationModel para um Map para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'courtId': courtId,
      'clientId': clientId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
    };
  }
}
