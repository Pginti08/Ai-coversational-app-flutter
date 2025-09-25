// To parse this JSON data, do
//
//     final sessionsModel = sessionsModelFromJson(jsonString);

import 'dart:convert';

SessionsModel sessionsModelFromJson(String str) =>
    SessionsModel.fromJson(json.decode(str));

String sessionsModelToJson(SessionsModel data) => json.encode(data.toJson());

class SessionsModel {
  String? status;
  String? message;
  Data? data;

  SessionsModel({
    this.status,
    this.message,
    this.data,
  });

  factory SessionsModel.fromJson(Map<String, dynamic> json) => SessionsModel(
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
  List<Session>? items;
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
            : List<Session>.from(
                json["items"]!.map((x) => Session.fromJson(x))),
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

class Session {
  String? id;
  String? userId;
  UserDetails? userDetails;
  dynamic image;
  String? firstMessage;
  String? lastMessage;
  DateTime? createdAt;
  DateTime? updatedAt;

  Session({
    this.id,
    this.userId,
    this.userDetails,
    this.image,
    this.firstMessage,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json["_id"],
        userId: json["userId"],
        userDetails: json["userDetails"] == null
            ? null
            : UserDetails.fromJson(json["userDetails"]),
        image: json["image"],
        firstMessage: json["firstMessage"],
        lastMessage: json["lastMessage"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "userDetails": userDetails?.toJson(),
        "image": image,
        "firstMessage": firstMessage,
        "lastMessage": lastMessage,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class UserDetails {
  UserDetails();

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails();

  Map<String, dynamic> toJson() => {};
}
