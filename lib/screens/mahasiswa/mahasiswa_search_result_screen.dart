import 'package:flutter/material.dart';
import '../../models/kost_model.dart';
import '../kost/kost_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final List<KostModel> results;
  final String keyword;

  const SearchResultScreen({
    super.key,
    required this.results,
    this.keyword = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Hasil Pencarian",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Kost tidak ditemukan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Coba sesuaikan filter atau kata kunci Anda.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final kost = results[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KostDetailScreen(kost: kost),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ICON GRADIENT
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff3B82F6), Color(0xff60A5FA)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.home_work,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          /// INFO KOST
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kost.namaKost,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xff1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        kost.alamat,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      kost.hargaFormatted,
                                      style: const TextStyle(
                                        color: Color(0xff3B82F6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kost.kategori == 'Pria' ? Colors.blue.withOpacity(0.1) : kost.kategori == 'Wanita' ? Colors.pink.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        kost.kategori,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: kost.kategori == 'Pria' ? Colors.blue : kost.kategori == 'Wanita' ? Colors.pink : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
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
    );
  }
}
