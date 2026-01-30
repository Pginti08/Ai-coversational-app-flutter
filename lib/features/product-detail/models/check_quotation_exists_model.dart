// To parse this JSON data, do
//
//     final checkQuotationExistsModel = checkQuotationExistsModelFromJson(jsonString);

import 'dart:convert';

CheckQuotationExistsModel checkQuotationExistsModelFromJson(String str) =>
    CheckQuotationExistsModel.fromJson(json.decode(str));

String checkQuotationExistsModelToJson(CheckQuotationExistsModel data) =>
    json.encode(data.toJson());

class CheckQuotationExistsModel {
  bool? success;
  String? message;
  Data? data;

  CheckQuotationExistsModel({
    this.success,
    this.message,
    this.data,
  });

  factory CheckQuotationExistsModel.fromJson(Map<String, dynamic> json) =>
      CheckQuotationExistsModel(
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
  bool? exists;
  String? quotationId;
  AiAnalysis? aiAnalysis;

  Data({
    this.exists,
    this.quotationId,
    this.aiAnalysis,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        exists: json["exists"],
        quotationId: json["quotationId"],
        aiAnalysis: json["aiAnalysis"] == null
            ? null
            : AiAnalysis.fromJson(json["aiAnalysis"]),
      );

  Map<String, dynamic> toJson() => {
        "exists": exists,
        "quotationId": quotationId,
        "aiAnalysis": aiAnalysis?.toJson(),
      };
}

class AiAnalysis {
  String? title;
  String? description;
  dynamic material;
  dynamic color;
  dynamic type;

  AiAnalysis({
    this.title,
    this.description,
    this.material,
    this.color,
    this.type,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) => AiAnalysis(
        title: json["title"],
        description: json["description"],
        material: json["material"],
        color: json["color"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "material": material,
        "color": color,
        "type": type,
      };
}
