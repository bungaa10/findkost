import '../models/kost_model.dart';
import 'api_service.dart';

class KostService {

  Future<List<KostModel>> getKost() async {

    final response =
        await ApiService.get(
      "kost/index.php",
    );

    return (response as List)
        .map(
          (e) => KostModel.fromJson(e),
        )
        .toList();
  }

  Future<dynamic> addKost(
      Map<String,dynamic> data,
      ) async {

    return await ApiService.post(
      "kost/store.php",
      data,
    );
  }

  Future<dynamic> updateKost(
      Map<String,dynamic> data,
      ) async {

    return await ApiService.post(
      "kost/update.php",
      data,
    );
  }

  Future<dynamic> deleteKost(
      int id,
      ) async {

    return await ApiService.post(
      "kost/delete.php",
      {
        "id": id.toString(),
      },
    );
  }
}