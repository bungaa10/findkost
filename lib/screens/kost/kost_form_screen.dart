import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/kost_model.dart';

class KostFormScreen extends StatefulWidget {
  final KostModel? kost;
  const KostFormScreen({super.key, this.kost});

  @override
  State<KostFormScreen> createState() => _KostFormScreenState();
}

class _KostFormScreenState extends State<KostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _alamatController;
  late TextEditingController _deskripsiController;
  String _selectedKategori = 'Campur';
  final List<String> _kategoriOptions = ['Pria', 'Wanita', 'Campur'];
  bool _isLoading = false;

  // ✅ Fasilitas dengan Tap Chip
  final List<String> _availableFacilities = [
    "WiFi",
    "AC",
    "Kipas Angin",
    "Kamar Mandi Dalam",
    "Kamar Mandi Luar",
    "Kasur",
    "Lemari Pakaian",
    "Meja Belajar",
    "Dapur Umum",
    "Parkir",
    "Include Listrik",
    "Include Air",
    "CCTV",
    "Akses 24 Jam",
  ];
  
  List<String> _selectedFacilities = [];
  final TextEditingController _customFacilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kost?.namaKost ?? '');
    _hargaController = TextEditingController(
      text: widget.kost?.harga.toString() ?? '',
    );
    _alamatController = TextEditingController(text: widget.kost?.alamat ?? '');
    _deskripsiController = TextEditingController(
      text: widget.kost?.deskripsi ?? '',
    );
    _selectedKategori = widget.kost?.kategori ?? 'Campur';
    
    // Load existing facilities from database
    if (widget.kost?.fasilitas != null && widget.kost!.fasilitas.isNotEmpty) {
      _selectedFacilities = widget.kost!.fasilitas.split(',').map((e) => e.trim()).toList();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    _customFacilityController.dispose();
    super.dispose();
  }

  String get _facilitiesString {
    return _selectedFacilities.join(', ');
  }

  void _addCustomFacility() {
    final text = _customFacilityController.text.trim();
    if (text.isNotEmpty && !_selectedFacilities.contains(text)) {
      setState(() {
        _selectedFacilities.add(text);
      });
      _customFacilityController.clear();
    }
  }

  void _toggleFacility(String facility) {
    setState(() {
      if (_selectedFacilities.contains(facility)) {
        _selectedFacilities.remove(facility);
      } else {
        _selectedFacilities.add(facility);
      }
    });
  }

  void _removeFacility(String facility) {
    setState(() {
      _selectedFacilities.remove(facility);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final kost = KostModel(
      id: widget.kost?.id,
      namaKost: _namaController.text,
      harga: int.parse(_hargaController.text),
      alamat: _alamatController.text,
      fasilitas: _facilitiesString, // ✅ Gunakan facilities string dari chip
      deskripsi: _deskripsiController.text,
      kategori: _selectedKategori,
      ownerId: 1,
    );

    final provider = context.read<KostProvider>();
    bool success;

    if (widget.kost == null) {
      success = await provider.createKost(kost);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Kost berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      success = await provider.updateKost(kost);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Kost berhasil diupdate!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menyimpan data'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xff3B82F6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final padding = isSmallScreen ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.kost == null ? 'Tambah Kost Baru' : 'Edit Data Kost',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: const Color(0xff3B82F6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xff3B82F6).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff3B82F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.kost == null ? Icons.add_home : Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.kost == null
                                  ? 'Tambahkan Kost Baru'
                                  : 'Ubah Data Kost',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3B82F6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.kost == null
                                  ? 'Isi semua data dengan lengkap'
                                  : 'Perbarui informasi kost Anda',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                /// FORM FIELDS
                Text(
                  'Informasi Dasar',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                /// NAMA KOST
                TextFormField(
                  controller: _namaController,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration('Nama Kost', Icons.home),
                  validator: (v) => v!.isEmpty ? 'Nama kost wajib diisi' : null,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                /// HARGA
                TextFormField(
                  controller: _hargaController,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    'Harga Per Bulan',
                    Icons.money,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Harga wajib diisi';
                    if (int.tryParse(v) == null)
                      return 'Harga harus berupa angka';
                    return null;
                  },
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),

                /// SECTION: LOKASI & DETAIL
                Text(
                  'Lokasi & Detail',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                /// ALAMAT
                TextFormField(
                  controller: _alamatController,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    'Alamat Lengkap',
                    Icons.location_on,
                  ),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                /// KATEGORI
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  decoration: _buildInputDecoration('Kategori Kost', Icons.category),
                  items: _kategoriOptions.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedKategori = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                /// ==================== FASILITAS TAP CHIP ====================
                Text(
                  'Fasilitas',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih fasilitas yang tersedia di kost Anda',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),

                /// Chip Pilihan Fasilitas
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableFacilities.map((facility) {
                    final isSelected = _selectedFacilities.contains(facility);
                    return FilterChip(
                      label: Text(facility),
                      selected: isSelected,
                      onSelected: (_) => _toggleFacility(facility),
                      selectedColor: const Color(0xff3B82F6),
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? const Color(0xff3B82F6) : Colors.grey[300]!,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                /// Fasilitas Kustom (Tambah sendiri)
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customFacilityController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: "Tambah fasilitas lain...",
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addCustomFacility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),

                /// Menampilkan fasilitas yang sudah dipilih
                if (_selectedFacilities.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff3B82F6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xff3B82F6).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fasilitas yang dipilih:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff3B82F6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _selectedFacilities.map((facility) {
                            return Chip(
                              label: Text(
                                facility,
                                style: const TextStyle(fontSize: 11, color: Color(0xff3B82F6)),
                              ),
                              backgroundColor: Colors.white,
                              deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xff3B82F6)),
                              onDeleted: () => _removeFacility(facility),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: const Color(0xff3B82F6).withOpacity(0.3)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                /// DESKRIPSI
                TextFormField(
                  controller: _deskripsiController,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    'Deskripsi',
                    Icons.description,
                  ).copyWith(
                    hintText:
                        'Jelaskan kondisi dan keunggulan kost Anda',
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),

                /// BUTTON
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff3B82F6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3B82F6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            widget.kost == null
                                ? 'Tambahkan Kost'
                                : 'Simpan Perubahan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                /// CANCEL BUTTON
                Container(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff3B82F6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff3B82F6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}