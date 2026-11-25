import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:destio/models/destinasi_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destio/screens/user/rating.dart';
import 'package:destio/screens/admin/tambah.dart';

class DeskripsiPage extends StatelessWidget {
  final DestinasiModel destinasi;
  final CollectionReference destioCollection = FirebaseFirestore.instance
      .collection('destio');
  final CollectionReference ratingCollection = FirebaseFirestore.instance
      .collection('rating');

  DeskripsiPage({super.key, required this.destinasi});

  Future<void> _launchMaps(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Yakin ingin menghapus destinasi ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                try {
                  await destioCollection.doc(docId).delete();
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali ke layar sebelumnya
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Destinasi berhasil dihapus')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destinasi.nama),
        backgroundColor: const Color.fromRGBO(86, 184, 255, 1),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TambahPage(destinasi: destinasi),
                  ),
                );
              } else if (value == 'hapus') {
                _showDeleteConfirmationDialog(context, destinasi.id);
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar destinasi
            if (destinasi.gambarNama.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinasi.gambarNama.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        destinasi.gambarNama[index],
                        width: 300,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            width: 300,
                            height: 180,
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(child: Text('Tidak ada gambar')),
              ),

            const SizedBox(height: 16),

            // Informasi dasar
            Text(
              destinasi.nama,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(destinasi.deskripsi, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Lokasi dan jam operasional
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jam Operasional',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destinasi.jamOperasional,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Harga Tiket
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga Tiket',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destinasi.hargaTiket,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Alamat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alamat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destinasi.namaJalan,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),




            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed:
                  destinasi.linkMaps.isNotEmpty
                      ? () => _launchMaps(context, destinasi.linkMaps)
                      : null,
              icon: const Icon(Icons.map),
              label: const Text('Buka di Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(86, 184, 255, 1),
              ),
            ),

            const SizedBox(height: 24),

             // Komentar dan rating
            const Text(
              'Komentar dan Rating',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: ratingCollection
                  .where('id_destinasi', isEqualTo: destinasi.id)
                  .where('rating', isEqualTo: 5)
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasData =
                    snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                final doc = hasData ? snapshot.data!.docs.first : null;
                final namaUser = doc?['nama_user'] ?? 'User';
                final komentar = doc?['komentar'] ?? '';
                final rating = doc?['rating'] ?? 5;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RatingPage(destinasi: destinasi),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Row(
                                  children: [
                                    Text('5', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 4),
                                    Icon(Icons.star, color: Colors.orange),
                                  ],
                                ),
                                Text(
                                  'Lihat Semua',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          hasData
                              ? ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(namaUser),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          rating,
                                          (index) => const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(komentar),
                                    ],
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Belum ada komentar'),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),



            const SizedBox(height: 24),

            // Rekomendasi
            const Text(
              'Rekomendasi Sekitar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecommendationBox(
              title: 'Travel',
              items: destinasi.rekomendasiTravel.join(', '),
            ),
            RecommendationBox(
              title: 'Penginapan',
              items: destinasi.rekomendasiPenginapan.join(', '),
            ),
            RecommendationBox(
              title: 'Tempat Makan',
              items: destinasi.rekomendasiKuliner.join(', '),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class RecommendationBox extends StatelessWidget {
  final String title;
  final String items;

  const RecommendationBox({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withOpacity(0.3), // Border hitam 30% opacity
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.recommend, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(items, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
