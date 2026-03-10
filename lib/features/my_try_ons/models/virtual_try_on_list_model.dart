// To parse this JSON data, do
//
//     final virtualTryOnListModel = virtualTryOnListModelFromJson(jsonString);

import 'dart:convert';

VirtualTryOnListModel virtualTryOnListModelFromJson(String str) =>
    VirtualTryOnListModel.fromJson(json.decode(str));

String virtualTryOnListModelToJson(VirtualTryOnListModel data) =>
    json.encode(data.toJson());

class VirtualTryOnListModel {
  final bool? success;
  final Data? data;

  VirtualTryOnListModel({
    this.success,
    this.data,
  });

  factory VirtualTryOnListModel.fromJson(Map<String, dynamic> json) =>
      VirtualTryOnListModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class Data {
  final List<VirtualTryOn>? items;
  final int? page;
  final int? limit;
  final int? total;

  Data({
    this.items,
    this.page,
    this.limit,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? []
            : List<VirtualTryOn>.from(
                json["items"]!.map((x) => VirtualTryOn.fromJson(x))),
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "page": page,
        "limit": limit,
        "total": total,
      };
}

class VirtualTryOn {
  final String? id;
  final String? personImageUrl;
  final String? productImageUrl;
  final String? resultImageUrl;
  final String? resultThumbnailUrl;
  final String? extractedGarmentUrl;
  final dynamic upscaledPersonUrl;
  final dynamic productId;
  final DateTime? createdAt;
  final SavedFilenames? savedFilenames;

  VirtualTryOn({
    this.id,
    this.personImageUrl,
    this.productImageUrl,
    this.resultImageUrl,
    this.resultThumbnailUrl,
    this.extractedGarmentUrl,
    this.upscaledPersonUrl,
    this.productId,
    this.createdAt,
    this.savedFilenames,
  });

  factory VirtualTryOn.fromJson(Map<String, dynamic> json) => VirtualTryOn(
        id: json["id"],
        personImageUrl: json["person_image_url"],
        productImageUrl: json["product_image_url"],
        resultImageUrl: json["result_image_url"],
        resultThumbnailUrl: json["result_thumbnail_url"],
        extractedGarmentUrl: json["extracted_garment_url"],
        upscaledPersonUrl: json["upscaled_person_url"],
        productId: json["product_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        savedFilenames: json["saved_filenames"] == null
            ? null
            : SavedFilenames.fromJson(json["saved_filenames"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "person_image_url": personImageUrl,
        "product_image_url": productImageUrl,
        "result_image_url": resultImageUrl,
        "result_thumbnail_url": resultThumbnailUrl,
        "extracted_garment_url": extractedGarmentUrl,
        "upscaled_person_url": upscaledPersonUrl,
        "product_id": productId,
        "created_at": createdAt?.toIso8601String(),
        "saved_filenames": savedFilenames?.toJson(),
      };
}

class SavedFilenames {
  final String? person;
  final String? product;
  final String? result;
  final String? garment;

  SavedFilenames({
    this.person,
    this.product,
    this.result,
    this.garment,
  });

  factory SavedFilenames.fromJson(Map<String, dynamic> json) => SavedFilenames(
        person: json["person"],
        product: json["product"],
        result: json["result"],
        garment: json["garment"],
      );

  Map<String, dynamic> toJson() => {
        "person": person,
        "product": product,
        "result": result,
        "garment": garment,
      };
}
