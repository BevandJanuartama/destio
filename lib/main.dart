import 'package:destio/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:destio/screens/dashboard/dashboard.dart'; // halaman admin
import 'package:destio/screens/user/user_main_page.dart'; // halaman user
import 'package:destio/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Destio Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User? user;
  String? userLevel;
  bool isLoading = true;
  late final Stream<User?> authStream;

  @override
  void initState() {
    super.initState();

    authStream = FirebaseAuth.instance.authStateChanges();

    authStream.listen((user) async {
      if (user == null) {
        // User logout
        if (mounted) {
          setState(() {
            this.user = null;
            userLevel = null;
            isLoading = false;
          });
        }
      } else {
        // User login, fetch level
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          if (mounted) {
            setState(() {
              this.user = user;
              userLevel = doc.get('level');
              isLoading = false;
            });
          }
        } else {
          // User data tidak ditemukan
          if (mounted) {
            setState(() {
              this.user = null;
              userLevel = null;
              isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const LoginScreen();
    } else {
      if (userLevel == 'admin') {
        return const MyHomePage();
      } else if (userLevel == 'user') {
        return const UserMainPage();
      } else {
        // Level tidak dikenali, kembali ke login
        return const LoginScreen();
      }
    }
  }
}
