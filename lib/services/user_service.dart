import 'package:cloud_firestore/cloud_firestore.dart';
// Corrija o caminho do import para o arquivo do seu modelo
import 'package:myapp/models/user_model.dart'; 

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'usuarios';

  // C - Create (Criar)
  // Cria um novo documento de usuário no Firestore.
  // O 'uid' geralmente vem do serviço de autenticação (Firebase Auth).
  Future<void> createUser(UserModel usuario, String uid) async { // <-- Alterado para UserModel
    try {
      await _firestore.collection(_collectionPath).doc(uid).set(usuario.toFirestore());
    } catch (e) {
      // É uma boa prática tratar os erros, por exemplo, logando ou mostrando uma mensagem.
      print('Erro ao criar usuário: $e');
      rethrow; // Propaga o erro para a camada que chamou o método.
    }
  }

  // R - Read (Ler)
  // Lê um único usuário do Firestore pelo seu UID.
  Future<UserModel?> getUser(String uid) async { // <-- Alterado para UserModel
    try {
      final docSnapshot = await _firestore.collection(_collectionPath).doc(uid).get();

      if (docSnapshot.exists) {
        // Usa o factory constructor do UserModel
        return UserModel.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>); 
      }
      return null; // Retorna nulo se o usuário não for encontrado.
    } catch (e) {
      print('Erro ao ler usuário: $e');
      rethrow;
    }
  }

  // R - Read (Ler todos os usuários)
  // Lê uma lista de todos os usuários. Útil para telas de administração.
  Future<List<UserModel>> getAllUsers() async { // <-- Alterado para UserModel
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs
          // Mapeia usando o factory constructor do UserModel
          .map((doc) => UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar todos os usuários: $e');
      rethrow;
    }
  }


  // U - Update (Atualizar)
  // Atualiza os dados de um usuário existente no Firestore.
  // Recebe um mapa apenas com os campos que devem ser atualizados.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).update(data);
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  // D - Delete (Deletar)
  // Deleta um usuário do Firestore pelo seu UID.
  // Lembre-se que isso apaga apenas os dados do Firestore, não a conta no Firebase Auth.
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).delete();
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      rethrow;
    }
  }
}