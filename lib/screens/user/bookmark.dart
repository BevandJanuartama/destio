import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:destio/screens/user/deskripsi.dart';
import 'package:destio/models/destinasi_model.dart';


// Widget Card mirip ProvinceCard untuk Bookmark
class BookmarkCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const BookmarkCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Bookmark
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference bookmarkCollection = FirebaseFirestore.instance
      .collection('bookmark');
  final CollectionReference destioCollection = FirebaseFirestore.instance
      .collection('destio');

  late Future<List<Map<String, dynamic>>> _bookmarkedDestinations;

  @override
  void initState() {
    super.initState();
    _bookmarkedDestinations = _fetchBookmarkedDestinations();
  }

  Future<List<Map<String, dynamic>>> _fetchBookmarkedDestinations() async {
    if (user == null) return [];

    final bookmarksSnapshot = await bookmarkCollection
        .where('id_user', isEqualTo: user!.uid)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> destinations = [];

    for (var bookmarkDoc in bookmarksSnapshot.docs) {
      final destId = bookmarkDoc['id_destinasi'];

      final destinasiDoc = await destioCollection.doc(destId).get();
      if (destinasiDoc.exists) {
        final destinasiData = destinasiDoc.data() as Map<String, dynamic>;
        destinasiData['docId'] = destinasiDoc.id;

        String imageUrl = '';
        if (destinasiData.containsKey('gambar_nama') &&
            destinasiData['gambar_nama'] is List &&
            destinasiData['gambar_nama'].isNotEmpty) {
          imageUrl = destinasiData['gambar_nama'][0];
        }

        destinasiData['imageUrl'] = imageUrl;

        destinations.add(destinasiData);
      }
    }

    return destinations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark Saya')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookmarkedDestinations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada destinasi yang dibookmark.'),
            );
          }

          final destinasiList = snapshot.data!;

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 190 / 253,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: destinasiList.length,
            itemBuilder: (context, index) {
              final destinasi = destinasiList[index];
              return BookmarkCard(
                name: destinasi['nama'] ?? 'Tanpa Nama',
                imagePath: destinasi['imageUrl'].isNotEmpty
                    ? destinasi['imageUrl']
                    : 'https://via.placeholder.com/190x253.png?text=No+Image',
                onTap: () {
                  // Convert Map ke DestinasiModel dengan id dokumen
                  final destinasiModel = DestinasiModel.fromMap(
                    destinasi,
                    destinasi['docId'],
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeskripsiUser(destinasi: destinasiModel),
                    ),
                  );
                },

              );
            },
          );
        },
      ),
    );
  }
}
