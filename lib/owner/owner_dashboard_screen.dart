import 'package:findkost/screens/kost/kost_detail_screen.dart';
import 'package:findkost/screens/kost/kost_form_screen.dart';
import 'package:findkost/screens/kost/kost_list_screen.dart';
import 'package:findkost/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kost_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<KostProvider>().fetchKost();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OwnerHomeContent(),
      const KostListScreen(),
      const OwnerBookingScreen(),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: "Kost Saya",
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

// ==================== DASHBOARD PEMILIK ====================
class OwnerHomeContent extends StatelessWidget {
  const OwnerHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final kostProvider = context.watch<KostProvider>();
    final userName = auth.user?["name"] ?? auth.user?["nama"] ?? "Pemilik";

    final totalKost = kostProvider.kosts.length;
    final totalTersedia = kostProvider.kosts.length;
    final totalBooking = 0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => kostProvider.fetchKost(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ✅ SLIVER APP BAR - FULL KE ATAS
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              floating: false,
              backgroundColor: const Color(0xff1E3A8A),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff1E3A8A),
                        Color(0xff3B82F6),
                        Color(0xff60A5FA),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.business,
                                    color: Color(0xff3B82F6),
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Halo, $userName! 👋",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Pemilik Kost",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // STATISTIK CARD
                          Row(
                            children: [
                              _statCard(
                                "Total Kost",
                                totalKost.toString(),
                                Icons.home_work_rounded,
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _statCard(
                                "Tersedia",
                                totalTersedia.toString(),
                                Icons.check_circle_rounded,
                                Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _statCard(
                                "Pesanan",
                                totalBooking.toString(),
                                Icons.receipt_long_rounded,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // CONTENT - MENU CEPAT & KOST LIST
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Menu Cepat",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _menuCard(
                                context,
                                "Tambah Kost",
                                Icons.add_home_rounded,
                                Colors.blue,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const KostFormScreen(),
                                    ),
                                  ).then(
                                    (_) => context
                                        .read<KostProvider>()
                                        .fetchKost(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _menuCard(
                                context,
                                "Kelola Kost",
                                Icons.edit_rounded,
                                Colors.green,
                                () {
                                  final dashboardState = context
                                      .findAncestorStateOfType<
                                        _OwnerDashboardScreenState
                                      >();
                                  if (dashboardState != null) {
                                    dashboardState.setState(() {
                                      dashboardState.currentIndex = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _menuCard(
                                context,
                                "Lihat Pesanan",
                                Icons.receipt_long_rounded,
                                Colors.orange,
                                () {
                                  final dashboardState = context
                                      .findAncestorStateOfType<
                                        _OwnerDashboardScreenState
                                      >();
                                  if (dashboardState != null) {
                                    dashboardState.setState(() {
                                      dashboardState.currentIndex = 2;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Kost Terbaru",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E293B),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final dashboardState = context
                                .findAncestorStateOfType<
                                  _OwnerDashboardScreenState
                                >();
                            if (dashboardState != null) {
                              dashboardState.setState(() {
                                dashboardState.currentIndex = 1;
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
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: const Color(0xff3B82F6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // KOST LIST
            kostProvider.isLoading && kostProvider.kosts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : kostProvider.kosts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          "Belum ada kost. Tambahkan kost pertama Anda!",
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >=
                            (kostProvider.kosts.length > 5
                                ? 5
                                : kostProvider.kosts.length))
                          return null;
                        final kost = kostProvider.kosts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                        builder: (_) =>
                                            KostDetailScreen(kost: kost),
                                      ),
                                    );
                                  },
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff3B82F6),
                                          Color(0xff60A5FA),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.home_work,
                                      color: Colors.white,
                                      size: 30,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              kost.alamat.length > 30
                                                  ? '${kost.alamat.substring(0, 30)}...'
                                                  : kost.alamat,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "Rp ${kost.harga}",
                                    style: const TextStyle(
                                      color: Color(0xff3B82F6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: kostProvider.kosts.length > 5
                          ? 5
                          : kostProvider.kosts.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HALAMAN PESANAN PEMILIK ====================
class OwnerBookingScreen extends StatelessWidget {
  const OwnerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum ada pesanan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Pesanan dari mahasiswa akan muncul di sini",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
