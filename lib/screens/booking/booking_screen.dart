import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kost_provider.dart';
import '../../services/socket_service.dart';
import '../../services/notification_service.dart';

class BookingScreen extends StatefulWidget {
  final int kostId;
  final String namaKost;
  final int harga;
  final String alamat;

  const BookingScreen({
    super.key,
    required this.kostId,
    required this.namaKost,
    required this.harga,
    required this.alamat,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // State untuk form
  int _selectedDuration = 1; // 1, 6, 12 bulan
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  // State untuk chip
  bool _isSelected1Bulan = true;
  bool _isSelected6Bulan = false;
  bool _isSelected1Tahun = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xff1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateDuration(int months) {
    setState(() {
      _selectedDuration = months;
      _isSelected1Bulan = months == 1;
      _isSelected6Bulan = months == 6;
      _isSelected1Tahun = months == 12;
    });
  }

  String _formatRupiah(int harga) {
    return 'Rp ${harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  int get _totalHarga {
    if (_selectedDuration == 6) {
      // Diskon 5% untuk 6 bulan
      return (widget.harga * _selectedDuration * 0.95).toInt();
    } else if (_selectedDuration == 12) {
      // Diskon 10% untuk 1 tahun
      return (widget.harga * _selectedDuration * 0.9).toInt();
    }
    return widget.harga * _selectedDuration;
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?['id'];
    final userName = authProvider.user?['name'] ?? 'Mahasiswa';

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Dapatkan owner_id dari kost
    final kostProvider = Provider.of<KostProvider>(context, listen: false);
    final kost = kostProvider.kosts.firstWhere(
      (k) => k.id == widget.kostId,
      orElse: () => throw Exception('Kost tidak ditemukan'),
    );
    final ownerId = kost.ownerId;

    // Data booking
    final bookingData = {
      'kost_id': widget.kostId,
      'user_id': userId,
      'owner_id': ownerId,
      'nama_kost': widget.namaKost,
      'harga': widget.harga,
      'total_harga': _totalHarga,
      'durasi_bulan': _selectedDuration,
      'tanggal_masuk': _selectedDate.toIso8601String().split('T')[0],
      'catatan': _noteController.text,
      'status': 'pending',
    };

    try {
      // Simpan ke database
      final response = await _saveBookingToDatabase(bookingData);

      if (response['success'] == true) {
        // Kirim notifikasi realtime ke pemilik kost
        SocketService().sendBookingNotification(
          kostId: widget.kostId,
          kostName: widget.namaKost,
          ownerId: ownerId,
          studentName: userName,
          bookingId: response['booking_id'],
          message: '$userName ingin booking ${widget.namaKost}',
        );

        // Tampilkan notifikasi lokal untuk mahasiswa
        await NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Booking Berhasil!',
          body: 'Pesanan Anda untuk ${widget.namaKost} telah dikirim',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Booking berhasil! Pemilik kost akan segera menghubungi Anda.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal melakukan booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _saveBookingToDatabase(Map<String, dynamic> bookingData) async {
    // TODO: Implement API call ke backend PHP
    // return await ApiService.post('bookings/store.php', bookingData);
    
    // Simulasi response (ganti dengan API call asli)
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'booking_id': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ==================== HEADER GRADIENT ====================
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xff1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff1E3A8A), Color(0xff3B82F6), Color(0xff60A5FA)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
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
                                child: Icon(Icons.receipt_long_rounded, color: Color(0xff3B82F6), size: 28),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Form Pemesanan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Isi data pemesanan kost",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

          // ==================== KONTEN ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CARD DETAIL KOST
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xff3B82F6), Color(0xff60A5FA)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.home_work, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.namaKost,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 12, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.alamat,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Harga Sewa",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                "${_formatRupiah(widget.harga)} / bulan",
                                style: const TextStyle(
                                  fontSize: 16,
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

                  const SizedBox(height: 24),

                  /// FORM PEMESANAN
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Form Pemesanan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        /// Durasi Sewa
                        const Text(
                          "Durasi Sewa",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildDurationChip("1 Bulan", _isSelected1Bulan, () => _updateDuration(1)),
                            const SizedBox(width: 8),
                            _buildDurationChip("6 Bulan (Diskon 5%)", _isSelected6Bulan, () => _updateDuration(6)),
                            const SizedBox(width: 8),
                            _buildDurationChip("1 Tahun (Diskon 10%)", _isSelected1Tahun, () => _updateDuration(12)),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        /// Tanggal Masuk
                        const Text(
                          "Tanggal Masuk",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                  style: const TextStyle(
                                    color: Color(0xff1E293B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        /// Catatan
                        const Text(
                          "Catatan (Opsional)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Tambahkan catatan untuk pemilik kost...",
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xff3B82F6)),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// RINGKASAN BIAYA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff3B82F6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xff3B82F6).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Subtotal",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              _formatRupiah(widget.harga * _selectedDuration),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        if (_selectedDuration == 6 || _selectedDuration == 12) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Diskon ${_selectedDuration == 6 ? '5%' : '10%'}",
                                style: const TextStyle(fontSize: 14, color: Colors.green),
                              ),
                              Text(
                                "-${_formatRupiah((widget.harga * _selectedDuration) - _totalHarga)}",
                                style: const TextStyle(fontSize: 14, color: Colors.green),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Pembayaran",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1E293B),
                              ),
                            ),
                            Text(
                              _formatRupiah(_totalHarga),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// TOMBOL KONFIRMASI
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Konfirmasi Booking",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff3B82F6) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xff3B82F6) : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: label.length > 10 ? 11 : 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}