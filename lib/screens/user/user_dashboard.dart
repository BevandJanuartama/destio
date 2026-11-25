import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:destio/screens/user/deskripsi.dart';
import 'package:destio/screens/provinsi/provinsi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:destio/models/destinasi_model.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});
  static const String _title = 'Destio User Dashboard';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: UserHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> filteredRecommendations = [];

  final List<String> imagePaths = const [
    'https://image2url.com/images/1765961815371-f363c6ba-864b-4231-9026-cbc99d0dddfa.webp', // image/JATIM/bromo_desc.jpg
    'https://image2url.com/images/1765960178313-f5247d2c-cd33-4a1c-a70f-cb35780b83f5.jpg', // image/JATIM/bromo.jpg
    'https://image2url.com/images/1765961231754-ca67a8d9-18e6-4eed-9ebc-f50df1a6ad30.jpg', // image/JATIM/jatimpark3.webp
    'https://image2url.com/images/1765962314233-d9e84ba1-0ae0-49c0-8baf-d0b19cf53111.jpeg', // image/JATIM/papuma.jpg
    'https://image2url.com/images/1765962366304-4ddbfee3-377a-4447-bfc4-799e5727cac2.webp', // image/JATIM/plengkung.jpg
    'https://image2url.com/images/1765961073683-181ce805-7892-4601-bb41-34a1764cf55d.jpg', // image/JATENG/karimun_jawa.jpg
    'https://image2url.com/images/1765962493919-7228de2e-364b-4093-aa5f-f97b70e8a5b5.webp', // image/JATENG/dieng.jpg
    'https://image2url.com/images/1765962869342-f4eba3f7-b4ad-41f0-b1c3-186901d9122e.jpg', // image/JATENG/ijen.jpg
    'https://image2url.com/images/1765960800600-cf289ed5-9e11-4ad2-b40b-065f7d8488e8.webp', // image/JATENG/umbul_ponggok.jpg
    'https://image2url.com/images/1765962513104-b00feef8-e087-454d-9279-6ffcd895dae4.webp', // image/JAKARTA/kotatua1.jpg
    'https://image2url.com/images/1765962531705-cd140ebc-4623-4b0b-a0f5-e174e25add52.webp', // image/JAKARTA/monas5.jpg
    'https://image2url.com/images/1765962546419-1c32995b-6537-4030-a734-84539970091c.webp', // image/JAKARTA/tmii_besar.jpg
    'https://image2url.com/images/1765962799228-953a3740-4fed-49cb-952e-c3b2a3fea99c.png', // image/JABAR/farmhouse.jpg
    'https://image2url.com/images/1765962828534-2716c27f-314d-4bb0-a523-5b36d0fd2c04.jpg', // image/JABAR/gunung_puntang.jpg
    'https://image2url.com/images/1765962702363-ab58a346-f2a3-44ee-9e21-692ee730e18d.jpg', // image/JABAR/tangkuban_perahu.jpg
    'https://image2url.com/images/1765962756949-b49e3261-a666-4c95-bf02-fb49d61ce83e.webp', // image/JABAR/ujung_genteng.jpg
    'https://image2url.com/images/1765961537736-0473625a-826b-435e-af3a-b848e24261fd.webp', // image/BANTEN/tanjung_lesung.jpg
    'https://image2url.com/images/1765962738604-6d0eda77-55c4-42f4-8ca2-231fb4184cc8.jpeg', // image/JAKARTA/dufan.jpg
  ];

  final List<Map<String, dynamic>> recommendations = const [
    {
      'title': 'Mountain Recommendation',
      'indices': [1, 7, 14, 13, 6],
      'names': [
        'Gunung Bromo',
        'Kawah Ijen',
        'Gunung Tangkuban Perahu',
        'Gunung Puntang',
        'Dataran Tinggi Dieng',
      ],
    },
    {
      'title': 'Beach Recommendation',
      'indices': [5, 16, 4, 15, 3],
      'names': [
        'Pantai Karimun Jawa',
        'Pantai Tanjung Lesung',
        'Pantai Plengkung',
        'Pantai Ujung Genteng',
        'Pantai Papuma',
      ],
    },
    {
      'title': 'Attraction Recommendation',
      'indices': [2, 8, 9, 12, 17],
      'names': ['Jatim Park 3', 'Umbul Ponggok', 'TMII', 'Farm House', 'Dufan'],
    },
  ];

  final List<Map<String, dynamic>> provinces = const [
    {
      'name': 'Jawa Timur',
      'image':
          'https://image2url.com/images/1765962951632-e37147fe-5f3c-4425-83fe-a53b21b471d8.webp',
    },
    {
      'name': 'Daerah Istimewa Yogyakarta',
      'image':
          'https://image2url.com/images/1765962970928-6c6c9ee2-4f8a-4bad-94e7-aa1ab7c8f898.webp',
    },
    {
      'name': 'DKI Jakarta',
      'image':
          'https://image2url.com/images/1765962990910-956b3c65-5b94-4e5c-a41c-0f27a0cf4f51.webp',
    },
    {
      'name': 'Jawa Tengah',
      'image':
          'https://image2url.com/images/1765963006132-43b066c0-1812-4d58-91f3-7f2ed4a1d524.webp',
    },
    {
      'name': 'Jawa Barat',
      'image':
          'https://image2url.com/images/1765962702363-ab58a346-f2a3-44ee-9e21-692ee730e18d.jpg',
    },
    {
      'name': 'Banten',
      'image':
          'https://image2url.com/images/1765963051898-6eeaa13b-d4e3-484e-877d-17b7766b4a1a.webp',
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredRecommendations = recommendations;
    _searchController.addListener(_filterRecommendations);
  }

  void _filterRecommendations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredRecommendations = recommendations;
      } else {
        // Mengumpulkan semua item yang cocok dari semua kategori
        List<int> allMatchingIndices = [];
        List<String> allMatchingNames = [];

        for (var rec in recommendations) {
          for (int i = 0; i < rec['names'].length; i++) {
            if (rec['names'][i].toLowerCase().contains(query)) {
              // Cek agar tidak ada duplikat jika item ada di dua kategori
              if (!allMatchingNames.contains(rec['names'][i])) {
                allMatchingIndices.add(rec['indices'][i]);
                allMatchingNames.add(rec['names'][i]);
              }
            }
          }
        }

        // Format hasil pencarian agar bisa dibaca oleh buildRecommendation
        if (allMatchingIndices.isNotEmpty) {
          filteredRecommendations = [
            {
              'title': 'Search Results',
              'indices': allMatchingIndices,
              'names': allMatchingNames,
            },
          ];
        } else {
          filteredRecommendations = [];
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  buildCarousel(),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 1,
                    child: buildSearchBar(overlap: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ...filteredRecommendations.map(buildRecommendation),
            buildTitle('Provinces'),
            buildProvinceGrid(),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar({bool overlap = false}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: overlap
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Find Your Destination',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
        ),
      ),
    );
  }


  Widget buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 231,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
      ),
      items: [imagePaths[0], imagePaths[5], imagePaths[11]].map((path) {
        return Builder(
          builder: (context) => Container(
            width: double.infinity,
            margin: EdgeInsets.zero,
            child: Image.network(
              path,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildRecommendation(Map<String, dynamic> rec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitle(rec['title']),
        const SizedBox(height: 13),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: rec['indices'].length,
            itemBuilder: (context, index) {
              final destinasiMap = {
                'nama': rec['names'][index],
                'gambar_nama': [imagePaths[rec['indices'][index]]],
                'deskripsi': rec['title'],
                'provinsi': '',
                'jam_operasional': '',
                'harga_tiket': '',
                'nama_jalan': '',
                'link_maps': '',
              };
              final id = rec['indices'][index].toString();
              final destinasi = model.DestinasiModel.fromMap(destinasiMap, id);
              return DestinationCard(destinasi: destinasi);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildProvinceGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 190 / 253,
      ),
      itemCount: provinces.length,
      itemBuilder: (context, index) {
        final prov = provinces[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProvinsiPage(provinsi: prov['name']),
              ),
            );
          },
          child: ProvinceCard(name: prov['name'], imagePath: prov['image']),
        );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final model.DestinasiModel destinasi;

  const DestinationCard({super.key, required this.destinasi});

  @override
  Widget build(BuildContext context) {
    bool isAssetImage = destinasi.gambarNama.isNotEmpty && destinasi.gambarNama[0].startsWith('image/');

    return GestureDetector(
      onTap: () async {
        try {
          final destinasiNama = destinasi.nama.trim();

                    final snapshot =
              await FirebaseFirestore.instance
                  .collection('destio')
                  .where('nama', isEqualTo: destinasiNama)
                  .limit(1)
                  .get();

          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            final destinasiModel = model.DestinasiModel.fromMap(
              doc.data(),
              doc.id,
            );

            // Navigate to the destination description page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeskripsiUser(destinasi: destinasiModel),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Deskripsi untuk "$destinasiNama" tidak ditemukan.',
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        }
      },
      child: Container(
        width: 230,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    isAssetImage
                        ? Image.network(
                          destinasi.gambarNama[0],
                          fit: BoxFit.cover,
                        )
                        : Image.network(
                          destinasi.gambarNama.isNotEmpty
                              ? destinasi.gambarNama[0]
                              : 'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              destinasi.nama,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProvinceCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const ProvinceCard({super.key, required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
             
