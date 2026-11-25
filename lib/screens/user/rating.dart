import 'package:flutter/material.dart';
import 'package:destio/screens/user/give_rating.dart';
import 'package:destio/models/destinasi_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatelessWidget {
  final CollectionReference ratingCollection = FirebaseFirestore.instance
      .collection('rating');
  final DestinasiModel destinasi;

  RatingPage({super.key, required this.destinasi});

  @override
  Widget build(BuildContext context) {
    print("ID destinasi: ${destinasi.id}"); // DEBUG: cetak ID

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Rating for ${destinasi.nama}'),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.orange),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ratingCollection
                  .where(
                    'destinasi_id',
                    isEqualTo: destinasi.id.toString(),
                  ) // pastikan string
                  // .orderBy('timestamp', descending: true) // bisa diaktifkan lagi jika index OK
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("Firestore Error: ${snapshot.error}");
                  return const Center(child: Text('Terjadi kesalahan.'));
                }

                final docs = snapshot.data?.docs ?? [];

                print("Jumlah dokumen ditemukan: ${docs.length}"); // DEBUG

                for (var doc in docs) {
                  print(doc.data()); // DEBUG: cetak isi dokumen
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada rating'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index];
                    final namaUser = item['username'] ?? 'Anonymous';
                    final komentar = item['komentar'] ?? '';
                    final rating = item['rating'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.grey, width: 0.3),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              item['photo_url'] != null &&
                                  item['photo_url'] != ''
                              ? NetworkImage(item['photo_url'])
                              : null,
                          child:
                              item['photo_url'] == null ||
                                  item['photo_url'] == ''
                              ? const Icon(Icons.person)
                              : null,
                        ),

                        title: Text(namaUser),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GiveRatingPage(
                      destinasiId: destinasi.id,
                      destinasiNama: destinasi.nama,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Give your rating for this place',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
