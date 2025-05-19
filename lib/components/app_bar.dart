import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? tabController;
  final List<Tab>? tabs;

  const CustomAppBar({super.key, this.tabController, this.tabs});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF8FAFC),
      elevation: 0,
      title: _buildAppBarTitle(),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.blue, size: 30),
          onPressed: () {
            // Tambahkan aksi notifikasi di sini
            Navigator.pushNamed(context, '/notifikasi');
          },
        ),
      ],
      bottom:
          (tabController != null && tabs != null)
              ? TabBar(
                labelColor: Color(0xFF60A5FA), // Warna teks tab aktif
                unselectedLabelColor: Colors.grey, // Warna teks tab tidak aktif
                indicatorColor: Color(0xFF60A5FA),
                controller: tabController,
                tabs: tabs!,
              )
              : null, // TabBar hanya muncul jika diberikan
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        SvgPicture.asset('assets/perpus_logo.svg', width: 45, height: 45),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perpustakaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            Text(
              'Indramayu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight +
          (tabs != null
              ? 48.0
              : 0.0), // Menyesuaikan tinggi saat TabBar ada/tidak
    );
  }
}
