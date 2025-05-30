import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usulan_provider.dart';
import 'package:perpus_flutter/config/config.dart';

class DetailUsulan extends StatelessWidget {
  const DetailUsulan({super.key});

  @override
  Widget build(BuildContext context) {
    final usulan = Provider.of<UsulanProvider>(context).selectedUsulan;

    if (usulan == null) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada data usulan yang dipilih")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 56, right: 20, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            usulan.bookImage != null &&
                                    usulan.bookImage!.isNotEmpty
                                ? Image.network(
                                  Config.fixImageUrl(usulan.bookImage!),
                                  height: 320,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 120,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                                : const Icon(
                                  Icons.image,
                                  size: 120,
                                  color: Colors.grey,
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InfoText(label: "Judul", value: usulan.bookTitle),
                    InfoText(label: "ISBN", value: usulan.isbn),
                    InfoText(label: "Pengarang", value: usulan.author),
                    InfoText(label: "Penerbit", value: usulan.publisher),
                    InfoText(
                      label: "Tahun terbit",
                      value: usulan.publicationYear.toString(),
                    ),
                    InfoText(label: "Kategori", value: usulan.genre),
                    InfoText(label: "Tanggal usulan", value: usulan.date),
                    // InfoText dengan status berwarna
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status : ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(usulan.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              usulan.status,
                              style: const TextStyle(
                                color: Colors.white,
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

              // Tombol kembali
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),           
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menentukan warna berdasarkan status
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.blue;
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class InfoText extends StatelessWidget {
  final String label;
  final String value;

  const InfoText({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            text: '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
