class KostModel {
  final int? id;
  final int ownerId;
  final String namaKost;
  final String ownerName;
  final int harga;
  final String alamat;
  final String fasilitas;
  final String deskripsi;
  final String kategori;
  final String? foto;
  final String? createdAt;

  const KostModel({
    this.id,
    required this.ownerId,
    required this.namaKost,
    required this.ownerName,
    required this.harga,
    required this.alamat,
    this.fasilitas = '',
    this.deskripsi = '',
    this.kategori = 'Campur',
    this.foto,
    this.createdAt,
  });

  // Dari JSON (response dari backend) - PERBAIKI PARSING
  factory KostModel.fromJson(Map<String, dynamic> json) {
    return KostModel(
      // Konversi id dengan aman
      id: _parseInt(json['id']),
      
      // Konversi owner_id dengan aman
      ownerId: _parseInt(json['owner_id'], defaultValue: 1),
      
      ownerName: json['owner_name']?.toString() ?? '',
      
      namaKost: json['nama_kost']?.toString() ?? '',
      
      // Konversi harga dengan aman
      harga: _parseInt(json['harga'], defaultValue: 0),
      
      alamat: json['alamat']?.toString() ?? '',
      fasilitas: json['fasilitas']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'Campur',
      foto: json['foto']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  // Helper function untuk parse int dari berbagai tipe
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  // Ke Map untuk HTTP POST
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'owner_id': ownerId.toString(),
      'nama_kost': namaKost,
      'harga': harga.toString(),
      'alamat': alamat,
      'fasilitas': fasilitas,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'foto': foto ?? '',
    };
  }

  // Format harga
  String get hargaFormatted {
    final h = harga.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = h.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(h[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  // copyWith
  KostModel copyWith({
    int? id,
    int? ownerId,
    String? namaKost,
    int? harga,
    String? alamat,
    String? fasilitas,
    String? deskripsi,
    String? kategori,
    String? foto,
    String? ownerName,
  }) {
    return KostModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      namaKost: namaKost ?? this.namaKost,
      ownerName: ownerName ?? this.ownerName,
      harga: harga ?? this.harga,
      alamat: alamat ?? this.alamat,
      fasilitas: fasilitas ?? this.fasilitas,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      foto: foto ?? this.foto,
    );
  }

  @override
  String toString() => 'KostModel(id: $id, namaKost: $namaKost, harga: $harga)';
}