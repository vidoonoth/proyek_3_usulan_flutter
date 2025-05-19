import 'package:flutter/material.dart';

class EditProfil extends StatelessWidget {
  const EditProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF60A5FA),
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
                      backgroundColor: Color(0xFFF8FAFC),
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
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/alfin.jpg'),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
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
                      spacing: 5,
                      children: [
                        _buildTextField("Username", "Gracia"),
                        _buildTextField("Nama lengkap", "Gracia Victory"),
                        _buildTextField("Nik", "45393429319931311"),
                        _buildTextField("Nomor telepon", "08393429319931311"),
                        _buildTextField("Jenis kelamin", "Perempuan"),
                        _buildTextField("Password", "xxxxxxxxxxxx"),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF60A5FA),
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

  Widget _buildTextField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(246, 0, 0, 0)),
          hintText: initialValue,
          filled: true,
          fillColor: Colors.blueGrey[50], // slate50
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueGrey[100]!,
            ), // slate100 border
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
}
