// To parse this JSON data, do
//
//     final userDetailModel = userDetailModelFromJson(jsonString);

import 'dart:convert';

UserDetailModel userDetailModelFromJson(String str) =>
    UserDetailModel.fromJson(json.decode(str));

String userDetailModelToJson(UserDetailModel data) =>
    json.encode(data.toJson());

class UserDetailModel {
  bool? success;
  String? message;
  Data? data;

  UserDetailModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) =>
      UserDetailModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };

  // ✅ copyWith method
  UserDetailModel copyWith({
    bool? success,
    String? message,
    Data? data,
  }) {
    return UserDetailModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class Data {
  String? id;
  String? name;
  String? countryCode;
  String? phone;
  String? role;
  String? image;
  String? bio;
  bool? hasSeenGuide;
  int? followersCount;
  int? followingCount;
  int? productsCount;
  int? swipeCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isFollowing;

  Data({
    this.id,
    this.name,
    this.countryCode,
    this.phone,
    this.role,
    this.image,
    this.bio,
    this.hasSeenGuide,
    this.followersCount,
    this.followingCount,
    this.productsCount,
    this.swipeCount,
    this.createdAt,
    this.updatedAt,
    this.isFollowing,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      id: json["id"],
      name: json["name"],
      countryCode: json["countryCode"],
      phone: json["phone"],
      role: json["role"],
      image: json["image"],
      bio: json["bio"],
      hasSeenGuide: json["hasSeenGuide"],
      followersCount: json["followersCount"],
      followingCount: json["followingCount"],
      productsCount: json["productsCount"],
      swipeCount: json["swipeCount"],
      createdAt:
          json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      updatedAt:
          json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      isFollowing: json["isFollowing"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "countryCode": countryCode,
        "phone": phone,
        "role": role,
        "image": image,
        "bio": bio,
        "hasSeenGuide": hasSeenGuide,
        "followersCount": followersCount,
        "followingCount": followingCount,
        "productsCount": productsCount,
        "swipeCount": swipeCount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "isFollowing": isFollowing
      };

  // ✅ copyWith method
  Data copyWith(
      {String? id,
      String? name,
      String? countryCode,
      String? phone,
      String? role,
      String? image,
      String? bio,
      bool? hasSeenGuide,
      int? followersCount,
      int? followingCount,
      int? productsCount,
      int? swipeCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool? isFollowing}) {
    return Data(
        id: id ?? this.id,
        name: name ?? this.name,
        countryCode: countryCode ?? this.countryCode,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        image: image ?? this.image,
        bio: bio ?? this.bio,
        hasSeenGuide: hasSeenGuide ?? this.hasSeenGuide,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        productsCount: productsCount ?? this.productsCount,
        swipeCount: swipeCount ?? this.swipeCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isFollowing: isFollowing ?? this.isFollowing);
  }
}
