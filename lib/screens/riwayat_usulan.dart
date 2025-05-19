import 'package:flutter/material.dart';
import 'package:perpus_flutter/components/app_bar.dart';
import 'package:perpus_flutter/components/bottom_nav_screen.dart';
import 'package:perpus_flutter/screens/usulan.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/usulan_provider.dart';

class RiwayatUsulan extends StatefulWidget {
  const RiwayatUsulan({super.key});

  @override
  State<RiwayatUsulan> createState() => _RiwayatUsulanState();
}

class _RiwayatUsulanState extends State<RiwayatUsulan> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsulanProvider>(context, listen: false).fetchRiwayatUsulan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usulanProvider = Provider.of<UsulanProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            // LIST VIEW
            Container(
              // padding: const EdgeInsets.only(top: 72),              
              child:
                  usulanProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : usulanProvider.riwayatUsulan.isEmpty
                      ? const Center(child: Text('Tidak ada data usulan.'))
                      : RefreshIndicator(
                        onRefresh: () async {
                          await Provider.of<UsulanProvider>(
                            context,
                            listen: false,
                          ).fetchRiwayatUsulan();
                        },
                        child: ListView.builder(                          
                          padding: EdgeInsets.only(top: 80, left: 16, right: 16),
                          itemCount: usulanProvider.riwayatUsulan.length,
                          itemBuilder: (context, index) {
                            final usulan = usulanProvider.riwayatUsulan[index];
                            return Card(
                              color: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              usulan.bookImage != null
                                                  ? Image.network(
                                                    'http://192.168.1.15:8000/storage/${usulan.bookImage}',
                                                    height: 110,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    height: 110,
                                                    width: 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.book,
                                                      size: 40,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Judul : ${usulan.bookTitle}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text("ISBN : ${usulan.isbn}"),
                                              Text(
                                                "Pengarang : ${usulan.author}",
                                              ),
                                              Text(
                                                "Kategori : ${usulan.genre}",
                                              ),
                                              Text(
                                                "Tanggal usulan : ${usulan.date}",
                                              ),
                                              // Text("Status : ${usulan.status}"),
                                              Text("Status : diproses"),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),

            // FLOATING SEARCH BAR (opsional, belum aktif)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari usulan ...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    Provider.of<UsulanProvider>(
                      context,
                      listen: false,
                    ).fetchRiwayatUsulan();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Usulan()),
          );
        },
        label: const Text(
          'Tambah Usulan',
          style: TextStyle(color: Color(0xFFF1F5F9)),
        ),
        icon: const Icon(Icons.add, color: Color(0xFFF1F5F9)),
        backgroundColor: Colors.blue[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      bottomNavigationBar: BottomNavComponent(
        selectedIndex: 2,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/buku');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/riwayatUsulan');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/informasi');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }
}
