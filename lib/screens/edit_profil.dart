import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/user_provider.dart';

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
    if (_usernameController.text.isNotEmpty) updateData['username'] = _usernameController.text;
    if (_nameController.text.isNotEmpty) updateData['name'] = _nameController.text;
    if (_emailController.text.isNotEmpty) updateData['email'] = _emailController.text;
    if (_nikController.text.isNotEmpty) updateData['nik'] = _nikController.text;
    if (_phoneController.text.isNotEmpty) updateData['numberphone'] = _phoneController.text;
    if (_gender != null && _gender!.isNotEmpty) updateData['gender'] = _gender;
    if (_passwordController.text.isNotEmpty) updateData['password'] = _passwordController.text;

    bool success;
    if (_selectedImage != null) {
      success = await userProvider.updateProfileWithImage(updateData, _selectedImage!);
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
        const SnackBar(
          content: Text('Gagal memperbarui profil'),
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

            // Foto Profil
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (widget.userData['profile_image_url'] != null
                          ? NetworkImage(widget.userData['profile_image_url'])
                          : null) as ImageProvider?,
                  child: (_selectedImage == null && widget.userData['profile_image_url'] == null)
                      ? Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF60A5FA),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Form Scrollable
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
                        _buildTextField("Username", _usernameController),
                        _buildTextField("Nama lengkap", _nameController),
                        _buildTextField("Email", _emailController),
                        _buildTextFieldWithValidation(
                          "NIK",
                          _nikController,
                          errorText: _nikError,
                          maxLength: 16,
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextFieldWithValidation(
                          "Nomor telepon",
                          _phoneController,
                          errorText: _phoneError,
                          maxLength: 13,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildGenderDropdown(),
                        _buildTextField(
                          "Password (kosongkan jika tidak ingin mengubah)",
                          _passwordController,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(246, 0, 0, 0)),
          filled: true,
          fillColor: Colors.blueGrey[50],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey[100]!),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey[200]!),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithValidation(
    String label,
    TextEditingController controller, {
    String? errorText,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color.fromARGB(246, 0, 0, 0)),
              filled: true,
              fillColor: Colors.blueGrey[50],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey[100]!),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey[200]!),
                borderRadius: BorderRadius.circular(15),
              ),
              errorText: errorText,
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Jenis Kelamin",
            style: TextStyle(
              fontSize: 12,
              color: Color.fromARGB(246, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blueGrey[100]!),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              underline: const SizedBox(),
              items: <String>['Laki-laki', 'Perempuan']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension NumericValidation on String {
  bool isNumeric() {
    return double.tryParse(this) != null;
  }
}