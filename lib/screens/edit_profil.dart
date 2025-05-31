import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/user_provider.dart';
import 'package:perpus_flutter/widgets/custom_text_field.dart';
import 'package:perpus_flutter/widgets/custom_text_field_validation.dart';
import 'package:perpus_flutter/widgets/gender_dropdown.dart';
import 'package:perpus_flutter/widgets/profile_image_picker.dart';

class EditProfil extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfil({super.key, required this.userData});

  @override
  EditProfilState createState() => EditProfilState();
}

class EditProfilState extends State<EditProfil> {
  late TextEditingController _usernameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nikController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  String? _gender;
  String? _nikError;
  String? _phoneError;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.userData['username'] ?? '',
    );
    _nameController = TextEditingController(
      text: widget.userData['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _nikController = TextEditingController(text: widget.userData['nik'] ?? '');
    _phoneController = TextEditingController(
      text: widget.userData['numberphone'] ?? '',
    );
    // Perbaiki inisialisasi _gender agar selalu valid
    final gender = widget.userData['gender']?.toString().toLowerCase();
    if (gender == 'perempuan') {
      _gender = 'Perempuan';
    } else {
      _gender = 'Laki-laki';
    }
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool isValid = true;

    // Validate NIK (must be 16 digits)
    if (_nikController.text.length != 16 || !_nikController.text.isNumeric()) {
      setState(() {
        _nikError = 'NIK harus 16 digit angka';
      });
      isValid = false;
    } else {
      setState(() {
        _nikError = null;
      });
    }

    // Validate Phone Number (must be 13 digits)
    if (_phoneController.text.length != 13 ||
        !_phoneController.text.isNumeric()) {
      setState(() {
        _phoneError = 'Nomor telepon harus 13 digit angka';
      });
      isValid = false;
    } else {
      setState(() {
        _phoneError = null;
      });
    }

    return isValid;
  }

  Future<void> _saveProfile() async {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan perbaiki data yang invalid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updateData = <String, dynamic>{};
    if (_usernameController.text.isNotEmpty)
      updateData['username'] = _usernameController.text;
    if (_nameController.text.isNotEmpty)
      updateData['name'] = _nameController.text;
    if (_emailController.text.isNotEmpty)
      updateData['email'] = _emailController.text;
    if (_nikController.text.isNotEmpty) updateData['nik'] = _nikController.text;
    if (_phoneController.text.isNotEmpty)
      updateData['numberphone'] = _phoneController.text;
    if (_gender != null && _gender!.isNotEmpty) updateData['gender'] = _gender;
    if (_passwordController.text.isNotEmpty)
      updateData['password'] = _passwordController.text;

    bool success;

    // Jika gambar dihapus (ada gambar sebelumnya tapi tidak ada gambar baru yang dipilih)
    bool shouldRemoveImage =
        widget.userData['profile_image_url'] != null && _selectedImage == null;

    // Jika ada gambar baru
    bool hasNewImage = _selectedImage != null;

    if (hasNewImage || shouldRemoveImage) {
      success = await userProvider.updateProfileWithImage(
        updateData,
        imageFile: _selectedImage,
        removeImage: shouldRemoveImage,
      );
    } else {
      success = await userProvider.updateProfile(updateData);
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProvider.errorMessage ?? 'Gagal memperbarui profil',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF60A5FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Kustom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "batal",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "edit profil",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 65),
                ],
              ),
            ),
            ProfileImagePicker(
              selectedImage: _selectedImage,
              imageUrl: widget.userData['profile_image_url'],
              onPickImage: _pickImage,
              onRemoveImage: () {
                setState(() {
                  _selectedImage = null;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: "Username",
                          controller: _usernameController,
                        ),
                        CustomTextField(
                          label: "Nama lengkap",
                          controller: _nameController,
                        ),
                        CustomTextField(
                          label: "Email",
                          controller: _emailController,
                        ),
                        CustomTextFieldValidation(
                          label: "NIK",
                          controller: _nikController,
                          errorText: _nikError,
                          maxLength: 16,
                          keyboardType: TextInputType.number,
                        ),
                        CustomTextFieldValidation(
                          label: "Nomor telepon",
                          controller: _phoneController,
                          errorText: _phoneError,
                          maxLength: 13,
                          keyboardType: TextInputType.phone,
                        ),
                        GenderDropdown(
                          value: _gender,
                          onChanged: (val) {
                            setState(() {
                              _gender = val;
                            });
                          },
                        ),
                        CustomTextField(
                          label: "Password (kosongkan jika tidak ingin mengubah)",
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF60A5FA),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 130,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "simpan",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
