import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?['id'];
    
    if (userId != null) {
      await Provider.of<BookingProvider>(context, listen: false)
          .getMyBookings(int.parse(userId.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Booking Saya"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.myBookings.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada booking', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.myBookings.length,
                    itemBuilder: (context, index) {
                      final booking = provider.myBookings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: booking.statusColor.withOpacity(0.1),
                            child: Icon(Icons.home, color: booking.statusColor),
                          ),
                          title: Text(booking.kostName),
                          subtitle: Text('${booking.durasiBulan} bulan • ${booking.formattedTotalHarga}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: booking.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.statusText,
                              style: TextStyle(color: booking.statusColor, fontSize: 11),
                            ),
                          ),
                          onTap: () => _showDetailDialog(booking),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showDetailDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking.kostName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Status', booking.statusText),
            _detailRow('Durasi', '${booking.durasiBulan} bulan'),
            _detailRow('Total', booking.formattedTotalHarga),
            _detailRow('Tanggal Masuk', '${booking.tanggalMasuk.day}/${booking.tanggalMasuk.month}/${booking.tanggalMasuk.year}'),
            if (booking.catatan != null && booking.catatan!.isNotEmpty)
              _detailRow('Catatan', booking.catatan!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}