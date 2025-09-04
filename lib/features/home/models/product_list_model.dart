import 'dart:convert';

ProductListModel productModelFromJson(String str) =>
    ProductListModel.fromJson(json.decode(str));

String productModelToJson(ProductListModel data) => json.encode(data.toJson());

class ProductListModel {
  bool? success;
  String? message;
  List<Product>? data;

  ProductListModel({
    this.success,
    this.message,
    this.data,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) =>
      ProductListModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Product>.from(json["data"]!.map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Product {
  String? id;
  String? userId;
  String? title;
  String? image;
  double? price;
  String? description;
  String? currency;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? userName;
  String? userImage;

  Product({
    this.id,
    this.userId,
    this.title,
    this.image,
    this.price,
    this.description,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userName,
    this.userImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"],
        userId: json["userId"],
        title: json["title"],
        image: json["image"],
        price: double.tryParse(json["price"].toString()),
        description: json["description"],
        currency: json["currency"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        userName: json["userName"],
        userImage: json["userImage"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "title": title,
        "image": image,
        "price": price,
        "description": description,
        "currency": currency,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "userName": userName,
        "userImage": userImage,
      };
}
