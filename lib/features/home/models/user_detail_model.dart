// To parse this JSON data, do
//
//     final userDetailModel = userDetailModelFromJson(jsonString);

import 'dart:convert';

UserDetailModel userDetailModelFromJson(String str) =>
    UserDetailModel.fromJson(json.decode(str));

String userDetailModelToJson(UserDetailModel data) =>
    json.encode(data.toJson());

class UserDetailModel {
  bool? success;
  String? message;
  Data? data;

  UserDetailModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) =>
      UserDetailModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  String? id;
  String? name;
  String? countryCode;
  String? phone;
  String? role;
  String? image;
  String? bio;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.name,
    this.countryCode,
    this.phone,
    this.role,
    this.image,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        countryCode: json["countryCode"],
        phone: json["phone"],
        role: json["role"],
        image: json["image"],
        bio: json["bio"],
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
        "countryCode": countryCode,
        "phone": phone,
        "role": role,
        "image": image,
        "bio": bio,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
