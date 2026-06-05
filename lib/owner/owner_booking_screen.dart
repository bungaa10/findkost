import 'package:flutter/material.dart';
import 'package:providers/provider.dart';
import '../../services/socket_service.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';

class OwnerBookingScreen extends StatefulWidget {
  const OwnerBookingScreen({super.key});

  @override
  State<OwnerBookingScreen> createState() => _OwnerBookingScreenState();
}

class _OwnerBookingScreenState extends State<OwnerBookingScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupSocketListener();
    _loadBookings();
  }

  void _setupSocketListener() {
    // Setup listener notifikasi booking dari Socket.IO
    SocketService().onBookingNotification = (data) async {
      print('📨 Booking notification received: $data');
      
      // Tampilkan notifikasi lokal di HP
      await NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '📢 Booking Baru!',
        body: '${data['studentName']} memesan ${data['kostName']}',
        payload: 'booking_id:${data['bookingId']}',
      );
      
      // Refresh list booking
      _loadBookings();
      
      // Tampilkan snackbar jika halaman sedang terbuka
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Booking baru dari ${data['studentName']} untuk ${data['kostName']}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    };
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ownerId = authProvider.user?['id'];
      
      if (ownerId == null) {
        setState(() {
          _errorMessage = 'User tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      // TODO: Panggil API get bookings untuk pemilik
      // final response = await ApiService.get('bookings/owner.php?owner_id=$ownerId');
      // _bookings = List<Map<String, dynamic>>.from(response['data']);
      
      // Data dummy untuk testing (hapus setelah API jadi)
      await Future.delayed(const Duration(seconds: 1));
      _bookings = [
        {
          'id': 1,
          'kost_id': 1,
          'kost_name': 'Kost Indah Permata',
          'student_name': 'Bunga Arini',
          'student_email': 'bunga@example.com',
          'duration': 6,
          'total_price': 5100000,
          'check_in_date': '2026-06-15',
          'note': 'Saya mahasiswa baru, mohon bantuannya',
          'status': 'pending',
          'created_at': '2026-06-01 10:30:00',
        },
        {
          'id': 2,
          'kost_id': 2,
          'kost_name': 'Kost Mawar Berseri',
          'student_name': 'Akbar Maulana',
          'student_email': 'akbar@example.com',
          'duration': 12,
          'total_price': 9000000,
          'check_in_date': '2026-07-01',
          'note': '',
          'status': 'pending',
          'created_at': '2026-06-02 09:15:00',
        },
      ];
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat booking: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookingStatus(int bookingId, String newStatus) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // TODO: Panggil API update status booking
      // final response = await ApiService.post('bookings/update_status.php', {
      //   'booking_id': bookingId,
      //   'status': newStatus,
      // });
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local list
      setState(() {
        final index = _bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          _bookings[index]['status'] = newStatus;
        }
      });
      
      // Kirim notifikasi ke mahasiswa via Socket
      // SocketService().sendBookingStatusUpdate(
      //   bookingId: bookingId,
      //   studentId: studentId,
      //   status: newStatus,
      //   message: newStatus == 'diterima' 
      //       ? 'Booking Anda telah diterima!' 
      //       : 'Mohon maaf, booking Anda ditolak.',
      // );
      
      if (mounted) {
        Navigator.pop(context); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking berhasil di${newStatus == 'diterima' ? 'terima' : 'tolak'}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBookingDetail(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xff3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long, color: Color(0xff3B82F6), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['kost_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Booking ID: #${booking['id']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(booking['status']),
              ],
            ),
            const Divider(height: 30),
            _detailRow('Nama Mahasiswa', booking['student_name']),
            _detailRow('Email', booking['student_email']),
            _detailRow('Tanggal Masuk', booking['check_in_date']),
            _detailRow('Durasi Sewa', '${booking['duration']} bulan'),
            _detailRow('Total Harga', 'Rp ${booking['total_price'].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}'),
            _detailRow('Tanggal Booking', booking['created_at']),
            if (booking['note'].isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Catatan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['note'],
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (booking['status'] == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateBookingStatus(booking['id'], 'diterima');
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Terima'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateBookingStatus(booking['id'], 'ditolak');
                      },
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Tolak'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (booking['status'] == 'diterima') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Booking telah diterima. Silakan hubungi mahasiswa untuk konfirmasi lebih lanjut.',
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (booking['status'] == 'ditolak') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Booking telah ditolak.',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'diterima':
        color = Colors.green;
        label = 'Diterima';
        break;
      case 'ditolak':
        color = Colors.red;
        label = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Pesanan Masuk",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Memuat pesanan..."),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBookings,
                        child: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                )
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
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
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showBookingDetail(booking),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xff3B82F6).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.home_work,
                                              color: Color(0xff3B82F6),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  booking['kost_name'],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${booking['student_name']} • ${booking['duration']} bulan',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildStatusBadge(booking['status']),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Masuk: ${booking['check_in_date']}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Rp ${booking['total_price'].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff3B82F6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}