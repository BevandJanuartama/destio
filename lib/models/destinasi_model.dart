class DestinasiModel {
  String id;
  String nama;
  String provinsi;
  String deskripsi;
  String jamOperasional;
  String hargaTiket;
  String namaJalan;
  String linkMaps;
  List<String> gambarNama; // berisi URL gambar

  // Tambahan: rekomendasi travel, penginapan, dan kuliner
  List<String> rekomendasiTravel;
  List<String> rekomendasiPenginapan;
  List<String> rekomendasiKuliner;

  DestinasiModel({
    required this.id,
    required this.nama,
    required this.provinsi,
    required this.deskripsi,
    required this.jamOperasional,
    required this.hargaTiket,
    required this.namaJalan,
    required this.linkMaps,
    required this.gambarNama,
    required this.rekomendasiTravel,
    required this.rekomendasiPenginapan,
    required this.rekomendasiKuliner,
  });

  factory DestinasiModel.fromMap(Map<String, dynamic> map, String id) {
    List<String> parseList(dynamic data) {
      if (data == null) return [];
      if (data is String) return [data];
      if (data is List) return List<String>.from(data);
      return [];
    }

    return DestinasiModel(
      id: id,
      nama: map['nama'] ?? '',
      provinsi: map['provinsi'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      jamOperasional: map['jam_operasional'] ?? '',
      hargaTiket: map['harga_tiket'] ?? '',
      namaJalan: map['nama_jalan'] ?? '',
      linkMaps: map['link_maps'] ?? '',
      gambarNama: parseList(map['gambar_nama']),
      rekomendasiTravel: parseList(map['rekomendasi_travel']),
      rekomendasiPenginapan: parseList(map['rekomendasi_penginapan']),
      rekomendasiKuliner: parseList(map['rekomendasi_kuliner']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'provinsi': provinsi,
      'deskripsi': deskripsi,
      'jam_operasional': jamOperasional,
      'harga_tiket': hargaTiket,
      'nama_jalan': namaJalan,
      'link_maps': linkMaps,
      'gambar_nama': gambarNama,
      'rekomendasi_travel': rekomendasiTravel,
      'rekomendasi_penginapan': rekomendasiPenginapan,
      'rekomendasi_kuliner': rekomendasiKuliner,
    };
  }
}
