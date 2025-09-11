// To parse this JSON data, do
//
//     final likedProductListModel = likedProductListModelFromJson(jsonString);

import 'dart:convert';

import 'package:ai_fashion/features/home/models/product_list_model.dart';

LikedProductListModel likedProductListModelFromJson(String str) =>
    LikedProductListModel.fromJson(json.decode(str));

String LikedProductListModelToJson(LikedProductListModel data) =>
    json.encode(data.toJson());

class LikedProductListModel {
  bool? success;
  String? message;
  Data? data;

  LikedProductListModel({
    this.success,
    this.message,
    this.data,
  });

  factory LikedProductListModel.fromJson(Map<String, dynamic> json) =>
      LikedProductListModel(
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
  List<Product>? items;
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
            : List<Product>.from(
                json["items"]!.map((x) => Product.fromJson(x))),
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
