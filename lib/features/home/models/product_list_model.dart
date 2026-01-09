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
            : List<Product>.from(
                json["data"]!.map((x) => Product.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };

  /// ✅ copyWith
  ProductListModel copyWith({
    bool? success,
    String? message,
    List<Product>? data,
  }) {
    return ProductListModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class Product {
  String? id;
  String? userId;
  String? title;
  String? image;
  double? minPrice;
  double? maxPrice;
  String? description;
  String? currency;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? userName;
  String? userImage;
  bool? isFollowing;
  bool? isPrivate;

  Product({
    this.id,
    this.userId,
    this.title,
    this.image,
    this.minPrice,
    this.maxPrice,
    this.description,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userName,
    this.userImage,
    this.isFollowing,
    this.isPrivate,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"],
        userId: json["userId"],
        title: json["title"],
        image: json["image"],
        minPrice: double.tryParse(json["minPrice"].toString()),
        maxPrice: double.tryParse(json["maxPrice"].toString()),
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
        isFollowing: json["isFollowing"],
        isPrivate: json["isPrivate"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "title": title,
        "image": image,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
        "description": description,
        "currency": currency,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "userName": userName,
        "userImage": userImage,
        "isFollowing": isFollowing,
        "isPrivate": isPrivate,
      };

  /// ✅ copyWith
  Product copyWith({
    String? id,
    String? userId,
    String? title,
    String? image,
    double? minPrice,
    double? maxPrice,
    String? description,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    String? userName,
    String? userImage,
    bool? isFollowing,
    bool? isPrivate,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      image: image ?? this.image,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      isFollowing: isFollowing ?? this.isFollowing,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
