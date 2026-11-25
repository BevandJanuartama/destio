import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:destio/screens/auth/login_screen.dart';
import 'package:destio/screens/user/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController birthdayDateController;

  String photoUrl = '';

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    telephoneController = TextEditingController();
    birthdayDateController = TextEditingController();

    _fetchUserData();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    birthdayDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          emailController.text = data?['email'] ?? user?.email ?? '';
          usernameController.text = data?['username'] ?? '';
          telephoneController.text = data?['telephone'] ?? '';
          birthdayDateController.text = data?['birthdayDate'] ?? '';
          photoUrl = data?['photoUrl'] ?? '';
        });
      } else {
        // buat dokumen baru jika belum ada
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': user?.email ?? '',
          'username': '',
          'telephone': '',
          'birthdayDate': '',
          'photoUrl': '',
        });
        setState(() {
          emailController.text = user?.email ?? '';
          usernameController.text = '';
          telephoneController.text = '';
          birthdayDateController.text = '';
          photoUrl = '';
        });
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah kamu yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFF60A3D9),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 120,
                backgroundImage: (photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : const AssetImage('image/profile.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 35),
            ProfileField(label: 'Username', controller: usernameController),
            const SizedBox(height: 17),
            ProfileField(label: 'Email', controller: emailController),
            const SizedBox(height: 17),
            ProfileField(label: 'Telephone', controller: telephoneController),
            const SizedBox(height: 17),
            ProfileField(
              label: 'Birthday Date',
              controller: birthdayDateController,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                ).then((_) {
                  _fetchUserData(); // refresh data saat kembali dari halaman edit
                });
              },
              child: const Text(
                'EDIT PROFILE',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ProfileField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: false,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
