import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kost_provider.dart';
import 'kost_form_screen.dart';

class KostListScreen extends StatefulWidget {
  const KostListScreen({super.key});

  @override
  State<KostListScreen> createState() => _KostListScreenState();
}

class _KostListScreenState extends State<KostListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<KostProvider>().fetchKost());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, int id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kost'),
        content: Text('Yakin ingin menghapus "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        final success = await context.read<KostProvider>().deleteKost(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Berhasil dihapus' : 'Gagal menghapus'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KostProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final padding = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Kelola Kost", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: const Color(0xff3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: EdgeInsets.all(padding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xff3B82F6)),
                hintText: "Cari kost...",
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: provider.isLoading && provider.kosts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Memuat data kost..."),
                      ],
                    ),
                  )
                : provider.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 56, color: Colors.red),
                            const SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: padding),
                              child: Text(
                                'Error: ${provider.errorMessage}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => provider.fetchKost(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("Coba Lagi"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff3B82F6),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : provider.kosts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  "Belum ada data kost",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isMediumScreen = constraints.maxWidth > 600;

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
                                itemCount: provider.kosts.length,
                                itemBuilder: (_, index) {
                                  final kost = provider.kosts[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /// HEADER ROW
                                          Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff3B82F6).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.home,
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
                                                      kost.namaKost,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      kost.alamat,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
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
                                          const SizedBox(height: 12),

                                          /// PRICE & ACTION
                                          if (isMediumScreen)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Rp ${kost.harga}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff3B82F6),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Icons.edit, size: 18),
                                                      label: const Text("Edit"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xff3B82F6),
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                KostFormScreen(kost: kost),
                                                          ),
                                                        ).then((_) => provider.fetchKost());
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Icons.delete, size: 18),
                                                      label: const Text("Hapus"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                      ),
                                                      onPressed: () => _confirmDelete(
                                                        context,
                                                        kost.id!,
                                                        kost.namaKost,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          else
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Rp ${kost.harga}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff3B82F6),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        icon: const Icon(Icons.edit, size: 18),
                                                        label: const Text("Edit"),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(0xff3B82F6),
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  KostFormScreen(kost: kost),
                                                            ),
                                                          ).then((_) =>
                                                              provider.fetchKost());
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        icon: const Icon(Icons.delete, size: 18),
                                                        label: const Text("Hapus"),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        onPressed: () => _confirmDelete(
                                                          context,
                                                          kost.id!,
                                                          kost.namaKost,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KostFormScreen()),
          ).then((_) => provider.fetchKost());
        },
        backgroundColor: const Color(0xff3B82F6),
        child: const Icon(Icons.add),
      ),
    );
  }
}