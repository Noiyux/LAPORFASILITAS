import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/laporan_controller.dart';
import '../models/laporan_model.dart';
import 'tambah_laporan_page.dart';
import 'laporan_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final controller = LaporanController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Laporan>>(
        stream: controller.streamData(),
        builder: (context, snapshot) {
          final laporan = snapshot.data ?? [];

          final todayCount = laporan.where((e) {
            final tgl = e.tanggal.toDate();
            final now = DateTime.now();
            return tgl.year == now.year &&
                tgl.month == now.month &&
                tgl.day == now.day;
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER USER =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang 👋',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              user?.email ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ===== STATISTIK =====
                Text(
                  'Ringkasan Laporan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _statCard(
                      title: 'Total',
                      value: laporan.length.toString(),
                      icon: Icons.assignment,
                      onTap: () => _goToList(context),
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      title: 'Hari Ini',
                      value: todayCount.toString(),
                      icon: Icons.today,
                      onTap: () => _goToList(context),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ===== AKSI CEPAT =====
                Text(
                  'Aksi Cepat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TambahLaporanPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.list),
                        label: const Text('Daftar'),
                        onPressed: () => _goToList(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ===== EMPTY STATE =====
                if (laporan.isEmpty)
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada laporan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // ===== INFO =====
                Text(
                  'Tentang Aplikasi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi ini digunakan untuk melaporkan kerusakan '
                  'fasilitas umum secara cepat dengan foto dan lokasi.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goToList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LaporanListPage(),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
