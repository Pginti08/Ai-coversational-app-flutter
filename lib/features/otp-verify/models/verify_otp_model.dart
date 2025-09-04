// To parse this JSON data, do
//
//     final verifyOtpModel = verifyOtpModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpModel verifyOtpModelFromJson(String str) =>
    VerifyOtpModel.fromJson(json.decode(str));

String verifyOtpModelToJson(VerifyOtpModel data) => json.encode(data.toJson());

class VerifyOtpModel {
  bool? success;
  String? message;
  Data? data;

  VerifyOtpModel({
    this.success,
    this.message,
    this.data,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
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
  String? message;
  bool? isNew;
  String? token;

  Data({
    this.message,
    this.isNew,
    this.token,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        isNew: json["isNew"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "isNew": isNew,
        "token": token,
      };
}
