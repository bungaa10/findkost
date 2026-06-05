import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('http://localhost/findkost_api/bookings/owner.php?owner_id=1'));
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
    
    final data = jsonDecode(response.body);
    print('Is List? ${data is List}');
    
    if (data is List) {
      for (var item in data) {
        print('Parsing item id: ${item['id']}');
        
        // Simulating BookingModel.fromJson
        int id = item['id'] is int ? item['id'] : int.parse(item['id'].toString());
        int kostId = item['kost_id'] is int ? item['kost_id'] : int.parse(item['kost_id'].toString());
        String kostName = item['kost_name'] ?? '';
        String kostImage = item['kost_image'] ?? '';
        int userId = item['user_id'] is int ? item['user_id'] : int.parse(item['user_id'].toString());
        String userName = item['user_name'] ?? '';
        int ownerId = item['owner_id'] is int ? item['owner_id'] : int.parse(item['owner_id'].toString());
        String status = item['status'] ?? 'pending';
        int durasiBulan = item['durasi_bulan'] is int ? item['durasi_bulan'] : int.parse(item['durasi_bulan'].toString());
        double totalHarga = (item['total_harga'] is int ? item['total_harga'] : double.parse(item['total_harga'].toString())).toDouble();
        DateTime tanggalMasuk = DateTime.parse(item['tanggal_masuk']);
        String catatan = item['catatan'] ?? '';
        DateTime createdAt = DateTime.parse(item['created_at']);
        
        print('Successfully parsed: Booking $id for $kostName');
      }
    }
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
