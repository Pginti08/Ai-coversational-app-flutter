// To parse this JSON data, do
//
//     final skipProductListModel = skipProductListModelFromJson(jsonString);

import 'dart:convert';

import 'package:vousvous/features/home/models/product_list_model.dart';

SkipProductListModel skipProductListModelFromJson(String str) =>
    SkipProductListModel.fromJson(json.decode(str));

String skipProductListModelToJson(SkipProductListModel data) =>
    json.encode(data.toJson());

class SkipProductListModel {
  bool? success;
  String? message;
  Data? data;

  SkipProductListModel({
    this.success,
    this.message,
    this.data,
  });

  factory SkipProductListModel.fromJson(Map<String, dynamic> json) =>
      SkipProductListModel(
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
