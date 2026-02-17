// To parse this JSON data, do
//
//     final quotationDetailModel = quotationDetailModelFromJson(jsonString);

import 'dart:convert';

QuotationDetailModel quotationDetailModelFromJson(String str) =>
    QuotationDetailModel.fromJson(json.decode(str));

String quotationDetailModelToJson(QuotationDetailModel data) =>
    json.encode(data.toJson());

class QuotationDetailModel {
  final bool? success;
  final String? message;
  final Data? data;

  QuotationDetailModel({
    this.success,
    this.message,
    this.data,
  });

  factory QuotationDetailModel.fromJson(Map<String, dynamic> json) =>
      QuotationDetailModel(
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
  final String? quotationNumber;
  final String? userId;
  final String? productId;
  final String? purchaseType;
  final int? price;
  final DateTime? date;
  final String? title;
  final String? color;
  final String? material;
  final String? type;
  final dynamic style;
  final List<BodyProfile>? bodyProfiles;
  final dynamic bulkQuantities;
  final String? currency;
  final String? description;
  final String? note;
  final dynamic specialRequests;
  final int? quantity;
  final String? dressImage;
  final String? status;
  final EstimatedDeliveryTime? estimatedDeliveryTime;

  Data({
    this.quotationNumber,
    this.userId,
    this.productId,
    this.purchaseType,
    this.price,
    this.date,
    this.title,
    this.color,
    this.material,
    this.type,
    this.style,
    this.bodyProfiles,
    this.bulkQuantities,
    this.currency,
    this.description,
    this.note,
    this.specialRequests,
    this.quantity,
    this.dressImage,
    this.status,
    this.estimatedDeliveryTime,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        quotationNumber: json["quotationNumber"],
        userId: json["userId"],
        productId: json["productId"],
        purchaseType: json["purchaseType"],
        price: json["price"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        title: json["title"],
        color: json["color"],
        material: json["material"],
        type: json["type"],
        style: json["style"],
        bodyProfiles: json["bodyProfiles"] == null
            ? []
            : List<BodyProfile>.from(
                json["bodyProfiles"]!.map((x) => BodyProfile.fromJson(x))),
        bulkQuantities: json["bulkQuantities"],
        currency: json["currency"],
        description: json["description"],
        note: json["note"],
        specialRequests: json["specialRequests"],
        quantity: json["quantity"],
        dressImage: json["dressImage"],
        status: json["status"],
        estimatedDeliveryTime: json["estimatedDeliveryTime"] == null
            ? null
            : EstimatedDeliveryTime.fromJson(json["estimatedDeliveryTime"]),
      );

  Map<String, dynamic> toJson() => {
        "quotationNumber": quotationNumber,
        "userId": userId,
        "productId": productId,
        "purchaseType": purchaseType,
        "price": price,
        "date": date?.toIso8601String(),
        "title": title,
        "color": color,
        "material": material,
        "type": type,
        "style": style,
        "bodyProfiles": bodyProfiles == null
            ? []
            : List<dynamic>.from(bodyProfiles!.map((x) => x.toJson())),
        "bulkQuantities": bulkQuantities,
        "currency": currency,
        "description": description,
        "note": note,
        "specialRequests": specialRequests,
        "quantity": quantity,
        "dressImage": dressImage,
        "status": status,
        "estimatedDeliveryTime": estimatedDeliveryTime?.toJson(),
      };
}

class BodyProfile {
  final String? id;
  final String? name;
  final String? height;
  final String? bust;
  final String? waist;
  final String? hips;
  final String? shoulders;
  final String? unit;

  BodyProfile({
    this.id,
    this.name,
    this.height,
    this.bust,
    this.waist,
    this.hips,
    this.shoulders,
    this.unit,
  });

  factory BodyProfile.fromJson(Map<String, dynamic> json) => BodyProfile(
        id: json["id"],
        name: json["name"],
        height: json["height"],
        bust: json["bust"],
        waist: json["waist"],
        hips: json["hips"],
        shoulders: json["shoulders"],
        unit: json["unit"],
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
      };
}

class EstimatedDeliveryTime {
  final int? minDays;
  final int? maxDays;

  EstimatedDeliveryTime({
    this.minDays,
    this.maxDays,
  });

  factory EstimatedDeliveryTime.fromJson(Map<String, dynamic> json) =>
      EstimatedDeliveryTime(
        minDays: json["minDays"],
        maxDays: json["maxDays"],
      );

  Map<String, dynamic> toJson() => {
        "minDays": minDays,
        "maxDays": maxDays,
      };
}
