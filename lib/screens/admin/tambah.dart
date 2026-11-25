import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:destio/models/destinasi_model.dart';

class TambahPage extends StatefulWidget {
  final DestinasiModel? destinasi;

  const TambahPage({super.key, this.destinasi});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();
  final TextEditingController _tiketController = TextEditingController();
  final TextEditingController _namaJalanController = TextEditingController();
  final TextEditingController _urlMapsController = TextEditingController();

  final List<TextEditingController> _urlGambarControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _travelControllers = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _penginapanControllers = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _kulinerControllers = List.generate(
    2,
    (_) => TextEditingController(),
  );

  String? _selectedProvinsi;
  final List<String> _provinsiList = [
    'Jawa Barat',
    'Jawa Timur',
    'Jawa Tengah',
    'DKI Jakarta',
    'DI Yogyakarta',
    'Banten',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.destinasi != null) {
      _fetchLatestData(widget.destinasi!.id);
    }
  }

  Future<void> _fetchLatestData(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('destio').doc(id).get();
      if (doc.exists) {
        final d = DestinasiModel.fromMap(doc.data()!, doc.id);
        d.id = doc.id;

        _namaController.text = d.nama;
        _aboutController.text = d.deskripsi;
        _jamController.text = d.jamOperasional;
        _tiketController.text = d.hargaTiket;
        _namaJalanController.text = d.namaJalan;
        _urlMapsController.text = d.linkMaps;
        _selectedProvinsi = d.provinsi;

        for (int i = 0; i < d.gambarNama.length && i < 5; i++) {
          _urlGambarControllers[i].text = d.gambarNama[i];
        }
        for (int i = 0; i < d.rekomendasiTravel.length && i < 2; i++) {
          _travelControllers[i].text = d.rekomendasiTravel[i];
        }
        for (int i = 0; i < d.rekomendasiPenginapan.length && i < 2; i++) {
          _penginapanControllers[i].text = d.rekomendasiPenginapan[i];
        }
        for (int i = 0; i < d.rekomendasiKuliner.length && i < 2; i++) {
          _kulinerControllers[i].text = d.rekomendasiKuliner[i];
        }

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data terbaru: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    if (widget.destinasi == null &&
        _urlGambarControllers.any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi semua 5 URL gambar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final destinasi = DestinasiModel(
      id: widget.destinasi?.id ?? '',
      nama: _namaController.text.trim(),
      provinsi: _selectedProvinsi ?? '',
      deskripsi: _aboutController.text.trim(),
      jamOperasional: _jamController.text.trim(),
      hargaTiket: _tiketController.text.trim(),
      namaJalan: _namaJalanController.text.trim(),
      linkMaps: _urlMapsController.text.trim(),
      gambarNama: _urlGambarControllers.map((c) => c.text.trim()).toList(),
      rekomendasiTravel: _travelControllers.map((c) => c.text.trim()).toList(),
      rekomendasiPenginapan: _penginapanControllers.map((c) => c.text.trim()).toList(),
      rekomendasiKuliner: _kulinerControllers.map((c) => c.text.trim()).toList(),
    );

    try {
      final collection = FirebaseFirestore.instance.collection('destio');

      if (widget.destinasi != null) {
        await collection.doc(widget.destinasi!.id).update(destinasi.toMap());
      } else {
        await collection.add({
          ...destinasi.toMap(),
          'tanggal_input': Timestamp.now(),
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
            const SizedBox(height: 10),
            Text(
              widget.destinasi != null
                  ? "Destinasi berhasil diperbarui"
                  : "Destinasi berhasil ditambahkan",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context)
        ..pop() // tutup dialog
        ..pop(); // kembali halaman sebelumnya
    }
  

      // Tutup dialog dan kembali ke halaman sebelumnya setelah 2 detik
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context)
          ..pop() // Tutup dialog
          ..pop(); // Kembali ke halaman sebelumnya
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
  );

  Widget _buildUrlImageInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Input URL berjajar vertikal
      for (int i = 0; i < _urlGambarControllers.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _urlGambarControllers[i],
            decoration: InputDecoration(
              labelText: 'URL Gambar ${i + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Masukkan URL gambar' : null,
            onChanged: (_) => setState(() {}),
          ),
        ),

      const SizedBox(height: 16),

      // Preview gambar berjajar horizontal
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_urlGambarControllers.length, (index) {
            final url = _urlGambarControllers[index].text;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: url.isNotEmpty
                    ? Image.network(
                        url,
                        height: 100,
                        width: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                      )
                    : Container(
                        height: 100,
                        width: 140,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text(
                          'Preview ${index + 1}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
              ),
            );
          }),
        ),
      ),
    ],
  );



  Widget _buildListInput(
    String label,
    List<TextEditingController> controllers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        controllers.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextFormField(
            controller: controllers[index],
            decoration: _inputDecoration('$label ${index + 1}'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Masukkan $label' : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _aboutController.dispose();
    _jamController.dispose();
    _tiketController.dispose();
    _namaJalanController.dispose();
    _urlMapsController.dispose();
    for (final c in [
      ..._urlGambarControllers,
      ..._travelControllers,
      ..._penginapanControllers,
      ..._kulinerControllers,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.destinasi != null ? 'Edit Destinasi' : 'Tambah Destinasi',
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: _inputDecoration('Nama Destinasi'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Masukkan nama'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Provinsi'),
                    value: _selectedProvinsi,
                    items:
                        _provinsiList
                            .map(
                              (provinsi) => DropdownMenuItem(
                                value: provinsi,
                                child: Text(provinsi),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => _selectedProvinsi = value),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Pilih provinsi'
                                : null,
                  ),
                  _buildSectionTitle("Upload Gambar (5 URL)"),
                  _buildUrlImageInput(),

                  _buildSectionTitle("Deskripsi"),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 4,
                    decoration: _inputDecoration('Deskripsi'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Masukkan deskripsi'
                                : null,
                  ),

                  _buildSectionTitle("Jam Operasional"),
                  TextFormField(
                    controller: _jamController,
                    decoration: _inputDecoration('Jam Operasional'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Masukkan jam operasional'
                                : null,
                  ),

                  _buildSectionTitle("Harga Tiket Masuk"),
                  TextFormField(
                    controller: _tiketController,
                    maxLines: 3,
                    decoration: _inputDecoration('Harga Tiket Masuk'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Masukkan harga tiket'
                                : null,
                  ),

                  _buildSectionTitle("Alamat & Maps"),
                  TextFormField(
                    controller: _namaJalanController,
                    decoration: _inputDecoration('Nama Jalan'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Masukkan nama jalan'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _urlMapsController,
                    decoration: _inputDecoration('Link Google Maps'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Masukkan link Google Maps'
                                : null,
                  ),
                  _buildSectionTitle("Rekomendasi Travel (2)"),
                  _buildListInput("Travel", _travelControllers),
                  _buildSectionTitle("Rekomendasi Penginapan (2)"),
                  _buildListInput("Penginapan", _penginapanControllers),
                  _buildSectionTitle("Rekomendasi Kuliner (2)"),
                  _buildListInput("Kuliner", _kulinerControllers),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF85C8F8,
                        ), // Warna tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Radius 10
                          side: const BorderSide(
                            color: Color(0xFF6AA0C6), // Warna border
                            width: 2, // Ketebalan border
                          ),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.destinasi != null ? 'UPDATE' : 'SIMPAN',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
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
