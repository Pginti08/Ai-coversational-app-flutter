// To parse this JSON data, do
//
//     final finalQuotationModel = finalQuotationModelFromJson(jsonString);

import 'dart:convert';

FinalQuotationModel finalQuotationModelFromJson(String str) =>
    FinalQuotationModel.fromJson(json.decode(str));

String finalQuotationModelToJson(FinalQuotationModel data) =>
    json.encode(data.toJson());

class FinalQuotationModel {
  String? quotationNumber;
  String? date;
  String? title;
  String? color;
  String? material;
  String? type;
  String? style;
  String? measurements;
  String? specialRequests;
  String? quantity;
  String? price;
  String? dressImageUrl;
  String? status;
  String? quotationId;

  FinalQuotationModel({
    this.quotationNumber,
    this.date,
    this.title,
    this.color,
    this.material,
    this.type,
    this.style,
    this.measurements,
    this.specialRequests,
    this.quantity,
    this.price,
    this.dressImageUrl,
    this.status,
    this.quotationId,
  });

  factory FinalQuotationModel.fromJson(Map<String, dynamic> json) =>
      FinalQuotationModel(
        quotationNumber: json["quotation_number"],
        date: json["date"],
        title: json["title"],
        color: json["color"],
        material: json["material"],
        type: json["type"],
        style: json["style"],
        measurements: json["measurements"],
        specialRequests: json["special_requests"],
        quantity: json["quantity"],
        price: json["price"],
        dressImageUrl: json["dress_image_url"],
        status: json["status"],
        quotationId: json["quotation_id"],
      );

  Map<String, dynamic> toJson() => {
        "quotation_number": quotationNumber,
        "date": date,
        "title": title,
        "color": color,
        "material": material,
        "type": type,
        "style": style,
        "measurements": measurements,
        "special_requests": specialRequests,
        "quantity": quantity,
        "price": price,
        "dress_image_url": dressImageUrl,
        "status": status,
        "quotation_id": quotationId,
      };
}
