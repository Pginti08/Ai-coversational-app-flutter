// To parse this JSON data, do
//
//     final chatHistoryModel = chatHistoryModelFromJson(jsonString);

import 'dart:convert';

ChatHistoryModel chatHistoryModelFromJson(String str) =>
    ChatHistoryModel.fromJson(json.decode(str));

String chatHistoryModelToJson(ChatHistoryModel data) =>
    json.encode(data.toJson());

class ChatHistoryModel {
  String? status;
  String? message;
  Data? data;

  ChatHistoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) =>
      ChatHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  List<Message>? items;
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
            : List<Message>.from(
                json["items"]!.map((x) => Message.fromJson(x))),
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

class Message {
  String? id;
  String? sessionId;
  String? type;
  String? sender;
  String? message;
  List<String>? refImage;
  List<ImageModel>? images;
  List<String>? parentImage;
  DateTime? createdAt;

  Message({
    this.id,
    this.sessionId,
    this.type,
    this.sender,
    this.message,
    this.refImage,
    this.images,
    this.parentImage,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["_id"],
        sessionId: json["sessionId"],
        type: json["type"],
        sender: json["sender"],
        message: json["message"],
        refImage: json["refImage"] == null
            ? []
            : List<String>.from(json["refImage"]!.map((x) => x)),
        images: json["images"] == null
            ? []
            : List<ImageModel>.from(
                json["images"]!.map((x) => ImageModel.fromJson(x))),
        parentImage: json["parentImage"] == null
            ? []
            : List<String>.from(json["parentImage"]!.map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "sessionId": sessionId,
        "type": type,
        "sender": sender,
        "message": message,
        "refImage":
            refImage == null ? [] : List<String>.from(refImage!.map((x) => x)),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "parentImage": parentImage == null
            ? []
            : List<String>.from(parentImage!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
      };
}

class ImageModel {
  String? filename;
  String? text;

  ImageModel({
    this.filename,
    this.text,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
        filename: json["filename"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "filename": filename,
        "text": text,
      };
}
