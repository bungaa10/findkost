import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/kost_model.dart';

class KostProvider extends ChangeNotifier {
  List<KostModel> _kosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<KostModel> get kosts => _kosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String baseUrl = 'http://192.168.0.107/findkost_api/kost';

  /// Ambil semua kost (untuk Mahasiswaserching)
  Future<void> fetchKost() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/index.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _kosts = data.map((json) => KostModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ambil kost milik pemilik tertentu saja (untuk Owner Dashboard)
  Future<void> fetchKostByOwner(int ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/index.php?owner_id=$ownerId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _kosts = data.map((json) => KostModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data kost';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<bool> createKost(KostModel kost) async {  //implementasi create kost dengan API (async)
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(kost.toJson()),
      );

      final result = json.decode(response.body);

      if (result['success'] == true) {
        // UI already handles fetching the correct list (all or by owner)
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal menambah kost';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> updateKost(KostModel kost) async {  //implementasi update kost dengan API (async)
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': kost.id, ...kost.toJson()}),
      );

      final result = json.decode(response.body);

      if (result['success'] == true) {
        // UI already handles fetching the correct list
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengupdate kost';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> deleteKost(int id) async { //implementasi delete kost dengan API (async)
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final result = json.decode(response.body);

      if (result['success'] == true) {
        _kosts.removeWhere((kost) => kost.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal menghapus kost';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
