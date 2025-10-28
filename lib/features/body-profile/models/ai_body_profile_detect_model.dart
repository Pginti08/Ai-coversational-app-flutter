// To parse this JSON data, do
//
//     final aiBodyProfileDetectModel = aiBodyProfileDetectModelFromJson(jsonString);

import 'dart:convert';

AiBodyProfileDetectModel aiBodyProfileDetectModelFromJson(String str) =>
    AiBodyProfileDetectModel.fromJson(json.decode(str));

String aiBodyProfileDetectModelToJson(AiBodyProfileDetectModel data) =>
    json.encode(data.toJson());

class AiBodyProfileDetectModel {
  String? status;
  String? message;
  String? analysisId;
  Measurements? measurements;
  double? confidenceScore;
  String? analysisNotes;
  ImageUrls? savedFilenames;
  ImageUrls? imageUrls;

  AiBodyProfileDetectModel({
    this.status,
    this.message,
    this.analysisId,
    this.measurements,
    this.confidenceScore,
    this.analysisNotes,
    this.savedFilenames,
    this.imageUrls,
  });

  factory AiBodyProfileDetectModel.fromJson(Map<String, dynamic> json) =>
      AiBodyProfileDetectModel(
        status: json["status"],
        message: json["message"],
        analysisId: json["analysis_id"],
        measurements: json["measurements"] == null
            ? null
            : Measurements.fromJson(json["measurements"]),
        confidenceScore: double.tryParse(json["confidence_score"].toString()),
        analysisNotes: json["analysis_notes"],
        savedFilenames: json["saved_filenames"] == null
            ? null
            : ImageUrls.fromJson(json["saved_filenames"]),
        imageUrls: json["image_urls"] == null
            ? null
            : ImageUrls.fromJson(json["image_urls"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "analysis_id": analysisId,
        "measurements": measurements?.toJson(),
        "confidence_score": confidenceScore,
        "analysis_notes": analysisNotes,
        "saved_filenames": savedFilenames?.toJson(),
        "image_urls": imageUrls?.toJson(),
      };
}

class ImageUrls {
  String? front;
  String? back;
  String? side;

  ImageUrls({
    this.front,
    this.back,
    this.side,
  });

  factory ImageUrls.fromJson(Map<String, dynamic> json) => ImageUrls(
        front: json["front"],
        back: json["back"],
        side: json["side"],
      );

  Map<String, dynamic> toJson() => {
        "front": front,
        "back": back,
        "side": side,
      };
}

class Measurements {
  double? height;
  String? heightUnit;
  double? bust;
  String? bustUnit;
  double? waist;
  String? waistUnit;
  double? hips;
  String? hipsUnit;
  double? shoulders;
  String? shouldersUnit;
  double? armLength;
  String? armLengthUnit;
  double? inseam;
  String? inseamUnit;
  double? neck;
  String? neckUnit;

  Measurements({
    this.height,
    this.heightUnit,
    this.bust,
    this.bustUnit,
    this.waist,
    this.waistUnit,
    this.hips,
    this.hipsUnit,
    this.shoulders,
    this.shouldersUnit,
    this.armLength,
    this.armLengthUnit,
    this.inseam,
    this.inseamUnit,
    this.neck,
    this.neckUnit,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) => Measurements(
        height: json["height"],
        heightUnit: json["height_unit"],
        bust: json["bust"],
        bustUnit: json["bust_unit"],
        waist: json["waist"],
        waistUnit: json["waist_unit"],
        hips: json["hips"],
        hipsUnit: json["hips_unit"],
        shoulders: json["shoulders"],
        shouldersUnit: json["shoulders_unit"],
        armLength: json["arm_length"],
        armLengthUnit: json["arm_length_unit"],
        inseam: json["inseam"],
        inseamUnit: json["inseam_unit"],
        neck: json["neck"],
        neckUnit: json["neck_unit"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "height_unit": heightUnit,
        "bust": bust,
        "bust_unit": bustUnit,
        "waist": waist,
        "waist_unit": waistUnit,
        "hips": hips,
        "hips_unit": hipsUnit,
        "shoulders": shoulders,
        "shoulders_unit": shouldersUnit,
        "arm_length": armLength,
        "arm_length_unit": armLengthUnit,
        "inseam": inseam,
        "inseam_unit": inseamUnit,
        "neck": neck,
        "neck_unit": neckUnit,
      };
}
