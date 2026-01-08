import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/laporan_model.dart';
import '../services/location_service.dart';
import '../controllers/laporan_controller.dart';

class EditLaporanPage extends StatefulWidget {
  final Laporan laporan;

  const EditLaporanPage({
    super.key,
    required this.laporan,
  });

  @override
  State<EditLaporanPage> createState() => _EditLaporanPageState();
}

class _EditLaporanPageState extends State<EditLaporanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _lokasiController;       // alamat otomatis
  late final TextEditingController _detailLokasiController; // manual

  final controller = LaporanController();

  double? latitude;
  double? longitude;

  bool isSaving = false;
  bool isGettingLocation = false;

  @override
  void initState() {
    super.initState();

    _judulController = TextEditingController(text: widget.laporan.judul);
    _deskripsiController =
        TextEditingController(text: widget.laporan.deskripsi);
    _lokasiController =
        TextEditingController(text: widget.laporan.lokasi);
    _detailLokasiController =
        TextEditingController(text: widget.laporan.detailLokasi);

    latitude = widget.laporan.latitude;
    longitude = widget.laporan.longitude;
  }

  // ================= AMBIL LOKASI BARU =================
  Future<void> ambilLokasiBaru() async {
    setState(() => isGettingLocation = true);

    try {
      final position = await LocationService.getCurrentLocation();
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        _lokasiController.text = address;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isGettingLocation = false);
      }
    }
  }

  // ================= SIMPAN PERUBAHAN =================
  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum tersedia')),
      );
      return;
    }

    setState(() => isSaving = true);

    final updatedLaporan = widget.laporan.copyWith(
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      lokasi: _lokasiController.text.trim(),
      detailLokasi: _detailLokasiController.text.trim(),
      latitude: latitude!,
      longitude: longitude!,
      tanggal: Timestamp.now(),
    );

    await controller.update(updatedLaporan);

    if (!mounted) return;

    setState(() => isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _detailLokasiController.dispose();
    super.dispose();
  }

  // ================= UI =================
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Laporan'),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ===== JUDUL =====
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Laporan',
                    hintText: 'Nama laporan atau benda yang dilaporkan',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                ),

                const SizedBox(height: 16),

                // ===== DESKRIPSI =====
                TextFormField(
                  controller: _deskripsiController,
                  minLines: 3,
                  maxLines: 5,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Jelaskan secara detail kerusakan yang terjadi',
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),

                const SizedBox(height: 16),

                // ===== ALAMAT =====
                TextFormField(
                  controller: _lokasiController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lokasi',
                    hintText:
                        'Alamat otomatis diisi berdasarkan koordinat dan dapat diedit manual',
                    prefixIcon: Icon(Icons.location_on),
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),

                const SizedBox(height: 16),

                // ===== DETAIL LOKASI =====
                TextFormField(
                  controller: _detailLokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Detail Lokasi',
                    hintText:
                        'Contoh: depan gerbang sekolah, lantai 2 gedung A',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Detail lokasi wajib diisi' : null,
                ),

                const SizedBox(height: 24),

                // ===== KOORDINAT =====
                const Text(
                  'Koordinat Lokasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latitude  : ${latitude ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('Longitude : ${longitude ?? '-'}'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ===== AMBIL LOKASI =====
                Center(
                  child: OutlinedButton.icon(
                    icon: isGettingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Perbarui Lokasi Sekarang'),
                    onPressed: isGettingLocation ? null : ambilLokasiBaru,
                  ),
                ),

                const SizedBox(height: 28),

                // ===== SIMPAN =====
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        (isSaving || isGettingLocation) ? null : simpanPerubahan,
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}