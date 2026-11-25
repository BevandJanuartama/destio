import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destio/models/destinasi_model.dart';
import 'package:destio/screens/detail/deskripsi.dart';

class ProvinsiPage extends StatelessWidget {
  final String provinsi;

  const ProvinsiPage({super.key, required this.provinsi});

  Stream<List<DestinasiModel>> _getDestinasiByProvinsi(String provinsi) {
    return FirebaseFirestore.instance
        .collection('destio')
        .where('provinsi', isEqualTo: provinsi)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DestinasiModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destinasi di $provinsi'),
        backgroundColor: const Color.fromRGBO(86, 184, 255, 1),
      ),
      body: StreamBuilder<List<DestinasiModel>>(
        stream: _getDestinasiByProvinsi(provinsi),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data destinasi'));
          }

          final destinasiList = snapshot.data!;

          return ListView.builder(
            itemCount: destinasiList.length,
            itemBuilder: (context, index) {
              final destinasi = destinasiList[index];
              final gambarPertama =
                  destinasi.gambarNama.isNotEmpty
                      ? destinasi.gambarNama[0]
                      : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DeskripsiPage(destinasi: destinasi),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 285,
                          child:
                              gambarPertama == null
                                  ? Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.image, size: 50),
                                    ),
                                  )
                                  : Image.network(
                                    gambarPertama,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          destinasi.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
