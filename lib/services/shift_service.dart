// Arquivo: lib/services/shift_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/shift_model.dart'; // Ajuste o caminho se necessário

class ShiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'shifts';

  // --- Create ---
  Future<void> createShift(ShiftModel shift) async {
    try {
      await _firestore.collection(_collectionPath).add(shift.toFirestore());
    } catch (e) {
      print('Erro ao criar turno: $e');
      rethrow;
    }
  }

  // --- Read ---
  // Busca todos os turnos de um ginásio específico
  Future<List<ShiftModel>> getShiftsForGym(String gymId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('gymId', isEqualTo: gymId)
          .get();

      return querySnapshot.docs
          .map((doc) => ShiftModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar turnos para o ginásio $gymId: $e');
      rethrow;
    }
  }

  // --- Delete ---
  Future<void> deleteShift(String shiftId) async {
    try {
      await _firestore.collection(_collectionPath).doc(shiftId).delete();
    } catch (e) {
      print('Erro ao deletar turno: $e');
      rethrow;
    }
  }
}
