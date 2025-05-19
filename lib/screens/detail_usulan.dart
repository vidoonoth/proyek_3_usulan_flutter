import 'package:flutter/material.dart';

class DetailUsulan extends StatelessWidget {
  const DetailUsulan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "detail usulan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12),
        //     child: TextButton(
        //       onPressed: () {
        //         // aksi hapus
        //       },
        //       style: TextButton.styleFrom(
        //         backgroundColor: Colors.red[300],
        //         foregroundColor: Colors.white,
        //         padding: const EdgeInsets.symmetric(horizontal: 16),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //       ),
        //       child: const Text("hapus"),
        //     ),
        //   ),
        // ],
      
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/book_images/laut_bercerita.jpg',
                    width: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Detail informasi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InfoRow(label: "ISBN", value: "20836664337821"),
                const InfoRow(label: "Pengarang", value: "Leila S. Chudori"),
                const InfoRow(label: "Penerbit", value: "Gramedia"),
                const InfoRow(label: "Tahun terbit", value: "2019"),
                const InfoRow(label: "Kategori", value: "fiksi"),
                const InfoRow(label: "Tanggal usulan", value: "12 feb 2025"),
                const InfoRow(label: "Judul", value: "Laut Bercerita"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: "$label : ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
