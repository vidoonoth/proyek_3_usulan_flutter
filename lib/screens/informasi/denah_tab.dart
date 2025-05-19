import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DenahTab extends StatelessWidget {
  const DenahTab({super.key});

  final String mapUrl =
      'https://www.google.com/maps/place/Dinas+Perpustakaan+dan+Arsip+Kabupaten+Indramayu/@-6.3294135,108.3169018,17z/data=!3m1!4b1!4m6!3m5!1s0x2e6eb959b97b9975:0x56b333828a7c4ce8!8m2!3d-6.3294135!4d108.3194767!16s%2Fg%2F1pzqfgtzy?entry=ttu';

  final String thumbnailUrl =
      'https://lh3.googleusercontent.com/gps-cs-s/AC9h4no2DKAyrbIVDBHPwfC7EpSsPH6d8yXMXFFrUsVxcwp_yh_gglehstQ4uZTBFT5qYX1FObgvBdWIDmYPjZdTWh_HB1iAOFVtA4_I_DvdKRvDZ6aCFiAOdbczhEOMhLDtZLJY7o4=s1016-k-no';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Denah & Lokasi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbnailUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.map, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Jl. Mt Haryono No.49, Penganjang, Sindang, Kabupaten Indramayu, Jawa Barat 45222.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            alignment: Alignment(1, 1),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse(mapUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak dapat membuka Google Maps'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                label: const Text('Buka di Google Maps'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ), // tinggi tombol
                  backgroundColor: Color(0xFF60A5FA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
