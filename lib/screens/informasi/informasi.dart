import 'package:flutter/material.dart';
import 'package:perpus_flutter/components/app_bar.dart';
import 'package:perpus_flutter/components/bottom_nav_screen.dart';
import 'sejarah_tab.dart';
import 'visi_misi_tab.dart';
import 'denah_tab.dart';

class Informasi extends StatefulWidget {
  const Informasi({super.key});

  @override
  State<Informasi> createState() => _InformasiState();
}

class _InformasiState extends State<Informasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        tabController: _tabController,
        tabs: const [
          Tab(text: 'Sejarah'),
          Tab(text: 'Visi Misi'),
          Tab(text: 'Denah'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SejarahTab(),
          VisiMisiTab(),
          DenahTab(),
        ],
      ),
      bottomNavigationBar: BottomNavComponent(
        selectedIndex: 3,
        onItemTapped: (index) {
          final routes = [
            '/dashboard',
            '/buku',
            '/riwayatUsulan',
            '/informasi',
            '/profil',
          ];
          Navigator.pushReplacementNamed(context, routes[index]);
        },
      ),
    );
  }
}
