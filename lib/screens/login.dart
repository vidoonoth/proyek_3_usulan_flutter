import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:perpus_flutter/config/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  var logger = Logger();

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      if (mounted) _showSnackBar("Email dan password tidak boleh kosong!");
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl('login')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return; // Cek apakah widget masih aktif

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['user']['id']; // ambil user ID

        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('user_id', userId); // simpan user ID juga
          logger.i("✅ Token: $token");
          logger.i("✅ User ID: $userId");

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          _showSnackBar(
            "Login berhasil, tetapi token atau user ID tidak ditemukan.",
          );
        }
      } else {
        logger.i('Response body: ${response.body}');
        _showErrorDialog("Email / password yang Anda masukkan salah.");
      }
    } on SocketException catch (e) {
      logger.e(
        "🚫 SocketException: Tidak dapat terhubung ke server. Pesan: $e",
      );
      if (mounted) {
        _showSnackBar("Tidak dapat terhubung ke server. Periksa koneksi Anda.");
      }
    } catch (e) {
      logger.e("❌ Exception lain: $e");
      if (mounted) _showSnackBar("Terjadi kesalahan: $e");
    } finally {
      if (mounted) isLoading.value = false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text("Login Gagal"),
            ],
          ),
          content: Text(message, style: const TextStyle(color: Colors.black87)),
          actions: [
            TextButton(
              child: const Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo dan Judul
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/perpus_logo.svg',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perpustakaan',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Indramayu',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Input Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email atau nomor telepon',
                  hintText: 'Masukkan email atau nomor telepon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 15),

              // Input Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 10),

              // Teks Daftar dan Lupa Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      "Belum punya akun? Daftar",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Lupa kata sandi?",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Tombol Login
              ValueListenableBuilder<bool>(
                valueListenable: isLoading,
                builder: (context, loading, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          loading
                              ? null
                              : () => login(
                                emailController.text,
                                passwordController.text,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child:
                          loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Masuk',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Divider "atau login dengan"
              Row(
                children: [
                  Expanded(
                    child: Divider(thickness: 1, color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "atau login dengan",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 1, color: Colors.grey.shade300),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tombol Login Google
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {}, // Tambahkan fungsi login Google jika ada
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Login dengan",
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      Image.asset('assets/google_logo.svg.png', height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
