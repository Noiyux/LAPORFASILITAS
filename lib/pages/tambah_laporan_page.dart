import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/location_service.dart';
import '../controllers/laporan_controller.dart';
import '../models/laporan_model.dart';

class TambahLaporanPage extends StatefulWidget {
  const TambahLaporanPage({super.key});

  @override
  State<TambahLaporanPage> createState() => _TambahLaporanPageState();
}

class _TambahLaporanPageState extends State<TambahLaporanPage> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _detailLokasiController = TextEditingController();

  final controller = LaporanController();
  final picker = ImagePicker();

  File? _foto;

  double? latitude;
  double? longitude;

  bool isSaving = false;
  bool isGettingLocation = false;

  // ================= PILIH FOTO =================
  Future<void> pilihFoto(ImageSource source) async {
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1280,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _foto = File(picked.path);
      });
    }
  }

  // ================= SIMPAN FOTO LOCAL =================
  Future<String?> simpanFotoLocal(File foto) async {
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/laporan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newFile = await foto.copy(path);
    return newFile.path;
  }

  // ================= AMBIL LOKASI =================
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
        _alamatController.text = address;
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

  // ================= SIMPAN LAPORAN =================
  Future<void> simpan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil lokasi terlebih dahulu')),
      );
      return;
    }

    setState(() => isSaving = true);

    String fotoPath = '';
    if (_foto != null) {
      try {
        fotoPath = await simpanFotoLocal(_foto!) ?? '';
      } catch (_) {}
    }

    final laporan = Laporan(
      id: '',
      userId: user.uid,
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      lokasi: _alamatController.text.trim(),
      detailLokasi: _detailLokasiController.text.trim(),
      latitude: latitude!,
      longitude: longitude!,
      tanggal: Timestamp.now(),
      fotoPath: fotoPath,
      status: 'Dikirim',
    );

    await controller.tambah(laporan);

    if (!mounted) return;

    setState(() => isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _detailLokasiController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Laporan')),
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

                  // ===== ALAMAT =====
                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lokasi',
                      helperText: 
                          'Alamat otomatis diisi berdasarkan koordinat yang diambil dan dapat diedit secara manual',
                          helperMaxLines: 3,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Alamat lokasi wajib diisi' : null,
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

                  Center(
                    child: OutlinedButton.icon(
                      icon: isGettingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: const Text('Ambil Lokasi Sekarang'),
                      onPressed: isGettingLocation ? null : ambilLokasiBaru,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== FOTO =====
                  const Text(
                    'Foto Laporan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Kamera'),
                          onPressed: () => pilihFoto(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.photo),
                          label: const Text('Galeri'),
                          onPressed: () => pilihFoto(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  if (_foto != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _foto!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ===== SIMPAN =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : simpan,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Simpan Laporan'),
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
