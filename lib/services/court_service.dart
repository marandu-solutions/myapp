// Arquivo: lib/services/court_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/court_model.dart';

class CourtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'courts';

  // --- Create ---
  Future<void> createCourt(CourtModel court) async {
    try {
      await _firestore.collection(_collectionPath).add(court.toFirestore());
    } catch (e) {
      print('Erro ao criar quadra: $e');
      rethrow;
    }
  }

  // --- Read ---
  // Busca todas as quadras cadastradas no sistema
  Future<List<CourtModel>> getAllCourts() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      return querySnapshot.docs
          .map((doc) => CourtModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar quadras: $e');
      rethrow;
    }
  }

  // --- Update ---
  Future<void> updateCourt(String courtId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionPath).doc(courtId).update(data);
    } catch (e) {
      print('Erro ao atualizar quadra: $e');
      rethrow;
    }
  }

  // --- Delete ---
  Future<void> deleteCourt(String courtId) async {
    try {
      await _firestore.collection(_collectionPath).doc(courtId).delete();
    } catch (e) {
      print('Erro ao deletar quadra: $e');
      rethrow;
    }
  }
}
