import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiveRatingPage extends StatefulWidget {
  final String destinasiId;
  final String destinasiNama;

  const GiveRatingPage({
    super.key,
    required this.destinasiId,
    required this.destinasiNama,
  });

  @override
  State<GiveRatingPage> createState() => _GiveRatingPageState();
}

class _GiveRatingPageState extends State<GiveRatingPage> {
  int selectedRating = 0;
  final TextEditingController komentarController = TextEditingController();

  String? username;
  String? photoUrl;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
          photoUrl = userDoc['photoUrl'];
          isLoadingUser = false;
        });
      }
    }
  }

  void submitRating() async {
    if (selectedRating == 0 || komentarController.text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && username != null) {
      await FirebaseFirestore.instance.collection('rating').add({
        'username': username,
        'photo_url': photoUrl ?? '', // <-- tambahkan ini
        'komentar': komentarController.text,
        'rating': selectedRating,
        'timestamp': FieldValue.serverTimestamp(),
        'destinasi_id': widget.destinasiId,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rating berhasil dikirim!')));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pengguna tidak ditemukan.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give your rating'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (photoUrl != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(photoUrl!),
                      radius: 40,
                    ),
                  const SizedBox(height: 8),
                  if (username != null)
                    Text(
                      '@$username',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Give your rating for ${widget.destinasiNama}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () =>
                            setState(() => selectedRating = index + 1),
                        icon: Icon(
                          Icons.star,
                          size: 50,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: komentarController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts about this place!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
