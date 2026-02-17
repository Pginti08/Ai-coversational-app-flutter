// To parse this JSON data, do
//
//     final orderDetailModel = orderDetailModelFromJson(jsonString);

import 'dart:convert';

OrderDetailModel orderDetailModelFromJson(String str) =>
    OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) =>
    json.encode(data.toJson());

class OrderDetailModel {
  bool? success;
  String? message;
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
  List<Tracking>? tracking;
  QuotationCard? quotationCard;
  List<String>? images;

  OrderDetailModel({
    this.success,
    this.message,
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
    this.tracking,
    this.quotationCard,
    this.images,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(
        success: json["success"],
        message: json["message"],
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
        tracking: json["tracking"] == null
            ? []
            : List<Tracking>.from(
                json["tracking"]!.map((x) => Tracking.fromJson(x))),
        quotationCard: json["quotationCard"] == null
            ? null
            : QuotationCard.fromJson(json["quotationCard"]),
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
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
        "tracking": tracking == null
            ? []
            : List<dynamic>.from(tracking!.map((x) => x.toJson())),
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
  double? amountDueOnDelivery;
  double? amountCollectedOnDelivery;
  double? walletPaidCU;
  dynamic remarks;
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
    this.amountDueOnDelivery,
    this.amountCollectedOnDelivery,
    this.walletPaidCU,
    this.remarks,
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
        amountDueOnDelivery:
            double.tryParse(json["amountDueOnDelivery"].toString()),
        amountCollectedOnDelivery:
            double.tryParse(json["amountCollectedOnDelivery"].toString()),
        walletPaidCU: double.tryParse(json["walletPaidCU"].toString()),
        remarks: json["remarks"],
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
        "amountDueOnDelivery": amountDueOnDelivery,
        "amountCollectedOnDelivery": amountCollectedOnDelivery,
        "walletPaidCU": walletPaidCU,
        "remarks": remarks,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class QuotationCard {
  String? title;
  dynamic material;
  String? color;
  String? dressImage;
  String? quotationNumber;
  String? purchaseType;
  String? sizeMeasurement;
  dynamic bulkQuantities;

  QuotationCard({
    this.title,
    this.material,
    this.color,
    this.dressImage,
    this.quotationNumber,
    this.purchaseType,
    this.sizeMeasurement,
    this.bulkQuantities,
  });

  factory QuotationCard.fromJson(Map<String, dynamic> json) => QuotationCard(
        title: json["title"],
        material: json["material"],
        color: json["color"],
        dressImage: json["dressImage"],
        quotationNumber: json["quotationNumber"],
        purchaseType: json["purchaseType"],
        sizeMeasurement: json["sizeMeasurement"],
        bulkQuantities: json["bulkQuantities"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "material": material,
        "color": color,
        "dressImage": dressImage,
        "quotationNumber": quotationNumber,
        "purchaseType": purchaseType,
        "sizeMeasurement": sizeMeasurement,
        "bulkQuantities": bulkQuantities,
      };
}

class Tracking {
  String? id;
  String? orderItemId;
  String? status;
  String? notes;
  String? performedBy;
  String? performedByRole;
  DateTime? createdAt;
  DateTime? updatedAt;

  Tracking({
    this.id,
    this.orderItemId,
    this.status,
    this.notes,
    this.performedBy,
    this.performedByRole,
    this.createdAt,
    this.updatedAt,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) => Tracking(
        id: json["id"],
        orderItemId: json["orderItemId"],
        status: json["status"],
        notes: json["notes"],
        performedBy: json["performedBy"],
        performedByRole: json["performedByRole"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "orderItemId": orderItemId,
        "status": status,
        "notes": notes,
        "performedBy": performedBy,
        "performedByRole": performedByRole,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
