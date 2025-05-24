// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/usulan_provider.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:perpus_flutter/models/usulan.dart';
import 'package:perpus_flutter/config/config.dart';

var logger = Logger();

class UpdateUsulan extends StatefulWidget {
  const UpdateUsulan({super.key});

  @override
  UpdateUsulanState createState() => UpdateUsulanState();
}

class UpdateUsulanState extends State<UpdateUsulan> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _judulController;
  late TextEditingController _isbnController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitController;
  late TextEditingController _tahunController;
  late String _selectedKategori;
  File? _selectedImage;
  String? _currentImageUrl;

  final List<String> _kategoriList = [
    'Self Improvement',
    'Fiksi Sejarah',
    'Puisi',
    'Sejarah',
  ];

  @override
  @override
  void initState() {
    super.initState();
    final usulanProvider = Provider.of<UsulanProvider>(context, listen: false);
    final usulan = usulanProvider.selectedUsulan;

    // Initialize controllers with selected usulan data
    _judulController = TextEditingController(text: usulan?.bookTitle ?? '');
    _isbnController = TextEditingController(text: usulan?.isbn ?? '');
    _pengarangController = TextEditingController(text: usulan?.author ?? '');
    _penerbitController = TextEditingController(text: usulan?.publisher ?? '');
    _tahunController = TextEditingController(
      text: usulan?.publicationYear.toString() ?? '',
    );
    _selectedKategori = usulan?.genre ?? _kategoriList.first;

    // Perbaikan di sini - gunakan usulanImageUrl
    String? imagePath = usulan?.bookImage;
    if (imagePath != null && imagePath.contains('usulan/usulan/')) {
      imagePath = imagePath.replaceFirst('usulan/usulan/', 'usulan/');
    }
    _currentImageUrl =
        usulan?.bookImage != null
            ? Config.fixImageUrl(usulan!.bookImage!)
            : null;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isbnController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _currentImageUrl =
              null; // Clear the current URL when new image is selected
        });
      }
    } catch (e) {
      logger.e('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
    });
  }

  Future<void> _updateBuku() async {
    if (_formKey.currentState!.validate()) {
      try {
        final usulanProvider = Provider.of<UsulanProvider>(
          context,
          listen: false,
        );
        final usulan = usulanProvider.selectedUsulan;

        if (usulan != null) {
          await usulanProvider.updateUsulan(
            usulanId: usulan.id,
            bookTitle: _judulController.text.trim(),
            genre: _selectedKategori,
            isbn: _isbnController.text.trim(),
            author: _pengarangController.text.trim(),
            publisher: _penerbitController.text.trim(),
            publicationYear: _tahunController.text.trim(),
            bookImage: _selectedImage,
            removeImage: _currentImageUrl == null && _selectedImage == null,
          );

          // Tambahkan ini untuk memuat ulang data
          await usulanProvider.fetchRiwayatUsulan();

          if (usulanProvider.success) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usulan berhasil diperbarui')),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        logger.e('Error updating usulan: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usulanProvider = Provider.of<UsulanProvider>(context);
    logger.i("Current image URL in build: $_currentImageUrl");
    logger.i("Selected image: $_selectedImage");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Usulan Buku'),
        actions: [
          if (usulanProvider.selectedUsulan != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body:
          usulanProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Image Section
                        _buildImageSection(),
                        const SizedBox(height: 20),
                        // Form Fields
                        _buildTextField('Judul buku', _judulController),
                        _buildTextField(
                          'ISBN',
                          _isbnController,
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                        ),
                        _buildDropdownField(),
                        _buildTextField('Pengarang', _pengarangController),
                        _buildTextField('Penerbit', _penerbitController),
                        _buildTextField(
                          'Tahun terbit',
                          _tahunController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              usulanProvider.isLoading ? null : _updateBuku,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child:
                              usulanProvider.isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text('Update'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (_currentImageUrl != null || _selectedImage != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: Stack(
              children: [
                Center(
                  child:
                      _selectedImage != null
                          ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImageErrorWidget();
                            },
                          )
                          : _currentImageUrl != null
                          ? Image.network(
                            _currentImageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImageErrorWidget();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          )
                          : _buildPlaceholderImage(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeImage,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        // Tombol Pilih Gambar - bagian yang sebelumnya dikomentari
        OutlinedButton(
          onPressed: _pickImage,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: Colors.blue.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Pilih Gambar'),
            ],
          ),
        ),
      ],
    );
  }

  // Widget tambahan untuk error handling
  Widget _buildImageErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image, size: 50, color: Colors.red),
        const SizedBox(height: 8),
        Text(
          'Gagal memuat gambar',
          style: TextStyle(color: Colors.red[700], fontSize: 12),
        ),
      ],
    );
  }

  // Widget tambahan untuk placeholder
  Widget _buildPlaceholderImage() {
    return const Icon(Icons.image, size: 50, color: Colors.grey);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedKategori,
        decoration: InputDecoration(
          labelText: 'Kategori',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedKategori = newValue!;
          });
        },
        items:
            _kategoriList
                .map(
                  (kategori) =>
                      DropdownMenuItem(value: kategori, child: Text(kategori)),
                )
                .toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Pilih kategori';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final usulanProvider = Provider.of<UsulanProvider>(context, listen: false);
    final usulan = usulanProvider.selectedUsulan;

    if (usulan == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Usulan'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus usulan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await usulanProvider.deleteUsulan(usulan.id);
        if (usulanProvider.success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usulan berhasil dihapus')),
          );
          Navigator.pop(context, true);
        } else if (usulanProvider.errorMessage != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(usulanProvider.errorMessage!)));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
        );
      }
    }
  }
}
