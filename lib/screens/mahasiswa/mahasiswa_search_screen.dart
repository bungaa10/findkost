import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/kost_model.dart';
import '../kost/kost_detail_screen.dart';

class MahasiswaSearchScreen extends StatefulWidget {
  const MahasiswaSearchScreen({super.key});

  @override
  State<MahasiswaSearchScreen> createState() => _MahasiswaSearchScreenState();
}

class _MahasiswaSearchScreenState extends State<MahasiswaSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kostProvider = Provider.of<KostProvider>(context);
    final filteredKosts = _searchQuery.isEmpty
        ? kostProvider.kosts
        : kostProvider.kosts.where((kost) {
            return kost.namaKost.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                kost.alamat.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Cari Kost", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari kost...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff3B82F6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xffF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: kostProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredKosts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              "Kost tidak ditemukan",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredKosts.length,
                        itemBuilder: (context, index) {
                          final kost = filteredKosts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: Colors.white,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => KostDetailScreen(kost: kost)),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff3B82F6).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.home_work, color: Color(0xff3B82F6), size: 40),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kost.namaKost,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  kost.alamat,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Rp ${kost.harga}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff3B82F6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}