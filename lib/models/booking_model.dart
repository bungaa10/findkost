class BookingModel {

  final int id;
  final int kostId;
  final int userId;
  final String status;

  BookingModel({
    required this.id,
    required this.kostId,
    required this.userId,
    required this.status,
  });

  factory BookingModel.fromJson(
    Map<String,dynamic> json,
  ){

    return BookingModel(
      id: int.parse(json['id'].toString()),
      kostId: int.parse(json['kost_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      status: json['status'],
    );
  }
}