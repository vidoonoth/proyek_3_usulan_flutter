import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:perpus_flutter/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to update the UI when focus changes
    _nameFocusNode.addListener(() => setState(() {}));
    _usernameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

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
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        }),
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Dapatkan token dari response
        final String token = responseData['token'] ?? '';
        final userData = responseData['user'] ?? {};

        // Simpan token dan user data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));

        showMessage('Registrasi berhasil!', Colors.green);
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        showMessage(responseData['message'] ?? 'Registrasi gagal!', Colors.red);
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Buat Akun Baru",
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),                 

                  // Name Field
                  _buildFloatingLabelField(
                    focusNode: _nameFocusNode,
                    controller: nameController,
                    label: "Nama Lengkap",
                    hint: "Masukkan nama lengkap Anda",
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),

                  // Username Field
                  _buildFloatingLabelField(
                    focusNode: _usernameFocusNode,
                    controller: usernameController,
                    label: "Username",
                    hint: "Masukkan username",
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _buildFloatingLabelField(
                    focusNode: _emailFocusNode,
                    controller: emailController,
                    label: "Email",
                    hint: "contoh@email.com",
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildPasswordField(
                    focusNode: _passwordFocusNode,
                    controller: passwordController,
                    label: "Password",
                    hint: "Minimal 8 karakter",
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildPasswordField(
                    focusNode: _confirmPasswordFocusNode,
                    controller: confirmPasswordController,
                    label: "Konfirmasi Password",
                    hint: "Ulangi password Anda",
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Daftar Sekarang',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Masuk",
                            style: GoogleFonts.poppins(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFloatingLabelField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: focusNode.hasFocus ? Colors.blueAccent : Colors.grey[600],
              fontSize: 14,
              fontWeight:
                  focusNode.hasFocus ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor:
                focusNode.hasFocus
                    ? Colors.blue[50]?.withOpacity(0.3)
                    : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    focusNode.hasFocus ? Colors.blueAccent : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16,
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: focusNode.hasFocus ? Colors.blueAccent : Colors.grey[600],
              fontSize: 14,
              fontWeight:
                  focusNode.hasFocus ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
          onChanged: (value) {
            setState(() {}); // Update the UI to show password length
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor:
                focusNode.hasFocus
                    ? Colors.blue[50]?.withOpacity(0.3)
                    : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    focusNode.hasFocus ? Colors.blueAccent : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red[600],
            ),
          ),
        ),
        if (label == "Password" && controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 16),
            child: Text(
              "Panjang password: ${controller.text.length} karakter",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color:
                    controller.text.length >= 8 ? Colors.green : Colors.orange,
              ),
            ),
          ),
      ],
    );
  }
}
