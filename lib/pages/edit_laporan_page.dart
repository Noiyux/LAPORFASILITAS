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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                      helperText: 'Nama Laporan atau Benda yang dilaporkan',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                  ),

                  const SizedBox(height: 12),

                  // ===== DESKRIPSI =====
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      helperText: 'Jelaskan Secara Detail Kerusakan yg terjadi',
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                  ),

                  const SizedBox(height: 12),

                  // ===== ALAMAT OTOMATIS =====
                  TextFormField(
                    controller: _lokasiController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lokasi',
                      prefixIcon: Icon(Icons.location_on),
                      helperText: 
                          'Alamat otomatis diisi berdasarkan koordinat yang diambil dan dapat diedit secara manual',
                          helperMaxLines: 3,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                  ),

                  const SizedBox(height: 12),

                  // ===== DETAIL MANUAL =====
                  TextFormField(
                    controller: _detailLokasiController,
                    decoration: const InputDecoration(
                      labelText: 'Detail Lokasi',
                      helperText:
                          'Contoh: depan gerbang sekolah, lantai 2 gedung A',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Detail lokasi wajib diisi' : null,
                  ),

                  const SizedBox(height: 20),

                  // ===== KOORDINAT =====
                  const Text(
                    'Koordinat Lokasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude  : ${latitude ?? '-'}'),
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
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: const Text('Perbarui Lokasi Sekarang'),
                      onPressed: isGettingLocation ? null : ambilLokasiBaru,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== SIMPAN =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (isSaving || isGettingLocation) ? null : simpanPerubahan,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Simpan Perubahan'),
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
