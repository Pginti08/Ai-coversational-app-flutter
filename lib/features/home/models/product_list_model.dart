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
  String? thumbnail;
  double? minPrice;
  double? maxPrice;
  String? description;
  String? type;
  String? color;
  String? material;
  String? currency;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? name;
  String? username;
  String? userImage;
  bool? isFollowing;
  bool? isPrivate;
  bool? isLiked;
  int? likesCount;

  Product({
    this.id,
    this.userId,
    this.title,
    this.image,
    this.thumbnail,
    this.minPrice,
    this.maxPrice,
    this.description,
    this.type,
    this.color,
    this.material,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.name,
    this.username,
    this.userImage,
    this.isFollowing,
    this.isPrivate,
    this.isLiked,
    this.likesCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"],
        userId: json["userId"],
        title: json["title"],
        image: json["image"],
        thumbnail: json["thumbnail"],
        minPrice: double.tryParse(json["minPrice"].toString()),
        maxPrice: double.tryParse(json["maxPrice"].toString()),
        description: json["description"],
        type: json["type"],
        color: json["color"],
        material: json["material"],
        currency: json["currency"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: int.tryParse(json["__v"].toString()),
        name: json["name"],
        username: json["username"],
        userImage: json["userImage"],
        isFollowing: json["isFollowing"],
        isPrivate: json["isPrivate"],
        isLiked: json["isLiked"] ?? (json["interaction"] == "like"),
        likesCount: int.tryParse(
            json["likesCount"]?.toString() ?? json["likes"]?.toString() ?? "0"),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "title": title,
        "image": image,
        "thumbnail": thumbnail,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
        "description": description,
        "type": type,
        "color": color,
        "material": material,
        "currency": currency,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "name": name,
        "username": username,
        "userImage": userImage,
        "isFollowing": isFollowing,
        "isPrivate": isPrivate,
        "isLiked": isLiked,
        "likesCount": likesCount,
      };

  /// ✅ copyWith
  Product copyWith({
    String? id,
    String? userId,
    String? title,
    String? image,
    String? thumbnail,
    double? minPrice,
    double? maxPrice,
    String? description,
    String? type,
    String? color,
    String? material,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    String? name,
    String? username,
    String? userImage,
    bool? isFollowing,
    bool? isPrivate,
    bool? isLiked,
    int? likesCount,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      image: image ?? this.image,
      thumbnail: thumbnail ?? this.thumbnail,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      description: description ?? this.description,
      type: type ?? this.type,
      color: color ?? this.color,
      material: material ?? this.material,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      name: name ?? this.name,
      username: username ?? this.username,
      userImage: userImage ?? this.userImage,
      isFollowing: isFollowing ?? this.isFollowing,
      isPrivate: isPrivate ?? this.isPrivate,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
