// To parse this JSON data, do
//
//     final savedBodyProfileModel = savedBodyProfileModelFromJson(jsonString);

import 'dart:convert';

SavedBodyProfileModel savedBodyProfileModelFromJson(String str) =>
    SavedBodyProfileModel.fromJson(json.decode(str));

String savedBodyProfileModelToJson(SavedBodyProfileModel data) =>
    json.encode(data.toJson());

class SavedBodyProfileModel {
  bool? success;
  String? message;
  List<SavedBodyProfile>? data;

  SavedBodyProfileModel({
    this.success,
    this.message,
    this.data,
  });

  factory SavedBodyProfileModel.fromJson(Map<String, dynamic> json) =>
      SavedBodyProfileModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SavedBodyProfile>.from(
                json["data"]!.map((x) => SavedBodyProfile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SavedBodyProfile {
  String? id;
  String? name;
  double? height;
  double? bust;
  double? waist;
  double? hips;
  double? shoulders;
  String? unit;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  SavedBodyProfile({
    this.id,
    this.name,
    this.height,
    this.bust,
    this.waist,
    this.hips,
    this.shoulders,
    this.unit,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory SavedBodyProfile.fromJson(Map<String, dynamic> json) =>
      SavedBodyProfile(
        id: json["id"],
        name: json["name"],
        height: double.tryParse(json["height"].toString()),
        bust: double.tryParse(json["bust"].toString()),
        waist: double.tryParse(json["waist"].toString()),
        hips: double.tryParse(json["hips"].toString()),
        shoulders: double.tryParse(json["shoulders"].toString()),
        unit: json["unit"],
        userId: json["userId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "height": height,
        "bust": bust,
        "waist": waist,
        "hips": hips,
        "shoulders": shoulders,
        "unit": unit,
        "userId": userId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
