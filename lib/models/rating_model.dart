import 'package:cloud_firestore/cloud_firestore.dart';


class RatingModel {
  final String id;
  final String namaUser;
  final String komentar;
  final int rating;
  final DateTime timestamp;
  final String destinasiId;

  RatingModel({
    required this.id,
    required this.namaUser,
    required this.komentar,
    required this.rating,
    required this.timestamp,
    required this.destinasiId,
  });

  factory RatingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RatingModel(
      id: id,
      namaUser: data['nama_user'] ?? 'User',
      komentar: data['komentar'] ?? '',
      rating: data['rating'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      destinasiId: data['destinasi_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_user': namaUser,
      'komentar': komentar,
      'rating': rating,
      'timestamp': timestamp,
      'destinasi_id': destinasiId,
    };
  }
}
