// To parse this JSON data, do
//
//     final quotationChatHistoryModel = quotationChatHistoryModelFromJson(jsonString);

import 'dart:convert';

QuotationChatHistoryModel quotationChatHistoryModelFromJson(String str) =>
    QuotationChatHistoryModel.fromJson(json.decode(str));

String quotationChatHistoryModelToJson(QuotationChatHistoryModel data) =>
    json.encode(data.toJson());

class QuotationChatHistoryModel {
  bool? success;
  String? message;
  Data? data;

  QuotationChatHistoryModel({
    this.success,
    this.message,
    this.data,
  });

  QuotationChatHistoryModel copyWith({
    bool? success,
    String? message,
    Data? data,
  }) =>
      QuotationChatHistoryModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory QuotationChatHistoryModel.fromJson(Map<String, dynamic> json) =>
      QuotationChatHistoryModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  List<Item>? items;
  int? total;
  int? page;
  int? limit;
  DateTime? timestampDate;

  Data({
    this.items,
    this.total,
    this.page,
    this.limit,
    this.timestampDate,
  });

  Data copyWith({
    List<Item>? items,
    int? total,
    int? page,
    int? limit,
    DateTime? timestampDate,
  }) =>
      Data(
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        limit: limit ?? this.limit,
        timestampDate: timestampDate ?? this.timestampDate,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        timestampDate: json["timestampDate"] == null
            ? null
            : DateTime.parse(json["timestampDate"]),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "limit": limit,
        "timestampDate": timestampDate?.toIso8601String(),
      };
}

class Item {
  String? id;
  String? quotationId;
  String? sender;
  String? senderId;
  String? message;
  String? messageType;
  String? imageUrl;
  QuotationCardData? quotationCardData;
  UpdatedBySupport? updatedBySupport;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  CardDetail? cardDetail;

  Item({
    this.id,
    this.quotationId,
    this.sender,
    this.senderId,
    this.message,
    this.messageType,
    this.imageUrl,
    this.quotationCardData,
    this.updatedBySupport,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.cardDetail,
  });

