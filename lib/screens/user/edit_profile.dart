import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String password = '';
  String confirmPassword = '';

  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  final TextEditingController _oldPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _photoUrlController.text = data['photoUrl'] ?? ''; // kosongkan URL gambar sesuai permintaanmu
          _usernameController.text = data['username'] ?? '';
          _telephoneController.text = data['telephone'] ?? '';
          _birthdayController.text = data['birthdayDate'] ?? '';
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        // Update data profil kecuali password
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'photoUrl': _photoUrlController.text,
          'username': _usernameController.text,
          'telephone': _telephoneController.text,
          'birthdayDate': _birthdayController.text,
        });

        // Kalau mau ganti password, harus reauthenticate dulu
        if (password.isNotEmpty) {
          final cred = EmailAuthProvider.credential(
            email: user!.email!,
            password: _oldPasswordController.text,
          );
          await user.reauthenticateWithCredential(cred);
          await user.updatePassword(password);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal update password: $e')));
      }
    }
  }

  Widget buildEditableField(
    String label,
    TextEditingController controller,
    Function(String) onChanged, {
    bool obscureText = false,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
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
            obscureText: obscureText,
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
              suffixIcon: suffixIcon,
            ),
            onChanged: onChanged,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    if (_birthdayController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthdayController.text);
      } catch (_) {}
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final formatted = pickedDate.toIso8601String().split('T').first;
      setState(() {
        _birthdayController.text = formatted;
      });
    }
  }

  @override
  void dispose() {
    _photoUrlController.dispose();
    _usernameController.dispose();
    _telephoneController.dispose();
    _birthdayController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF60A3D9),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tampilkan preview foto hanya kalau URL ada isinya
              if (_photoUrlController.text.isNotEmpty) ...[
                CircleAvatar(
                  radius: 120,
                  backgroundImage: NetworkImage(_photoUrlController.text),
                ),
                const SizedBox(height: 35),
              ],

              buildEditableField(
                'Photo URL',
                _photoUrlController,
                (val) => setState(() {}),
                suffixIcon: const Icon(Icons.link),
              ),

              const SizedBox(height: 17),

              buildEditableField(
                'Username',
                _usernameController,
                (val) => setState(() {}),
                suffixIcon: const Icon(Icons.person),
              ),

              buildEditableField(
                'Telephone',
                _telephoneController,
                (val) => setState(() {}),
                suffixIcon: const Icon(Icons.phone),
              ),

              const SizedBox(height: 17),

              buildEditableField(
                'Birthday Date',
                _birthdayController,
                (val) {},
                readOnly: true,
                onTap: _selectDate,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Tanggal lahir harus diisi';
                  }
                  return null;
                },
                suffixIcon: const Icon(Icons.calendar_today),
              ),

              const SizedBox(height: 17),

              // Field password lama (required jika mau ganti password)
              buildEditableField(
                'Old Password',
                _oldPasswordController,
                (val) {},
                obscureText: true,
                validator: (val) {
                  if (password.isNotEmpty && (val == null || val.isEmpty)) {
                    return 'Password lama harus diisi untuk mengganti password';
                  }
                  return null;
                },
                suffixIcon: const Icon(Icons.lock_outline),
              ),

              buildEditableField(
                'New Password',
                TextEditingController(),
                (val) => password = val,
                obscureText: true,
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
                suffixIcon: const Icon(Icons.lock),
              ),

              buildEditableField(
                'Confirm Password',
                TextEditingController(),
                (val) => confirmPassword = val,
                obscureText: true,
                validator: (val) {
                  if (password.isNotEmpty && val != password) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
                suffixIcon: const Icon(Icons.lock),
              ),

              const SizedBox(height: 17),

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
                onPressed: _saveChanges,
                child: const Text(
                  'SAVE',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
