// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../models/destinasi_model.dart';

// class DestinasiService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   Future<void> createDestinasi(
//     DestinasiModel destinasi,
//     List<Uint8List> images, {
//     void Function(int index, double progress)? onUploadProgress,
//   }) async {
//     try {
//       List<String> imageUrls = [];

//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       for (int i = 0; i < images.length; i++) {
//         final ref = _storage
//             .ref()
//             .child('destinasi_images')
//             .child('${timestamp}_$i.jpg');

//         final uploadTask = ref.putData(images[i]);

//         // Monitoring upload progress
//         uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//           if (onUploadProgress != null && snapshot.totalBytes > 0) {
//             double progress = snapshot.bytesTransferred / snapshot.totalBytes;
//             onUploadProgress(i, progress); // Kirim progress per gambar
//           }
//         });

//         final snapshot = await uploadTask;
//         final url = await snapshot.ref.getDownloadURL();
//         imageUrls.add(url);
//       }

//       destinasi.gambarUrls = imageUrls;
//       await _firestore.collection('destinasi').add(destinasi.toMap());
//     } catch (e) {
//       throw Exception('Gagal upload destinasi: $e');
//     }
//   }

//   Stream<List<DestinasiModel>> getDestinasiByProvinsi(String provinsi) {
//     return _firestore
//         .collection('destinasi')
//         .where('provinsi', isEqualTo: provinsi)
//         .snapshots()
//         .map(
//           (snapshot) =>
//               snapshot.docs
//                   .map((doc) => DestinasiModel.fromMap(doc.data()))
//                   .toList(),
//         );
//   }

//   Stream<List<DestinasiModel>> getDestinasiByDeskripsi(String deskripsi) {
//     return _firestore
//         .collection('destinasi')
//         .where('about', isEqualTo: deskripsi)
//         .snapshots()
//         .map(
//           (snapshot) =>
//               snapshot.docs
//                   .map((doc) => DestinasiModel.fromMap(doc.data()))
//                   .toList(),
//         );
//   }
// }
