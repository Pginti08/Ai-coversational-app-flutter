// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

OrderModel orderModelFromJson(String str) =>
    OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  String? type;
  Data? data;
  DateTime? timestamp;

  OrderModel({
    this.type,
    this.data,
    this.timestamp,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        type: json["type"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
        "timestamp": timestamp?.toIso8601String(),
      };
}

class Data {
  List<OrderItem>? orderItems;
  Pagination? pagination;

  Data({
    this.orderItems,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderItems: json["orderItems"] == null
            ? []
            : List<OrderItem>.from(
                json["orderItems"]!.map((x) => OrderItem.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "orderItems": orderItems == null
            ? []
            : List<dynamic>.from(orderItems!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class OrderItem {
  String? id;
  String? orderId;
  String? quotationCardId;
  dynamic productId;
  int? quantity;
  double? price;
  dynamic trackingId;
  String? itemStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  Order? order;
  QuotationCard? quotationCard;
  List<String>? images;

  OrderItem({
    this.id,
    this.orderId,
    this.quotationCardId,
    this.productId,
    this.quantity,
    this.price,
    this.trackingId,
    this.itemStatus,
    this.createdAt,
    this.updatedAt,
    this.order,
    this.quotationCard,
    this.images,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["orderId"],
        quotationCardId: json["quotationCardId"],
        productId: json["productId"],
        quantity: json["quantity"],
        price: double.tryParse(json["price"].toString()),
        trackingId: json["trackingId"],
        itemStatus: json["itemStatus"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        quotationCard: json["quotationCard"] == null
            ? null
            : QuotationCard.fromJson(json["quotationCard"]),
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "orderId": orderId,
        "quotationCardId": quotationCardId,
        "productId": productId,
        "quantity": quantity,
        "price": price,
        "trackingId": trackingId,
        "itemStatus": itemStatus,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "order": order?.toJson(),
        "quotationCard": quotationCard?.toJson(),
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
      };
}

class Order {
  String? id;
  String? orderUniqueId;
  String? orderStatus;
  String? paymentStatus;
  String? paymentMode;
  String? addressText;
  double? subTotal;
  double? taxAmount;
  double? shippingCharge;
  double? totalAmount;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.orderUniqueId,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMode,
    this.addressText,
    this.subTotal,
    this.taxAmount,
    this.shippingCharge,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        orderUniqueId: json["orderUniqueId"],
        orderStatus: json["orderStatus"],
        paymentStatus: json["paymentStatus"],
        paymentMode: json["paymentMode"],
        addressText: json["addressText"],
        subTotal: double.tryParse(json["subTotal"].toString()),
        taxAmount: double.tryParse(json["taxAmount"].toString()),
        shippingCharge: double.tryParse(json["shippingCharge"].toString()),
        totalAmount: double.tryParse(json["totalAmount"].toString()),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "orderUniqueId": orderUniqueId,
        "orderStatus": orderStatus,
        "paymentStatus": paymentStatus,
        "paymentMode": paymentMode,
        "addressText": addressText,
        "subTotal": subTotal,
        "taxAmount": taxAmount,
        "shippingCharge": shippingCharge,
        "totalAmount": totalAmount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class QuotationCard {
  String? title;
  String? material;
  String? color;
  String? dressImage;
  String? quotationNumber;

  QuotationCard({
    this.title,
    this.material,
    this.color,
    this.dressImage,
    this.quotationNumber,
  });

  factory QuotationCard.fromJson(Map<String, dynamic> json) => QuotationCard(
        title: json["title"],
        material: json["material"],
        color: json["color"],
        dressImage: json["dressImage"],
        quotationNumber: json["quotationNumber"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "material": material,
        "color": color,
        "dressImage": dressImage,
        "quotationNumber": quotationNumber,
      };
}

class Pagination {
  int? page;
  int? limit;
  int? total;

  Pagination({
    this.page,
    this.limit,
    this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
      };
}
