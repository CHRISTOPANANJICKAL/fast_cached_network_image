import 'dart:typed_data';

class ImageModel {
  ImageModel({required this.dateCreated, required this.data});

  DateTime dateCreated;
  Uint8List data;

  factory ImageModel.fromJson(dynamic json) {
    Map<String, dynamic> jsonConverted = Map<String, dynamic>.from(json);

    return ImageModel(
      dateCreated: jsonConverted["date"],
      data: Uint8List.fromList(List<int>.from(jsonConverted["data"])),
    );
  }

  Map<String, dynamic> toJson() => {"date": dateCreated, "data": List<dynamic>.from(data.map((x) => x))};
}
