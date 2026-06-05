import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isPemilik = auth.userRole == 'pemilik';
    final userName = auth.user?["name"] ?? "User";
    final userEmail = auth.user?["email"] ?? "-";
    final userRole = auth.userRole == 'pemilik' ? "Pemilik Kost" : "Mahasiswa";

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER PROFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1E3A8A), Color(0xff3B82F6)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xff3B82F6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userRole,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  /// Menu untuk Pemilik Kost (TAMBAHAN)
                  if (isPemilik) ...[
                    _buildMenuItem(
                      context,
                      "Kost Saya",
                      Icons.home_work_rounded,
                      () {
                        // Navigasi ke halaman kelola kost
                        Navigator.pushNamed(context, '/owner-kost-list');
                      },
                    ),
                    _buildMenuItem(
                      context,
                      "Statistik Kost",
                      Icons.bar_chart_rounded,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fitur segera hadir")),
                        );
                      },
                    ),
                    const Divider(),
                  ],

                  /// Menu untuk SEMUA USER
                  _buildMenuItem(
                    context,
                    "Edit Profil",
                    Icons.edit_rounded,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur segera hadir")),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    "Ubah Password",
                    Icons.lock_rounded,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur segera hadir")),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    "Tentang Aplikasi",
                    Icons.info_rounded,
                    () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    "Logout",
                    Icons.logout_rounded,
                    () {
                      _showLogoutDialog(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xff3B82F6)),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : const Color(0xff1E293B),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tentang FindKost"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work, size: 50, color: Color(0xff3B82F6)),
            SizedBox(height: 12),
            Text(
              "FindKost v1.0.0",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Aplikasi pencari kost untuk mahasiswa Polindra",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}