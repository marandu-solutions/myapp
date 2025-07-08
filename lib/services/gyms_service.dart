// Arquivo: lib/services/gym_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/gym_model.dart'; // Ajuste o caminho se necessário

class GymService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'gyms';

  // --- Create ---
  Future<DocumentReference> createGym(GymModel gym) async {
    try {
      return await _firestore.collection(_collectionPath).add(gym.toFirestore());
    } catch (e) {
      print('Erro ao criar ginásio: $e');
      rethrow;
    }
  }

  // --- Read ---
  Future<List<GymModel>> getAllGyms() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs
          .map((doc) => GymModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar ginásios: $e');
      rethrow;
    }
  }

  // --- Update ---
  Future<void> updateGym(String gymId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionPath).doc(gymId).update(data);
    } catch (e) {
      print('Erro ao atualizar ginásio: $e');
      rethrow;
    }
  }

  // --- Delete ---
  Future<void> deleteGym(String gymId) async {
    try {
      await _firestore.collection(_collectionPath).doc(gymId).delete();
    } catch (e) {
      print('Erro ao deletar ginásio: $e');
      rethrow;
    }
  }
}
