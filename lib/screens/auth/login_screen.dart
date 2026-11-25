import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destio/screens/auth/signup_screen.dart';
import 'package:destio/screens/dashboard/dashboard.dart';
import 'package:destio/screens/user/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  bool isRememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    loadUserEmailPassword();
  }

  void loadUserEmailPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        isRememberMe = true;
      });
    }
  }

  void saveUserEmailPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isRememberMe) {
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  void login() async {
    if (!mounted) return;
    setState(() {
      errorMessage = "";
    });

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Email dan Password harus diisi";
      });
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        saveUserEmailPassword();

        String uid = userCredential.user!.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!userDoc.exists) {
          setState(() {
            errorMessage = "Data pengguna tidak ditemukan di Firestore.";
          });
          return;
        }

        String level = userDoc['level'];

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
                  'Login Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.of(context).pop();

        if (level == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else if (level == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Terjadi kesalahan.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6BD8E0), Color(0xE6EEEEEE)],
                stops: [0.10, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: Image.network(
              "https://image2url.com/images/1765959942031-3c8ac89e-705e-4b91-bfa9-ef444c61468a.png",
              fit: BoxFit.cover,
            ),
          ),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Image.network(
                      "https://image2url.com/images/1765959888722-9b273262-13ca-41bd-8f6b-bbcabca6ecec.png",
                      height: 100,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: const TextStyle(fontSize: 20),
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
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(fontSize: 20),
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isRememberMe,
                          onChanged: (value) {
                            setState(() {
                              isRememberMe = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 2),
                        const Text("Ingat Saya"),
                      ],
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF127AC1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: login,
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Center(
                      child: Text(
                        "Belum punya akun?",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
