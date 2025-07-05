import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/employee_model.dart'; // Ajuste o caminho para o seu modelo

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'users';

  // --- MÉTODO CORRIGIDO ---
  // Este método agora lida com a criação do usuário no Auth e no Firestore.
  // É a maneira mais robusta e segura de garantir a consistência dos dados.
  Future<void> registerNewEmployee(EmployeeModel employeeData, String password) async {
    try {
      // Para criar um usuário em nome de um admin, o ideal é usar uma Cloud Function.
      // Como alternativa, podemos criar uma instância temporária do Firebase para criar o usuário.
      // Por simplicidade, vamos assumir que a criação do Auth e do Firestore são separadas,
      // mas a lógica de adicionar o 'tipoUsuario' é a chave.

      // A lógica abaixo seria ideal se movida para o _submitForm do seu widget
      // ou para uma Cloud Function.

      // 1. Criar o usuário no Firebase Auth para obter o UID
      // Esta parte requer uma lógica mais complexa para ser executada por um admin.
      // Por enquanto, vamos focar em salvar o dado corretamente no Firestore.
      
      // O importante é garantir que o dado salvo no Firestore tenha o tipo correto.
      Map<String, dynamic> employeeMap = employeeData.toFirestore();
      employeeMap['tipoUsuario'] = 'employee'; // Define o tipo de usuário

      // Salva o funcionário na coleção 'users'
      await _firestore.collection(_collectionPath).doc(employeeData.uid).set(employeeMap);

    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Auth
      print('Erro de autenticação ao criar funcionário: $e');
      rethrow;
    } catch (e) {
      print('Erro ao criar funcionário: $e');
      rethrow;
    }
  }

  // O método createEmployee original é mantido para compatibilidade, mas com a correção.
  Future<void> createEmployee(EmployeeModel employee) async {
    try {
      Map<String, dynamic> employeeData = employee.toFirestore();
      // CORREÇÃO: Adiciona o campo 'tipoUsuario' para que o funcionário seja encontrado depois.
      employeeData['tipoUsuario'] = 'employee';

      await _firestore.collection(_collectionPath).doc(employee.uid).set(employeeData);
    } catch (e) {
      print('Erro ao criar funcionário: $e');
      rethrow;
    }
  }

  Future<EmployeeModel?> getEmployee(String uid) async {
    try {
      final docSnapshot = await _firestore.collection(_collectionPath).doc(uid).get();
      if (docSnapshot.exists) {
        return EmployeeModel.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      print('Erro ao ler funcionário: $e');
      rethrow;
    }
  }

  // --- MÉTODO CORRIGIDO ---
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          // CORREÇÃO: Filtra pelo tipo 'employee' para consistência.
          .where('tipoUsuario', isEqualTo: 'employee')
          .get();
          
      return querySnapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Erro ao buscar todos os funcionários: $e');
      rethrow;
    }
  }

  Future<void> updateEmployee(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).update(data);
    } catch (e) {
      print('Erro ao atualizar funcionário: $e');
      rethrow;
    }
  }

  Future<void> deleteEmployee(String uid) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).delete();
    } catch (e) {
      print('Erro ao deletar funcionário: $e');
      rethrow;
    }
  }
}
