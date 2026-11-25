import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destio/screens/auth/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  void signUp() async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email dan Password harus diisi';
        isLoading = false;
      });
      return;
    }

    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      setState(() {
        errorMessage = 'Format email tidak valid';
        isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password minimal 6 karakter';
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Password dan konfirmasi tidak cocok';
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'level': 'user',
          'uid': user.uid,
          'created_at': FieldValue.serverTimestamp(),
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
                SizedBox(height: 16),
                Text(
                  'Sign Up Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );

        // Tunggu 1 detik
        await Future.delayed(const Duration(seconds: 1));

        // Tutup dialog
        Navigator.of(context).pop();

        // Navigasi ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Terjadi kesalahan';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background biru muda
      body: Stack(
        children: [
          // 1. Lapisan paling bawah: biru muda
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6BD8E0), // #6BD8E0 full opacity
                  Color(0xE6EEEEEE), // #EEEEEE with 90% opacity (E6 in hex)
                ],
                stops: [0.10, 1.0], // posisi gradasi: 10% ke 100%
              ),
            ),
          ),

          // 2. Gambar Borobudur di atas biru, tanpa transparansi
          Positioned.fill(
            child: Image.network(
              "https://image2url.com/images/1765959942031-3c8ac89e-705e-4b91-bfa9-ef444c61468a.png",
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
          ),

          // Logo "destio.pnd" di atas tengah layar
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Image.network(
                "https://image2url.com/images/1765960042492-f6f60f53-2330-4d29-99e1-ba8a9a86674f.png",
                height: 80,
              ),
            ),
          ),

          // Form transparan
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 520,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Ganti dari stretch ke center
                  children: [
                    const SizedBox(height: 10),
                    Image.network(
                      "https://image2url.com/images/1765959888722-9b273262-13ca-41bd-8f6b-bbcabca6ecec.png",
                      height: 100,
                    ), //logo merak
                    const SizedBox(height: 30),

                    // Email Field
                    TextField(
                      controller: emailController,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Konfirmasi Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Error message
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 15),

                    // Sign Up Button
                    SizedBox(
                      width: 200,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF127AC1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Already have account
                    const Text(
                      "Sudah punya akun?",
                      style: TextStyle(fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
