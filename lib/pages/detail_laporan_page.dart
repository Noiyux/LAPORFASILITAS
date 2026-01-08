import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/laporan_model.dart';
import 'edit_laporan_page.dart';

class DetailLaporanPage extends StatelessWidget {
  final Laporan laporan;

  const DetailLaporanPage({super.key, required this.laporan});

  Color statusColor(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String formatTanggal(Timestamp timestamp) {
    return DateFormat('dd MMMM yyyy • HH:mm').format(timestamp.toDate());
  }

  /// ================= BUKA PETA EKSTERNAL =================
  Future<void> bukaPetaEksternal() async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=${laporan.latitude}&mlon=${laporan.longitude}&zoom=18',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFoto = laporan.fotoPath.isNotEmpty;
    final LatLng lokasi = LatLng(laporan.latitude, laporan.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Laporan',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditLaporanPage(laporan: laporan),
                ),
              );

              if (context.mounted && result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= FOTO (TAP → FULLSCREEN) =================
            if (hasFoto)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: EdgeInsets.zero,
                      child: InteractiveViewer(
                        child: Image.file(
                          File(laporan.fotoPath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Image.file(
                      File(laporan.fotoPath),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ================= JUDUL + STATUS =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          laporan.judul,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          laporan.status,
                          style: TextStyle(
                            color: statusColor(laporan.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                            statusColor(laporan.status).withValues(alpha: 0.15),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ================= META INFO =================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                laporan.lokasi,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              formatTanggal(laporan.tanggal),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= DESKRIPSI =================
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            laporan.deskripsi,
                            style: const TextStyle(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= MAP TITLE =================
                  Row(
                    children: const [
                      Icon(Icons.map, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Lokasi Laporan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ================= MAP (INTERAKTIF) =================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: lokasi,
                          initialZoom: 16,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.laporfasilitas',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: lokasi,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ================= BUKA PETA EKSTERNAL =================
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: bukaPetaEksternal,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Buka di Peta'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ================= KOORDINAT =================
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('Lat: ${laporan.latitude}')),
                      Chip(label: Text('Lng: ${laporan.longitude}')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
