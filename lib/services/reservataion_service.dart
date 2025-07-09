// Arquivo: lib/services/reservation_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reservation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'reservations';

  // --- Create ---
  Future<void> createReservation(ReservationModel reservation) async {
    try {
      await _firestore.collection(_collectionPath).add(reservation.toFirestore());
    } catch (e) {
      print('Erro ao criar reserva: $e');
      rethrow;
    }
  }

  // --- Read (por Semana) - NOVO MÉTODO ---
  // Busca todas as reservas para uma quadra específica durante uma semana inteira.
  Future<List<ReservationModel>> getReservationsForWeek(String courtId, DateTime weekStartDate) async {
    try {
      // Define o início e o fim da semana para a consulta
      final DateTime startOfWeek = DateTime(weekStartDate.year, weekStartDate.month, weekStartDate.day);
      final DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('courtId', isEqualTo: courtId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('startTime', isLessThan: Timestamp.fromDate(endOfWeek))
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => ReservationModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar reservas da semana: $e');
      rethrow;
    }
  }

  // --- Update ---
  Future<void> updateReservationStatus(String reservationId, String newStatus) async {
    try {
      await _firestore.collection(_collectionPath).doc(reservationId).update({'status': newStatus});
    } catch (e) {
      print('Erro ao atualizar status da reserva: $e');
      rethrow;
    }
  }

  // --- Delete ---
  Future<void> deleteReservation(String reservationId) async {
    try {
      await _firestore.collection(_collectionPath).doc(reservationId).delete();
    } catch (e) {
      print('Erro ao deletar reserva: $e');
      rethrow;
    }
  }
}
