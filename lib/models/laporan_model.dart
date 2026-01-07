import 'package:cloud_firestore/cloud_firestore.dart';

class Laporan {
  final String id;
  final String userId;
  final String judul;
  final String deskripsi;
  final String lokasi;
  final String detailLokasi;
  final double latitude;
  final double longitude;
  final Timestamp tanggal;
  final String fotoPath;
  final String status;

  const Laporan({
    required this.id,
    required this.userId,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    required this.detailLokasi,
    required this.latitude,
    required this.longitude,
    required this.tanggal,
    required this.fotoPath,
    required this.status,
  });

  // ================= TO MAP (SAVE KE FIRESTORE) =================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'judul': judul,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'detailLokasi': detailLokasi,
      'latitude': latitude,
      'longitude': longitude,
      'tanggal': tanggal,
      'fotoPath': fotoPath,
      'status': status, 
    };
  }

  // ================= FROM MAP (AMBIL DARI FIRESTORE) =================
  factory Laporan.fromMap(String id, Map<String, dynamic> map) {
    return Laporan(
      id: id,
      userId: map['userId'] as String? ?? '',
      judul: map['judul'] as String? ?? '',
      deskripsi: map['deskripsi'] as String? ?? '',
      lokasi: map['lokasi'] as String? ?? '',
      detailLokasi: map['detailLokasi'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      tanggal: map['tanggal'] as Timestamp? ?? Timestamp.now(),
      fotoPath: map['fotoPath'] as String? ?? '',
      status: map['status'] as String? ?? 'Dikirim', 
    );
  }

  // ================= COPY WITH =================
  Laporan copyWith({
    String? judul,
    String? deskripsi,
    String? lokasi,
    String? detailLokasi,
    double? latitude,
    double? longitude,
    Timestamp? tanggal,
    String? fotoPath,
    String? status,
  }) {
    return Laporan(
      id: id,
      userId: userId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
      detailLokasi: detailLokasi ?? this.detailLokasi,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tanggal: tanggal ?? this.tanggal,
      fotoPath: fotoPath ?? this.fotoPath,
      status: status ?? this.status,
    );
  }
}
