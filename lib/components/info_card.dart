import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final Color backgroundColor;
  final double iconSize;
  final String? buttonText; // Tambahkan opsi untuk teks tombol
  final VoidCallback? onButtonPressed; // Opsional
  final bool iconOnLeft; // Properti baru untuk menentukan posisi icon

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    this.backgroundColor = const Color(0xFF2196F3),
    this.iconSize = 80,
    this.buttonText, // Jika tidak diisi, tombol tidak muncul
    this.onButtonPressed, // Opsional
    this.iconOnLeft = false, // default: icon di kanan
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: iconOnLeft
                ? [
                    SvgPicture.asset(iconPath, width: 100, height: 100),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    SvgPicture.asset(iconPath, width: 100, height: 100),
                  ],
          ),
          if (buttonText != null) ...[ // Jika buttonText ada, tampilkan tombol
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onButtonPressed ?? () {}, // Jika tidak diisi, tetap bisa diklik
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: backgroundColor,
                minimumSize: Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}
