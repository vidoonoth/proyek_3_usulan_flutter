import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'providers/usulan_provider.dart';
import 'providers/user_provider.dart';
import 'package:perpus_flutter/screens/buku.dart';
import 'package:perpus_flutter/screens/informasi/informasi.dart';
import 'package:perpus_flutter/screens/riwayat_usulan.dart';
import 'package:perpus_flutter/screens/profil.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/dashboard.dart';
import 'screens/splash_screen.dart';
import 'screens/notifikasi.dart';
import 'screens/detail_usulan.dart';
import 'screens/edit_usulan.dart';
// import 'package:perpus_flutter/pages/bottom_nav_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => UsulanProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pengusulan Buku",
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Pastikan sesuai dengan rute di bawah
      routes: {
        '/': (context) => SplashScreen(),
        '/login':
            (context) =>
                LoginPage(), // Sesuaikan dengan nama class di login.dart
        '/register':
            (context) =>
                RegisterScreen(), // Sesuaikan dengan nama class di register.dart
        '/dashboard':
            (context) =>
                DashboardScreen(), // Sesuaikan dengan nama class di dashboard.dart
        '/buku': (context) => BukuScreen(),
        '/riwayatUsulan': (context) => RiwayatUsulan(),
        '/informasi': (context) => Informasi(),
        '/profil': (context) => Profil(),
        '/notifikasi': (context) => NotifikasiScreen(),
        '/detailUsulan': (context) => DetailUsulan(),
        '/editUsulan': (context) => UpdateUsulan(),
      },
      // home: BottomNavScreen(),
    );
  }
}
