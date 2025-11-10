import 'dart:convert';

QuotationChatHistoryModel quotationChatHistoryModelFromJson(String str) =>
    QuotationChatHistoryModel.fromJson(json.decode(str));

String quotationChatHistoryModelToJson(QuotationChatHistoryModel data) =>
    json.encode(data.toJson());

class QuotationChatHistoryModel {
  String? status;
  String? message;
  Data? data;
  DateTime? timestamp;

  QuotationChatHistoryModel({
    this.status,
    this.message,
    this.data,
    this.timestamp,
  });

  factory QuotationChatHistoryModel.fromJson(Map<String, dynamic> json) =>
      QuotationChatHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
        "timestamp": timestamp?.toIso8601String(),
      };

  QuotationChatHistoryModel copyWith({
    String? status,
    String? message,
    Data? data,
    DateTime? timestamp,
  }) =>
      QuotationChatHistoryModel(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
        timestamp: timestamp ?? this.timestamp,
      );
}

class Data {
  List<Message>? items;
  int? total;
  int? page;
  int? limit;
  DateTime? timestamp;

  Data({
    this.items,
    this.total,
    this.page,
    this.limit,
    this.timestamp,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? []
            : List<Message>.from(json["items"].map((x) => Message.fromJson(x))),
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "limit": limit,
        "timestamp": timestamp?.toIso8601String(),
      };

  Data copyWith({
    List<Message>? items,
    int? total,
    int? page,
    int? limit,
    DateTime? timestamp,
  }) =>
      Data(
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        limit: limit ?? this.limit,
        timestamp: timestamp ?? this.timestamp,
      );
}

class Message {
  String? id;
  String? quotationId;
  String? sender;
  String? message;
  String? messageType;
  DateTime? createdAt;
  CardDetail? cardDetail;
  CardDetail? updatedBySupport;

  Message({
    this.id,
    this.quotationId,
    this.sender,
    this.message,
    this.messageType,
    this.createdAt,
    this.cardDetail,
    this.updatedBySupport,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["_id"],
        quotationId: json["quotationId"],
        sender: json["sender"],
        message: json["message"],
        messageType: json["messageType"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        cardDetail: json["cardDetail"] == null
            ? null
            : CardDetail.fromJson(json["cardDetail"]),
        updatedBySupport: json["updatedBySupport"] == null
            ? null
            : CardDetail.fromJson(json["updatedBySupport"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "quotationId": quotationId,
        "sender": sender,
        "message": message,
        "messageType": messageType,
        "createdAt": createdAt?.toIso8601String(),
        "cardDetail": cardDetail?.toJson(),
        "updatedBySupport": updatedBySupport?.toJson(),
      };

  Message copyWith({
    String? id,
    String? quotationId,
    String? sender,
    String? message,
    String? messageType,
    DateTime? createdAt,
    CardDetail? cardDetail,
    CardDetail? updatedBySupport,
  }) =>
      Message(
        id: id ?? this.id,
        quotationId: quotationId ?? this.quotationId,
        sender: sender ?? this.sender,
        message: message ?? this.message,
        messageType: messageType ?? this.messageType,
        createdAt: createdAt ?? this.createdAt,
        cardDetail: cardDetail ?? this.cardDetail,
        updatedBySupport: updatedBySupport ?? this.updatedBySupport,
      );
}

class CardDetail {
  String? quotationNumber;
  String? date;
  String? color;
  String? material;
  String? sizeMeasurement;
  String? specialRequests;
  String? dressImage;
  double? price;
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

  factory CardDetail.fromJson(Map<String, dynamic> json) => CardDetail(
        quotationNumber: json["quotationNumber"],
        date: json["date"],
        color: json["color"],
        material: json["material"],
        sizeMeasurement: json["sizeMeasurement"],
        specialRequests: json["specialRequests"],
        dressImage: json["dressImage"],
        price: double.tryParse(json["price"].toString()),
        currency: json["currency"],
        status: json["status"],
        purchaseType: json["purchaseType"],
        quantity: json["quantity"],
        bulkQuantities: json["bulkQuantities"],
      );

  Map<String, dynamic> toJson() => {
        "quotationNumber": quotationNumber,
        "date": date,
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

  CardDetail copyWith({
    String? quotationNumber,
    String? date,
    String? color,
    String? material,
    String? sizeMeasurement,
    String? specialRequests,
    String? dressImage,
    double? price,
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
}
