import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sirh_mobile/models/conge.dart';
import 'package:sirh_mobile/models/absence.dart';

class CongeAbsenceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== CONGÉ =====

  /// Créer une demande de congé
  Future<void> createCongeRequest(Conge conge) async {
    try {
      print('📅 === CRÉATION DEMANDE CONGÉ ===');
      print('📅 Employé: ${conge.employeId}');
      print('📅 Type: ${conge.typeConge}');
      print('📅 Du ${conge.dateDebut} au ${conge.dateFin}');

      await _firestore.collection('conges').doc(conge.id).set(conge.toJson());

      print('📅 ✅ Demande créée avec succès!');
    } catch (e) {
      print('❌ Erreur création congé: $e');
      rethrow;
    }
  }

  /// Récupérer les demandes de congé d'un employé
  Future<List<Conge>> getEmployeeConges(String employeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conges')
          .where('employeId', isEqualTo: employeId)
          .orderBy('dateDemande', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Conge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur récupération congés: $e');
      rethrow;
    }
  }

  /// Récupérer les demandes de congé en attente pour un manager
  Future<List<Conge>> getPendingCongesForManager(String managerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conges')
          .where('managerId', isEqualTo: managerId)
          .where('statut', isEqualTo: 'enAttente')
          .orderBy('dateDemande', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Conge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur récupération congés en attente: $e');
      rethrow;
    }
  }

  /// Approuver une demande de congé
  Future<void> approveConge(String congeId) async {
    try {
      print('✅ Approbation congé: $congeId');
      await _firestore.collection('conges').doc(congeId).update({
        'statut': 'approuve',
        'dateValidation': DateTime.now().toIso8601String(),
      });
      print('✅ Congé approuvé!');
    } catch (e) {
      print('❌ Erreur approbation: $e');
      rethrow;
    }
  }

  /// Refuser une demande de congé
  Future<void> refuseConge(String congeId) async {
    try {
      print('❌ Refus congé: $congeId');
      await _firestore.collection('conges').doc(congeId).update({
        'statut': 'refuse',
        'dateValidation': DateTime.now().toIso8601String(),
      });
      print('❌ Congé refusé!');
    } catch (e) {
      print('❌ Erreur refus: $e');
      rethrow;
    }
  }

  // ===== ABSENCE =====

  /// Créer une demande d'absence
  Future<void> createAbsenceRequest(Absence absence) async {
    try {
      print('⚠️ === CRÉATION DEMANDE ABSENCE ===');
      print('⚠️ Employé: ${absence.employeId}');
      print('⚠️ Type: ${absence.typeAbsence}');
      print('⚠️ Date: ${absence.dateAbsence}');

      await _firestore
          .collection('absences')
          .doc(absence.id)
          .set(absence.toJson());

      print('⚠️ ✅ Demande créée avec succès!');
    } catch (e) {
      print('❌ Erreur création absence: $e');
      rethrow;
    }
  }

  /// Récupérer les demandes d'absence d'un employé
  Future<List<Absence>> getEmployeeAbsences(String employeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('absences')
          .where('employeId', isEqualTo: employeId)
          .orderBy('dateDemande', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Absence.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur récupération absences: $e');
      rethrow;
    }
  }

  /// Récupérer les demandes d'absence en attente pour un manager
  Future<List<Absence>> getPendingAbsencesForManager(String managerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('absences')
          .where('managerId', isEqualTo: managerId)
          .where('statut', isEqualTo: 'enAttente')
          .orderBy('dateDemande', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Absence.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erreur récupération absences en attente: $e');
      rethrow;
    }
  }

  /// Approuver une demande d'absence
  Future<void> approveAbsence(String absenceId) async {
    try {
      print('✅ Approbation absence: $absenceId');
      await _firestore.collection('absences').doc(absenceId).update({
        'statut': 'approuve',
        'dateValidation': DateTime.now().toIso8601String(),
      });
      print('✅ Absence approuvée!');
    } catch (e) {
      print('❌ Erreur approbation: $e');
      rethrow;
    }
  }

  /// Refuser une demande d'absence
  Future<void> refuseAbsence(String absenceId) async {
    try {
      print('❌ Refus absence: $absenceId');
      await _firestore.collection('absences').doc(absenceId).update({
        'statut': 'refuse',
        'dateValidation': DateTime.now().toIso8601String(),
      });
      print('❌ Absence refusée!');
    } catch (e) {
      print('❌ Erreur refus: $e');
      rethrow;
    }
  }
}
