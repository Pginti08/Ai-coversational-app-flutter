import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/features/try-on/models/virtual_tryon_response_model.dart';

class TryOnPreviewController extends GetxController {
  late final String personImagePath;
  late final String productImageUrl;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final tryOnResult = Rxn<VirtualTryOnResponseModel>();

  @override
  void onInit() {
    super.onInit();
    personImagePath = Get.arguments['personImage'] as String;
    productImageUrl = Get.arguments['productImage'] as String;
    generateTryOn();
  }

  Future<void> generateTryOn() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final personFile = File(personImagePath);
      final personFileName = personFile.path.split('/').last;

      // Build form data with person image as binary file
      final formData = FormData.fromMap({
        'person_image': await MultipartFile.fromFile(
          personFile.path,
          filename: personFileName,
        ),
        'product_image': await MultipartFile.fromFile(
          await _downloadToTempFile(productImageUrl),
          filename: 'product_image.png',
        ),
      });

      final result = await NetworkClient.instance.callApi(
        ApiConstants.virtualTryOn,
        MethodType.post,
        baseUrlType: BaseUrl.chat,
        params: formData,
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      );

      if (result.isSuccess && result.data?.data != null) {
        final response = VirtualTryOnResponseModel.fromJson(result.data!.data);
        if (response.status == 'success' && response.resultImageUrl != null) {
          tryOnResult.value = response;
        } else {
          errorMessage.value =
              response.textResponse ?? 'Failed to generate try-on image';
        }
      } else {
        errorMessage.value = result.error ?? 'Something went wrong';
      }
    } catch (e) {
      debugPrint('Try-on error: $e');
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Downloads a network image to a temp file to send as multipart
  Future<String> _downloadToTempFile(String url) async {
    final dio = Dio();
    final tempDir = Directory.systemTemp;
    final tempFile = File(
        '${tempDir.path}/tryon_product_${DateTime.now().millisecondsSinceEpoch}.png');
    await dio.download(url, tempFile.path);
    return tempFile.path;
  }
}
