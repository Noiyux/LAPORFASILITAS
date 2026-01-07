import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/laporan_model.dart';

class FirestoreService {
  final CollectionReference laporanCollection =
      FirebaseFirestore.instance.collection('laporan');

  Future<List<Laporan>> getLaporan() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await laporanCollection
        .where('userId', isEqualTo: uid)
        .orderBy('tanggal', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Laporan.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }


  Stream<List<Laporan>> streamLaporan() {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return laporanCollection
      .where('userId', isEqualTo: uid)
      .orderBy('tanggal', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Laporan.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList();
      });
}


  Future<void> tambahLaporan(Laporan laporan) async {
    await laporanCollection.add(laporan.toMap());
  }

  Future<void> hapusLaporan(String id) async {
    await laporanCollection.doc(id).delete();
  }

  Future<void> updateLaporan(Laporan laporan) async {
    await laporanCollection.doc(laporan.id).update(laporan.toMap());
  }
}