  Item copyWith({
    String? id,
    String? quotationId,
    String? sender,
    String? senderId,
    String? message,
    String? messageType,
    String? imageUrl,
    QuotationCardData? quotationCardData,
    UpdatedBySupport? updatedBySupport,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    CardDetail? cardDetail,
  }) =>
      Item(
        id: id ?? this.id,
        quotationId: quotationId ?? this.quotationId,
        sender: sender ?? this.sender,
        senderId: senderId ?? this.senderId,
        message: message ?? this.message,
        messageType: messageType ?? this.messageType,
        imageUrl: imageUrl ?? this.imageUrl,
        quotationCardData: quotationCardData ?? this.quotationCardData,
        updatedBySupport: updatedBySupport ?? this.updatedBySupport,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        v: v ?? this.v,
        cardDetail: cardDetail ?? this.cardDetail,
      );

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["_id"],
        quotationId: json["quotationId"],
        sender: json["sender"],
        senderId: json["senderId"],
        message: json["message"],
        messageType: json["messageType"],
        imageUrl: json["imageUrl"],
        quotationCardData: json["quotationCardData"] == null
            ? null
            : QuotationCardData.fromJson(json["quotationCardData"]),
        updatedBySupport: json["updatedBySupport"] == null
            ? null
            : UpdatedBySupport.fromJson(json["updatedBySupport"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        cardDetail: json["cardDetail"] == null
            ? null
            : CardDetail.fromJson(json["cardDetail"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "quotationId": quotationId,
        "sender": sender,
        "senderId": senderId,
        "message": message,
        "messageType": messageType,
        "imageUrl": imageUrl,
        "quotationCardData": quotationCardData?.toJson(),
        "updatedBySupport": updatedBySupport?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "cardDetail": cardDetail?.toJson(),
      };
}

class CardDetail {
  String? quotationNumber;
  DateTime? date;
  String? color;
  String? material;
  String? sizeMeasurement;
  String? specialRequests;
  String? dressImage;
  int? price;
  String? currency;
  String? status;
  String? purchaseType;
  String? quantity;
  dynamic bulkQuantities;

  CardDetail({
    this.quotationNumber,
    this.date,
    this.color,
    this.material,
    this.sizeMeasurement,
    this.specialRequests,
    this.dressImage,
    this.price,
    this.currency,
    this.status,
    this.purchaseType,
    this.quantity,
    this.bulkQuantities,
  });

  CardDetail copyWith({
    String? quotationNumber,
    DateTime? date,
    String? color,
    String? material,
    String? sizeMeasurement,
    String? specialRequests,
    String? dressImage,
    int? price,
    String? currency,
    String? status,
    String? purchaseType,
    String? quantity,
    dynamic bulkQuantities,
  }) =>
      CardDetail(
        quotationNumber: quotationNumber ?? this.quotationNumber,
        date: date ?? this.date,
        color: color ?? this.color,
        material: material ?? this.material,
        sizeMeasurement: sizeMeasurement ?? this.sizeMeasurement,
        specialRequests: specialRequests ?? this.specialRequests,
        dressImage: dressImage ?? this.dressImage,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        status: status ?? this.status,
        purchaseType: purchaseType ?? this.purchaseType,
        quantity: quantity ?? this.quantity,
        bulkQuantities: bulkQuantities ?? this.bulkQuantities,
      );

  factory CardDetail.fromJson(Map<String, dynamic> json) => CardDetail(
        quotationNumber: json["quotationNumber"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        color: json["color"],
        material: json["material"],
        sizeMeasurement: json["sizeMeasurement"],
        specialRequests: json["specialRequests"],
        dressImage: json["dressImage"],
        price: json["price"],
        currency: json["currency"],
        status: json["status"],
        purchaseType: json["purchaseType"],
        quantity: json["quantity"],
        bulkQuantities: json["bulkQuantities"],
      );

  Map<String, dynamic> toJson() => {
        "quotationNumber": quotationNumber,
        "date": date?.toIso8601String(),
        "color": color,
        "material": material,
        "sizeMeasurement": sizeMeasurement,
        "specialRequests": specialRequests,
        "dressImage": dressImage,
        "price": price,
        "currency": currency,
        "status": status,
        "purchaseType": purchaseType,
        "quantity": quantity,
        "bulkQuantities": bulkQuantities,
      };
}

class QuotationCardData {
  String? quotationNumber;
  String? userId;
  String? productId;
  String? purchaseType;
  double? price;
  String? date;
  String? title;
  String? color;
  String? material;
  String? type;
  String? style;
  String? bodyProfiles;
  String? bulkQuantities;
  double? currency;
  String? description;
  String? note;
  String? specialRequests;
  int? quantity;
  String? dressImage;
  String? status;

  QuotationCardData({
    this.quotationNumber,
    this.userId,
    this.productId,
    this.purchaseType,
    this.price,
    this.date,
    this.title,
    this.color,
    this.material,
    this.type,
    this.style,
    this.bodyProfiles,
    this.bulkQuantities,
    this.currency,
    this.description,
    this.note,
    this.specialRequests,
    this.quantity,
    this.dressImage,
    this.status,
  });

  QuotationCardData copyWith({
    String? quotationNumber,
    String? userId,
    String? productId,
    String? purchaseType,
    double? price,
    String? date,
    String? title,
    String? color,
    String? material,
    String? type,
    String? style,
    String? bodyProfiles,
    String? bulkQuantities,
    double? currency,
    String? description,
    String? note,
    String? specialRequests,
    int? quantity,
    String? dressImage,
    String? status,
  }) =>
      QuotationCardData(
        quotationNumber: quotationNumber ?? this.quotationNumber,
        userId: userId ?? this.userId,
        productId: productId ?? this.productId,
        purchaseType: purchaseType ?? this.purchaseType,
        price: price ?? this.price,
        date: date ?? this.date,
        title: title ?? this.title,
        color: color ?? this.color,
        material: material ?? this.material,
        type: type ?? this.type,
        style: style ?? this.style,
        bodyProfiles: bodyProfiles ?? this.bodyProfiles,
        bulkQuantities: bulkQuantities ?? this.bulkQuantities,
        currency: currency ?? this.currency,
        description: description ?? this.description,
        note: note ?? this.note,
        specialRequests: specialRequests ?? this.specialRequests,
        quantity: quantity ?? this.quantity,
        dressImage: dressImage ?? this.dressImage,
        status: status ?? this.status,
      );

  factory QuotationCardData.fromJson(Map<String, dynamic> json) =>
      QuotationCardData(
        quotationNumber: json["quotationNumber"],
        userId: json["userId"],
        productId: json["productId"],
        purchaseType: json["purchaseType"],
        price: json["price"]?.toDouble(),
        date: json["date"],
        title: json["title"],
        color: json["color"],
        material: json["material"],
        type: json["type"],
        style: json["style"],
        bodyProfiles: json["bodyProfiles"],
        bulkQuantities: json["bulkQuantities"],
        currency: json["currency"]?.toDouble(),
        description: json["description"],
        note: json["note"],
        specialRequests: json["specialRequests"],
        quantity: json["quantity"],
        dressImage: json["dressImage"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "quotationNumber": quotationNumber,
        "userId": userId,
        "productId": productId,
        "purchaseType": purchaseType,
        "price": price,
        "date": date,
        "title": title,
        "color": color,
        "material": material,
        "type": type,
        "style": style,
        "bodyProfiles": bodyProfiles,
        "bulkQuantities": bulkQuantities,
        "currency": currency,
        "description": description,
        "note": note,
        "specialRequests": specialRequests,
        "quantity": quantity,
        "dressImage": dressImage,
        "status": status,
      };
}

class UpdatedBySupport {
  String? color;
  String? material;
  String? specialRequests;
  String? note;

  UpdatedBySupport({
    this.color,
    this.material,
    this.specialRequests,
    this.note,
  });

  UpdatedBySupport copyWith({
    String? color,
    String? material,
    String? specialRequests,
    String? note,
  }) =>
      UpdatedBySupport(
        color: color ?? this.color,
        material: material ?? this.material,
        specialRequests: specialRequests ?? this.specialRequests,
        note: note ?? this.note,
      );

  factory UpdatedBySupport.fromJson(Map<String, dynamic> json) =>
      UpdatedBySupport(
        color: json["color"],
        material: json["material"],
        specialRequests: json["specialRequests"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "color": color,
        "material": material,
        "specialRequests": specialRequests,
        "note": note,
      };
}
