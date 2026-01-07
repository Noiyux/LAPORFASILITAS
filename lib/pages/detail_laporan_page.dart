import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/laporan_model.dart';
import 'edit_laporan_page.dart';

class DetailLaporanPage extends StatelessWidget {
  final Laporan laporan;

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

  const DetailLaporanPage({super.key, required this.laporan});

  String formatTanggal(Timestamp timestamp) {
    return DateFormat('dd MMMM yyyy • HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final hasFoto = laporan.fotoPath.isNotEmpty;
    final LatLng lokasi = LatLng(laporan.latitude, laporan.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
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

            // ================= FOTO =================
            if (hasFoto)
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ================= JUDUL =================
                  Text(
                    laporan.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

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


                  // ================= META =================
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

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

                  const SizedBox(height: 20),

                  // ================= DESKRIPSI =================
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(laporan.deskripsi),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= MAP PREVIEW =================
                  const Text(
                    'Lokasi Laporan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: lokasi,
                          initialZoom: 16,
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

                  const SizedBox(height: 8),

                  Text(
                    'Lat: ${laporan.latitude}, Lng: ${laporan.longitude}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
