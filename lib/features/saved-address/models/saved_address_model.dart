// To parse this JSON data, do
//
//     final savedAddressModel = savedAddressModelFromJson(jsonString);

import 'dart:convert';

SavedAddressModel savedAddressModelFromJson(String str) =>
    SavedAddressModel.fromJson(json.decode(str));

String savedAddressModelToJson(SavedAddressModel data) =>
    json.encode(data.toJson());

class SavedAddressModel {
  bool? success;
  String? message;
  List<SavedAddress>? data;

  SavedAddressModel({
    this.success,
    this.message,
    this.data,
  });

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) =>
      SavedAddressModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SavedAddress>.from(
                json["data"]!.map((x) => SavedAddress.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SavedAddress {
  String? id;
  String? name;
  String? mobile;
  String? pincode;
  String? address;
  String? city;
  String? state;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  SavedAddress({
    this.id,
    this.name,
    this.mobile,
    this.pincode,
    this.address,
    this.city,
    this.state,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json["id"],
        name: json["name"],
        mobile: json["mobile"],
        pincode: json["pincode"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
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
        "mobile": mobile,
        "pincode": pincode,
        "address": address,
        "city": city,
        "state": state,
        "userId": userId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
