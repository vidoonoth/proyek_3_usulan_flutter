import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  await Future.delayed(Duration(seconds: 2)); // Simulasi splash delay

  if (!mounted) return; // Tambahkan ini sebelum memakai context

  if (token != null) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Tambahkan ini agar Row tidak memenuhi layar
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/perpus_logo.svg', width: 70, height: 70),
            SizedBox(width: 8),
            Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // Tambahkan ini agar Column tidak memenuhi layar
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perpustakaan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                Text(
                  'Indramayu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
