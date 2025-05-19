import 'package:flutter/material.dart';

class VisiMisiTab extends StatelessWidget {
  const VisiMisiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Visi Misi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Visi:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                '"TERWUJUDNYA LEMBAGA PERPUSTAKAAN DAERAH DAN KEARSIPAN DAERAH YANG UNGGUL PADA TAHUN 2026"',
                textAlign: TextAlign.justify,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Text(
                'Misi:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                '1. Meningkatkan Sumber Daya Manusia Pengelola Arsip dan Pengelola Perpustakaan;\n'
                '2. Meningkatkan Koordinasi Pengelolaan Arsip dan Pengelolaan Perpustakaan;\n'
                '3. Meningkatkan Kebermanfaatan Arsip untuk SKPD;\n'
                '4. Meningkatkan Sarana dan Prasarana Kearsipan dan Perpustakaan;\n'
                '5. Meningkatkan Fungsi dan Tanggungjawab Kearsipan Statis;\n'
                '6. Meningkatkan Kompetensi Sumber Daya Manusia Perpustakaan;\n'
                '7. Meningkatkan Sarana Prasarana Perpustakaan;\n'
                '8. Meningkatkan Pelayanan Kearsipan dan Perpustakaan;\n'
                '9. Meningkatkan Pembinaan terhadap Perpustakaan;\n'
                '10. Mengembangkan Minat, Gemar dan Budaya Membaca.',
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
