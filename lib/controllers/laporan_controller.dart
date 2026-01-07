import '../models/laporan_model.dart';
import '../services/firestore_service.dart';
import '../services/local_service.dart';

class LaporanController {
  final firestoreService = FirestoreService();
  final localService = LocalService();

  Future<List<Laporan>> ambilData() async {
    try {
      final data = await firestoreService.getLaporan();
      await localService.simpanLaporan(data);
      return data;
    } catch (e) {
      return await localService.ambilLaporan();
    }
  }

  Stream<List<Laporan>> streamData() {
  return firestoreService.streamLaporan();
}

  Future<void> tambah(Laporan laporan) async {
    await firestoreService.tambahLaporan(laporan);
  }

  Future<void> hapus(String id) async {
    await firestoreService.hapusLaporan(id);
  }

  Future<void> update(Laporan laporan) async {
  await firestoreService.updateLaporan(laporan);
  }

}
