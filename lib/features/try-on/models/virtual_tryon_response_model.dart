class VirtualTryOnResponseModel {
  final String? status;
  final String? resultImageUrl;
  final String? textResponse;
  final SavedFilenames? savedFilenames;

  VirtualTryOnResponseModel({
    this.status,
    this.resultImageUrl,
    this.textResponse,
    this.savedFilenames,
  });

  factory VirtualTryOnResponseModel.fromJson(Map<String, dynamic> json) {
    return VirtualTryOnResponseModel(
      status: json['status'] as String?,
      resultImageUrl: json['result_image_url'] as String?,
      textResponse: json['text_response'] as String?,
      savedFilenames: json['saved_filenames'] != null
          ? SavedFilenames.fromJson(
              json['saved_filenames'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SavedFilenames {
  final String? person;
  final String? product;
  final String? result;

  SavedFilenames({this.person, this.product, this.result});

  factory SavedFilenames.fromJson(Map<String, dynamic> json) {
    return SavedFilenames(
      person: json['person'] as String?,
      product: json['product'] as String?,
      result: json['result'] as String?,
    );
  }
}
