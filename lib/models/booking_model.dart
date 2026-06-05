import 'package:flutter/material.dart';

class BookingModel {
  final int id;
  final int kostId;
  final String kostName;
  final String kostImage;
  final int userId;
  final String userName;
  final int ownerId;
  final String status;
  final int durasiBulan;
  final double totalHarga;
  final DateTime tanggalMasuk;
  final String? catatan;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.kostId,
    required this.kostName,
    required this.kostImage,
    required this.userId,
    required this.userName,
    required this.ownerId,
    required this.status,
    required this.durasiBulan,
    required this.totalHarga,
    required this.tanggalMasuk,
    this.catatan,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      kostId: json['kost_id'] is int ? json['kost_id'] : int.parse(json['kost_id'].toString()),
      kostName: json['kost_name'] ?? '',
      kostImage: json['kost_image'] ?? '',
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      userName: json['user_name'] ?? '',
      ownerId: json['owner_id'] is int ? json['owner_id'] : int.parse(json['owner_id'].toString()),
      status: json['status'] ?? 'pending',
      durasiBulan: json['durasi_bulan'] is int ? json['durasi_bulan'] : int.parse(json['durasi_bulan'].toString()),
      totalHarga: (json['total_harga'] is int ? json['total_harga'] : double.parse(json['total_harga'].toString())).toDouble(),
      tanggalMasuk: DateTime.parse(json['tanggal_masuk']),
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedTotalHarga {
    return 'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String get statusText {
    switch (status) {
      case 'pending': return 'Menunggu Konfirmasi';
      case 'confirmed': return 'Dikonfirmasi';
      case 'cancelled': return 'Dibatalkan';
      case 'completed': return 'Selesai';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }
}