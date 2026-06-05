import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kost_provider.dart';
import '../kost/kost_detail_screen.dart';
import 'mahasiswa_search_screen.dart';
import 'mahasiswa_booking_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/socket_service.dart';
import '../../services/notification_service.dart';
import '../../providers/booking_provider.dart';

class MahasiswaHomeScreen extends StatefulWidget {
  const MahasiswaHomeScreen({super.key});

  @override
  State<MahasiswaHomeScreen> createState() => _MahasiswaHomeScreenState();
}

class _MahasiswaHomeScreenState extends State<MahasiswaHomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<KostProvider>().fetchKost();
        
        // Force register socket to ensure Student is online
        final auth = context.read<AuthProvider>();
        if (auth.user != null) {
          int parsedUserId = auth.user!["id"] is int 
              ? auth.user!["id"] 
              : int.tryParse(auth.user!["id"].toString()) ?? 0;
              
          SocketService().registerUser(
            userId: parsedUserId,
            userName: auth.user!["name"] ?? "Mahasiswa",
            role: "mahasiswa",
          );
        }
        
        _setupSocketListener();
      }
    });
  }

  void _setupSocketListener() {
    SocketService().onBookingStatusUpdate = (data) async {
      print('📨 Booking status update received: $data');

      await NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Status Booking Diperbarui!',
        body: data['message'] ?? 'Status booking Anda berubah menjadi ${data['status']}',
        payload: 'booking_id:${data['bookingId']}',
      );

      if (mounted) {
        // Refresh bookings data globally
        final auth = context.read<AuthProvider>();
        final userId = auth.user?['id'];
        if (userId != null) {
          context.read<BookingProvider>().getMyBookings(int.parse(userId.toString()));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['message'] ?? 'Status booking diperbarui',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: data['status'] == 'confirmed' ? Colors.green[700] : Colors.red[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MahasiswaHomeContent(),
      const MahasiswaSearchScreen(),
      const MahasiswaBookingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Beranda",
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Cari",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Pesanan",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}

// ==================== HOME CONTENT MAHASISWA ====================
class MahasiswaHomeContent extends StatelessWidget {
  const MahasiswaHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final kostProvider = context.watch<KostProvider>();
    final userName = auth.user?["name"] ?? auth.user?["nama"] ?? "Mahasiswa";

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => kostProvider.fetchKost(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              /// HEADER WITH GRADIENT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff1E3A8A), Color(0xff3B82F6), Color(0xff60A5FA)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xff3B82F6), size: 28),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, $userName!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Temukan kost terbaikmu hari ini",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// SEARCH BAR
                    GestureDetector(
                      onTap: () {
                        final homeState = context.findAncestorStateOfType<_MahasiswaHomeScreenState>();
                        if (homeState != null) {
                          homeState.setState(() {
                            homeState.currentIndex = 1;
                          });
                        }
                      },
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(Icons.search, color: Colors.grey[400], size: 22),
                            const SizedBox(width: 8),
                            Text(
                              "Cari kost...",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                            const Spacer(),
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xff3B82F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Filter",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// REKOMENDASI KOST
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Rekomendasi Kost",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final homeState = context.findAncestorStateOfType<_MahasiswaHomeScreenState>();
                        if (homeState != null) {
                          homeState.setState(() {
                            homeState.currentIndex = 1;
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Lihat semua",
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xff3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 10, color: const Color(0xff3B82F6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              /// KOST LIST
              kostProvider.isLoading && kostProvider.kosts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : kostProvider.kosts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text("Belum ada kost")),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: kostProvider.kosts.length > 5 ? 5 : kostProvider.kosts.length,
                      itemBuilder: (context, index) {
                        final kost = kostProvider.kosts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.transparent,
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => KostDetailScreen(kost: kost),
                                    ),
                                  );
                                },
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xff3B82F6), Color(0xff60A5FA)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.home_work, color: Colors.white, size: 30),
                                ),
                                title: Text(
                                  kost.namaKost,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xff1E293B),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 12, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            kost.alamat.length > 30
                                                ? '${kost.alamat.substring(0, 30)}...'
                                                : kost.alamat,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 12, color: Colors.amber[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          "4.8",
                                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.wifi, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          "WiFi",
                                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Rp ${kost.harga}",
                                      style: const TextStyle(
                                        color: Color(0xff3B82F6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Tersedia",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}