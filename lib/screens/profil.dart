import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpus_flutter/components/bottom_nav_screen.dart';
import 'package:perpus_flutter/components/app_bar.dart';
import 'package:perpus_flutter/providers/user_provider.dart';
import 'edit_profil.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  void initState() {
    super.initState();
    // Ambil data user setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.isLoading &&
                    (userProvider.username == null ||
                        userProvider.username!.isEmpty)) {
                  return Center(child: CircularProgressIndicator());
                }
                return Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child:
                          userProvider.profileImage != null
                              ? ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/avatar_placeholder.png',
                                  image: userProvider.profileImage!,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                          Icon(Icons.error),
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.username ?? '-',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Bergabung pada ${userProvider.joinedAt ?? '-'}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (userProvider.isLoading &&
                      (userProvider.username == null || userProvider.username!.isEmpty)) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: [
                      _buildInfoRow("Nama lengkap", userProvider.name ?? '-'),
                      _buildInfoRow("Email", userProvider.email ?? '-'),
                      _buildInfoRow("NIK", userProvider.nik ?? '-'),
                      _buildInfoRow("Nomor telepon", userProvider.numberphone ?? '-'),
                      _buildInfoRow("Jenis kelamin", userProvider.gender ?? '-'),
                      SizedBox(height: 30),
                      // Pisahkan tombol dari loading
                      _ActionButtons(
                        userProvider: userProvider,
                        logout: _logout,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavComponent(
        selectedIndex: 4,
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

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Widget tombol aksi dipisah
class _ActionButtons extends StatelessWidget {
  final UserProvider userProvider;
  final VoidCallback logout;
  const _ActionButtons({required this.userProvider, required this.logout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EditProfil(
                      userData: {
                        'username': userProvider.username,
                        'name': userProvider.name,
                        'email': userProvider.email,
                        'nik': userProvider.nik,
                        'numberphone': userProvider.numberphone,
                        'gender': userProvider.gender,
                        'profile_image_url': userProvider.profileImage, // <-- Tambahkan ini
                      },
                    ),
              ),
            );
          },
          icon: Icon(Icons.edit, color: Colors.white),
          label: Text("edit", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text("atau", style: TextStyle(color: Colors.black)),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: logout,
          icon: Icon(Icons.exit_to_app, color: Colors.white),
          label: Text("keluar", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ],
    );
  }
}
