import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laporan_model.dart';

class LocalService {
  static const String keyLaporan = 'laporan_local';

  /// ================= SIMPAN KE LOCAL =================
  Future<void> simpanLaporan(List<Laporan> laporanList) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonData = laporanList.map((e) {
      return {
        'id': e.id,
        'userId': e.userId,
        'judul': e.judul,
        'deskripsi': e.deskripsi,
        'lokasi': e.lokasi,
        'latitude': e.latitude,
        'longitude': e.longitude,
        // 🔥 Timestamp → String
        'tanggal': e.tanggal.toDate().toIso8601String(),
        'fotoPath': e.fotoPath,
      };
    }).toList();

    await prefs.setString(keyLaporan, jsonEncode(jsonData));
  }

  /// ================= AMBIL DARI LOCAL =================
  Future<List<Laporan>> ambilLaporan() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyLaporan);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);

    return decoded.map<Laporan>((e) {
      return Laporan(
        id: e['id'],
        userId: e['userId'],
        judul: e['judul'],
        deskripsi: e['deskripsi'],
        lokasi: e['lokasi'],
        detailLokasi: e['detailLokasi'],
        latitude: e['latitude'],
        longitude: e['longitude'],
        tanggal: Timestamp.fromDate(
          DateTime.parse(e['tanggal']),
        ),
        fotoPath: e['fotoPath'],
        status: e['status'],
      );
    }).toList();
  }
}
