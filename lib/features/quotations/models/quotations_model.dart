// To parse this JSON data, do
//
//     final quotationModel = quotationModelFromJson(jsonString);

import 'dart:convert';

QuotationModel quotationModelFromJson(String str) =>
    QuotationModel.fromJson(json.decode(str));

String quotationModelToJson(QuotationModel data) => json.encode(data.toJson());

class QuotationModel {
  String? type;
  Data? data;
  DateTime? timestamp;

  QuotationModel({
    this.type,
    this.data,
    this.timestamp,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) => QuotationModel(
        type: json["type"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
        "timestamp": timestamp?.toIso8601String(),
      };
}

class Data {
  List<Quotation>? items;
  int? total;
  int? page;
  int? limit;

  Data({
    this.items,
    this.total,
    this.page,
    this.limit,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? []
            : List<Quotation>.from(
                json["items"]!.map((x) => Quotation.fromJson(x))),
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "limit": limit,
      };
}

class Quotation {
  String? id;
  String? userId;
  String? productId;
  String? purchaseType;
  List<BodyProfile>? bodyProfiles;
  String? dressImage;
  String? material;
  String? color;
  String? specialRequests;
  double? price;
  String? currency;
  String? note;
  String? title;
  String? description;
  String? status;
  String? quotationNumber;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  AiAnalysis? aiAnalysis;
  Map<String, dynamic>? bulkQuantities;
  int? totalQuantity;
  dynamic product;
  bool? hasNewMessage;

  Quotation({
    this.id,
    this.userId,
    this.productId,
    this.purchaseType,
    this.bodyProfiles,
    this.dressImage,
    this.material,
    this.color,
    this.specialRequests,
    this.price,
    this.currency,
    this.note,
    this.title,
    this.description,
    this.status,
    this.quotationNumber,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.aiAnalysis,
    this.bulkQuantities,
    this.totalQuantity,
    this.product,
    this.hasNewMessage,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
        id: json["_id"],
        userId: json["userId"],
        productId: json["productId"],
        purchaseType: json["purchaseType"],
        bodyProfiles: json["bodyProfiles"] == null
            ? []
            : List<BodyProfile>.from(
                json["bodyProfiles"]!.map((x) => BodyProfile.fromJson(x))),
        dressImage: json["dressImage"],
        material: json["material"],
        color: json["color"],
        specialRequests: json["specialRequests"],
        price: double.tryParse(json["price"].toString()),
        currency: json["currency"],
        note: json["note"],
        title: json["title"],
        description: json["description"],
        status: json["status"],
        quotationNumber: json["quotationNumber"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        aiAnalysis: json["aiAnalysis"] == null
            ? null
            : AiAnalysis.fromJson(json["aiAnalysis"]),
        bulkQuantities: json["bulkQuantities"] == null
            ? {}
            : Map<String, dynamic>.from(json["bulkQuantities"]),
        totalQuantity: json["totalQuantity"],
        product: json["product"],
        hasNewMessage: json["hasNewMessage"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "productId": productId,
        "purchaseType": purchaseType,
        "bodyProfiles": bodyProfiles == null
            ? []
            : List<dynamic>.from(bodyProfiles!.map((x) => x.toJson())),
        "dressImage": dressImage,
        "material": material,
        "color": color,
        "specialRequests": specialRequests,
        "price": price,
        "currency": currency,
        "note": note,
        "title": title,
        "description": description,
        "status": status,
        "quotationNumber": quotationNumber,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "aiAnalysis": aiAnalysis?.toJson(),
        "bulkQuantities": bulkQuantities ?? {},
        "totalQuantity": totalQuantity,
        "product": product,
        "hasNewMessage": hasNewMessage,
      };
}

class AiAnalysis {
  String? title;
  String? description;
  String? material;
  String? color;
  String? type;
  String? style;
  List<String>? features;

  AiAnalysis({
    this.title,
    this.description,
    this.material,
    this.color,
    this.type,
    this.style,
    this.features,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) => AiAnalysis(
        title: json["title"],
        description: json["description"],
        material: json["material"],
        color: json["color"],
        type: json["type"],
        style: json["style"],
        features: json["features"] == null
            ? []
            : List<String>.from(json["features"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "material": material,
        "color": color,
        "type": type,
        "style": style,
        "features":
            features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
      };
}

class BodyProfile {
  String? id;
  String? name;
  int? height;
  String? heightUnit;
  int? bust;
  String? bustUnit;
  int? waist;
  String? waistUnit;
  int? hips;
  String? hipsUnit;
  int? shoulders;

  BodyProfile({
    this.id,
    this.name,
    this.height,
    this.heightUnit,
    this.bust,
    this.bustUnit,
    this.waist,
    this.waistUnit,
    this.hips,
    this.hipsUnit,
    this.shoulders,
  });

  factory BodyProfile.fromJson(Map<String, dynamic> json) => BodyProfile(
        id: json["id"],
        name: json["name"],
        height: json["height"],
        heightUnit: json["heightUnit"],
        bust: json["bust"],
        bustUnit: json["bustUnit"],
        waist: json["waist"],
        waistUnit: json["waistUnit"],
        hips: json["hips"],
        hipsUnit: json["hipsUnit"],
        shoulders: json["shoulders"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "height": height,
        "heightUnit": heightUnit,
        "bust": bust,
        "bustUnit": bustUnit,
        "waist": waist,
        "waistUnit": waistUnit,
        "hips": hips,
        "hipsUnit": hipsUnit,
        "shoulders": shoulders,
      };
}
