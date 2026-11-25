import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:destio/models/destinasi_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destio/screens/user/rating.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeskripsiUser extends StatefulWidget {
  final DestinasiModel destinasi;

  const DeskripsiUser({super.key, required this.destinasi});

  @override
  State<DeskripsiUser> createState() => _DeskripsiUserState();
}

class _DeskripsiUserState extends State<DeskripsiUser> {
  final CollectionReference ratingCollection = FirebaseFirestore.instance
      .collection('rating');
  final CollectionReference bookmarkCollection = FirebaseFirestore.instance
      .collection('bookmark');

  bool isBookmarked = false;
  bool isLoadingBookmark = true;
  String? bookmarkDocId;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final querySnapshot =
            await bookmarkCollection
                .where('id_user', isEqualTo: user.uid)
                .where('id_destinasi', isEqualTo: widget.destinasi.id)
                .get();

        if (mounted) {
          setState(() {
            isBookmarked = querySnapshot.docs.isNotEmpty;
            if (isBookmarked) {
              bookmarkDocId = querySnapshot.docs.first.id;
            }
            isLoadingBookmark = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoadingBookmark = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingBookmark = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk menyimpan bookmark')),
      );
      return;
    }

    try {
      if (isBookmarked) {
        // Remove bookmark
        if (bookmarkDocId != null) {
          await bookmarkCollection.doc(bookmarkDocId).delete();
          setState(() {
            isBookmarked = false;
            bookmarkDocId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destinasi dihapus dari bookmark')),
          );
        }
      } else {
        // Add bookmark
        final docRef = await bookmarkCollection.add({
          'id_user': user.uid,
          'id_destinasi': widget.destinasi.id,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          isBookmarked = true;
          bookmarkDocId = docRef.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destinasi ditambahkan ke bookmark')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _launchMaps(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    try {
      // Coba buka langsung ke aplikasi Google Maps
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened) {
        // Jika gagal → fallback buka lewat browser
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka Google Maps: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.destinasi.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(86, 184, 255, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            if (widget.destinasi.gambarNama.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.destinasi.gambarNama.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.destinasi.gambarNama[index],
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('No Images')),
              ),
            const SizedBox(height: 20),

            // Judul dan Bookmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.destinasi.nama,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                isLoadingBookmark
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.blue : null,
                      ),
                      onPressed: _toggleBookmark,
                    ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              widget.destinasi.deskripsi,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),

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
                    widget.destinasi.jamOperasional,
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
                    widget.destinasi.hargaTiket,
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
                    widget.destinasi.namaJalan,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed:
                  widget.destinasi.linkMaps.isNotEmpty
                      ? () => _launchMaps(context, widget.destinasi.linkMaps)
                      : null,
              icon: const Icon(Icons.map),
              label: const Text('Buka di Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(86, 184, 255, 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              stream:
                  ratingCollection
                      .where('destinasi_id', isEqualTo: widget.destinasi.id)
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
                final namaUser = doc?['username'] ?? 'User';
                final komentar = doc?['komentar'] ?? '';
                final rating = doc?['rating'] ?? 5;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RatingPage(destinasi: widget.destinasi),
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
              items: widget.destinasi.rekomendasiTravel.join(', '),
            ),
            RecommendationBox(
              title: 'Penginapan',
              items: widget.destinasi.rekomendasiPenginapan.join(', '),
            ),
            RecommendationBox(
              title: 'Tempat Makan',
              items: widget.destinasi.rekomendasiKuliner.join(', '),
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
