// To parse this JSON data, do
//
//     final analyzeDressModel = analyzeDressModelFromJson(jsonString);

import 'dart:convert';

AnalyzeDressModel analyzeDressModelFromJson(String str) =>
    AnalyzeDressModel.fromJson(json.decode(str));

String analyzeDressModelToJson(AnalyzeDressModel data) =>
    json.encode(data.toJson());

class AnalyzeDressModel {
  String? status;
  String? message;
  String? quotationId;
  Analysis? analysis;
  String? savedFilename;
  String? imageUrl;

  AnalyzeDressModel({
    this.status,
    this.message,
    this.quotationId,
    this.analysis,
    this.savedFilename,
    this.imageUrl,
  });

  AnalyzeDressModel copyWith({
    String? status,
    String? message,
    String? quotationId,
    Analysis? analysis,
    String? savedFilename,
    String? imageUrl,
  }) =>
      AnalyzeDressModel(
        status: status ?? this.status,
        message: message ?? this.message,
        quotationId: quotationId ?? this.quotationId,
        analysis: analysis ?? this.analysis,
        savedFilename: savedFilename ?? this.savedFilename,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory AnalyzeDressModel.fromJson(Map<String, dynamic> json) =>
      AnalyzeDressModel(
        status: json["status"],
        message: json["message"],
        quotationId: json["quotation_id"],
        analysis: json["analysis"] == null
            ? null
            : Analysis.fromJson(json["analysis"]),
        savedFilename: json["saved_filename"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "quotation_id": quotationId,
        "analysis": analysis?.toJson(),
        "saved_filename": savedFilename,
        "image_url": imageUrl,
      };
}

class Analysis {
  String? title;
  String? description;
  String? material;
  String? color;
  String? type;
  String? style;
  List<String>? features;

  Analysis({
    this.title,
    this.description,
    this.material,
    this.color,
    this.type,
    this.style,
    this.features,
  });

  Analysis copyWith({
    String? title,
    String? description,
    String? material,
    String? color,
    String? type,
    String? style,
    List<String>? features,
  }) =>
      Analysis(
        title: title ?? this.title,
        description: description ?? this.description,
        material: material ?? this.material,
        color: color ?? this.color,
        type: type ?? this.type,
        style: style ?? this.style,
        features: features ?? this.features,
      );

  factory Analysis.fromJson(Map<String, dynamic> json) => Analysis(
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
