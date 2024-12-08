import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchNoteFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu yok");

    final snapshot = await _firestore
        .collection('notes')
        .where('uuid', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchLists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu yok");

    final snapshot = await _firestore
        .collection('lists')
        .where('uuid', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
