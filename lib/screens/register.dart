import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:perpus_flutter/config/config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController numberPhoneController = TextEditingController();
  TextEditingController nikController = TextEditingController();
  String selectedGender = 'Laki-laki';
  bool _isLoading = false;

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username harus diisi';
    }
    if (value.length < 4) {
      return 'Username minimal 4 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP harus diisi';
    }
    if (value.length != 13) {
      return 'Nomor HP harus 13 digit';
    }
    if (!value.isNumeric()) {
      return 'Hanya boleh mengandung angka';
    }
    return null;
  }

  String? _validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK harus diisi';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!value.isNumeric()) {
      return 'Hanya boleh mengandung angka';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl('register')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'numberphone': numberPhoneController.text,
          'nik': nikController.text,
          'gender': selectedGender,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        showMessage('Registrasi berhasil!', Colors.green);
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final responseData = jsonDecode(response.body);
        showMessage(
          responseData['message'] ?? 'Registrasi gagal!', 
          Colors.red
        );
      }
    } catch (error) {
      if (!mounted) return;
      showMessage('Terjadi kesalahan! Periksa koneksi Anda.', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Daftar",
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: nameController,
                    label: "Nama Lengkap",
                    validator: _validateName,
                  ),
                  _buildTextField(
                    controller: usernameController,
                    label: "Username",
                    validator: _validateUsername,
                  ),
                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  _buildTextField(
                    controller: numberPhoneController,
                    label: "Nomor HP (13 digit)",
                    keyboardType: TextInputType.phone,
                    maxLength: 13,
                    validator: _validatePhone,
                  ),
                  _buildTextField(
                    controller: nikController,
                    label: "NIK (16 digit)",
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    validator: _validateNIK,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      items: ['Laki-laki', 'Perempuan'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: passwordController,
                    label: "Password (minimal 8 karakter)",
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  _buildTextField(
                    controller: confirmPasswordController,
                    label: "Konfirmasi Password",
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 100,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Sudah punya akun? Masuk",
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }
}

extension NumericValidation on String {
  bool isNumeric() {
    return double.tryParse(this) != null;
  }
}