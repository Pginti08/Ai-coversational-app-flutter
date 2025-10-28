// To parse this JSON data, do
//
//     final brandsModel = brandsModelFromJson(jsonString);

import 'dart:convert';

BrandsModel brandsModelFromJson(String str) =>
    BrandsModel.fromJson(json.decode(str));

String brandsModelToJson(BrandsModel data) => json.encode(data.toJson());

class BrandsModel {
  bool? success;
  String? message;
  Data? data;

  BrandsModel({
    this.success,
    this.message,
    this.data,
  });

  BrandsModel copyWith({
    bool? success,
    String? message,
    Data? data,
  }) =>
      BrandsModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory BrandsModel.fromJson(Map<String, dynamic> json) => BrandsModel(
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
  List<Brand>? brands;
  Pagination? pagination;

  Data({
    this.brands,
    this.pagination,
  });

  Data copyWith({
    List<Brand>? brands,
    Pagination? pagination,
  }) =>
      Data(
        brands: brands ?? this.brands,
        pagination: pagination ?? this.pagination,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        brands: json["brands"] == null
            ? []
            : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class Brand {
  String? id;
  String? name;
  String? logo;

  Brand({
    this.id,
    this.name,
    this.logo,
  });

  Brand copyWith({
    String? id,
    String? name,
    String? logo,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        logo: logo ?? this.logo,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["_id"],
        name: json["name"],
        logo: json["logo"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "logo": logo,
      };
}

class Pagination {
  int? page;
  int? limit;
  int? total;

  Pagination({
    this.page,
    this.limit,
    this.total,
  });

  Pagination copyWith({
    int? page,
    int? limit,
    int? total,
  }) =>
      Pagination(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        total: total ?? this.total,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
      };
}
