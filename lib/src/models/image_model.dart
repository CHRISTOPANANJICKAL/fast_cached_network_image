import 'dart:typed_data';

class FastCacheImageModel {
  FastCacheImageModel({required this.dateCreated, required this.data});

  DateTime dateCreated;
  Uint8List data;

  factory FastCacheImageModel.fromJson(dynamic json) {
    Map<String, dynamic> jsonConverted = Map<String, dynamic>.from(json);

    return FastCacheImageModel(
      dateCreated: jsonConverted["date"],
      data: Uint8List.fromList(List<int>.from(jsonConverted["data"])),
    );
  }

  Map<String, dynamic> toJson() => {"date": dateCreated, "data": List<dynamic>.from(data.map((x) => x))};
}
