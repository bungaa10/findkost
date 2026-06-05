import 'package:findkost/screens/booking/booking_screen.dart';
import 'package:findkost/screens/mahasiswa/mahasiswa_booking_screen.dart';
import 'package:flutter/material.dart';
import '../../models/kost_model.dart';

class KostDetailScreen extends StatelessWidget {
  final KostModel kost;

  const KostDetailScreen({super.key, required this.kost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: CustomScrollView(
        slivers: [
          /// HEADER IMAGE DENGAN SLIVER APP BAR
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xff3B82F6),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff60A5FA),
                      Color(0xff1E3A8A),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_work,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ditambahkan ke favorit')),
                  );
                },
              ),
            ],
          ),

          /// KONTEN DETAIL
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xffF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAMA KOST & STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          kost.namaKost,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E293B),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: kost.kategori == 'Pria' ? Colors.blue.withOpacity(0.1) : kost.kategori == 'Wanita' ? Colors.pink.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Kost ${kost.kategori}",
                              style: TextStyle(
                                color: kost.kategori == 'Pria' ? Colors.blue : kost.kategori == 'Wanita' ? Colors.pink : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Tersedia",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// ALAMAT
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xff3B82F6), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          kost.alamat,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// HARGA CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Harga Sewa",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${kost.harga}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3B82F6),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "/ bulan",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// FASILITAS
                  const Text(
                    "Fasilitas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(
                      kost.fasilitas.isEmpty
                          ? "Belum ada informasi fasilitas."
                          : kost.fasilitas,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// DESKRIPSI
                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kost.deskripsi.isEmpty
                        ? "Tidak ada deskripsi untuk kost ini."
                        : kost.deskripsi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 100), // Spasi bawah untuk tombol
                ],
              ),
            ),
          ),
        ],
      ),

      /// BOTTOM ACTION BAR (Booking)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff3B82F6)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: const Color(0xff3B82F6),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur chat belum tersedia')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(
                            kostId: kost.id ?? 0,
                            namaKost: kost.namaKost,
                            harga: kost.harga,
                            alamat: kost.alamat,
                          ), // Arahkan ke screen booking
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Pesan Sekarang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
