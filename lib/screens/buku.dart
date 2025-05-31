import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/components/bottom_nav_screen.dart';
import 'package:perpus_flutter/components/book_card.dart';
import 'package:perpus_flutter/components/app_bar.dart';
import 'package:perpus_flutter/providers/book_provider.dart';

class BukuScreen extends StatefulWidget {
  const BukuScreen({super.key});

  @override
  State<BukuScreen> createState() => _BukuScreenState();
}

class _BukuScreenState extends State<BukuScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BookProvider>(context, listen: false);
    provider.loadBooksFromCache(); // tampilkan cache dulu
    Future.microtask(() => provider.fetchBooks()); // lalu fetch ke backend
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8),
                child: const Text(
                  'Koleksi Buku',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<BookProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (provider.errorMessage != null) {
                      return Center(child: Text(provider.errorMessage!));
                    } else if (provider.books.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada buku tersedia.'),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await Provider.of<BookProvider>(
                            context,
                            listen: false,
                          ).fetchBooks();
                        },
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 20,
                          children:
                              bookProvider.books
                                  .map(
                                    (book) => BookCard(book: book),
                                  ) // Menggunakan objek Book
                                  .toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavComponent(
        selectedIndex: 1,
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
