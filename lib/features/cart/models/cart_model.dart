// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

CartModel cartModelFromJson(String str) => CartModel.fromJson(json.decode(str));

String cartModelToJson(CartModel data) => json.encode(data.toJson());

class CartModel {
  bool? success;
  String? message;
  Data? data;

  CartModel({
    this.success,
    this.message,
    this.data,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
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
  List<Cart>? items;
  double? subTotal;
  double? taxAmount;
  double? shippingCharge;
  int? total;
  int? page;
  int? limit;

  Data({
    this.items,
    this.subTotal,
    this.taxAmount,
    this.shippingCharge,
    this.total,
    this.page,
    this.limit,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? []
            : List<Cart>.from(json["items"]!.map((x) => Cart.fromJson(x))),
        subTotal: double.tryParse(json["subTotal"].toString()),
        taxAmount: double.tryParse(json["taxAmount"].toString()),
        shippingCharge: double.tryParse(json["shippingCharge"].toString()),
        total: int.tryParse(json["total"].toString()),
        page: int.tryParse(json["page"].toString()),
        limit: int.tryParse(json["limit"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "subTotal": subTotal,
        "taxAmount": taxAmount,
        "shippingCharge": shippingCharge,
        "total": total,
        "page": page,
        "limit": limit,
      };
}

class Cart {
  String? id;
  String? userId;
  String? quotationCardId;
  double? amount;
  int? quantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? title;
  String? purchaseType;
  dynamic bulkQuantities;
  List<BodyProfile>? bodyProfiles;
  String? dressImage;
  String? sizeMeasurement;
  double? totalPrice;

  Cart({
    this.id,
    this.userId,
    this.quotationCardId,
    this.amount,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.title,
    this.purchaseType,
    this.bulkQuantities,
    this.bodyProfiles,
    this.dressImage,
    this.sizeMeasurement,
    this.totalPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["_id"],
        userId: json["userId"],
        quotationCardId: json["quotationCardId"],
        amount: double.tryParse(json["amount"].toString()),
        quantity: int.tryParse(json["quantity"].toString()),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: int.tryParse(json["__v"].toString()),
        title: json["title"],
        purchaseType: json["purchaseType"],
        bulkQuantities: json["bulkQuantities"],
        bodyProfiles: json["bodyProfiles"] == null
            ? []
            : List<BodyProfile>.from(
                json["bodyProfiles"]!.map((x) => BodyProfile.fromJson(x))),
        dressImage: json["dressImage"],
        sizeMeasurement: json["sizeMeasurement"],
        totalPrice: double.tryParse(json["totalPrice"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "quotationCardId": quotationCardId,
        "amount": amount,
        "quantity": quantity,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "title": title,
        "purchaseType": purchaseType,
        "bulkQuantities": bulkQuantities?.toJson(),
        "bodyProfiles": bodyProfiles == null
            ? []
            : List<dynamic>.from(bodyProfiles!.map((x) => x.toJson())),
        "dressImage": dressImage,
        "sizeMeasurement": sizeMeasurement,
        "totalPrice": totalPrice,
      };
}

class BodyProfile {
  String? id;
  String? name;
  int? height;
  int? bust;
  int? waist;
  int? hips;
  int? shoulders;
  String? unit;

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
        height: int.tryParse(json["height"].toString()),
        bust: int.tryParse(json["bust"].toString()),
        waist: int.tryParse(json["waist"].toString()),
        hips: int.tryParse(json["hips"].toString()),
        shoulders: int.tryParse(json["shoulders"].toString()),
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
