// Arquivo: lib/services/reservation_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/reservation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'reservations';

  // --- Create ---
  // Adiciona uma nova reserva no Firestore.
  Future<void> createReservation(ReservationModel reservation) async {
    try {
      // O Firestore gerará um ID automaticamente se não especificarmos um .doc()
      await _firestore.collection(_collectionPath).add(reservation.toFirestore());
    } catch (e) {
      print('Erro ao criar reserva: $e');
      rethrow;
    }
  }

  // --- Read ---
  // Busca todas as reservas para uma quadra específica em um determinado dia.
  Future<List<ReservationModel>> getReservationsForCourtByDate(String courtId, DateTime date) async {
    try {
      // Define o início e o fim do dia para a consulta
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      final DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('courtId', isEqualTo: courtId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => ReservationModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar reservas: $e');
      rethrow;
    }
  }
  
  // --- Update ---
  // Atualiza o status de uma reserva (ex: de 'pendente' para 'confirmada').
  Future<void> updateReservationStatus(String reservationId, String newStatus) async {
    try {
      await _firestore.collection(_collectionPath).doc(reservationId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Erro ao atualizar status da reserva: $e');
      rethrow;
    }
  }

  // --- Delete ---
  // Cancela (deleta) uma reserva do Firestore.
  Future<void> deleteReservation(String reservationId) async {
    try {
      await _firestore.collection(_collectionPath).doc(reservationId).delete();
    } catch (e) {
      print('Erro ao deletar reserva: $e');
      rethrow;
    }
  }
}
