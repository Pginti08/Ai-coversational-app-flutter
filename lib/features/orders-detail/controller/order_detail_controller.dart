import 'dart:typed_data';

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/orders-detail/models/order_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:get/get.dart';

class OrderDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  String orderId = "";

  final Rx<OrderDetailModel> orderDetailModel = OrderDetailModel().obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["orderId"] != null) {
      orderId = Get.arguments["orderId"];
    }
    getOrderDetail();
    super.onInit();
  }

  Future<void> getOrderDetail() async {
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.orders}/$orderId",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        orderDetailModel.value = OrderDetailModel.fromJson(result.data?.data);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadPdf() async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.orders}/$orderId${ApiConstants.invoice}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
        responseType: ResponseType.bytes, // Important: Tell Dio to expect bytes
      );

      if (result.isSuccess) {
        final responseData = result.data?.data;

        if (responseData != null) {
          Uint8List bytes;

          if (responseData is List<int>) {
            bytes = Uint8List.fromList(responseData);
          } else if (responseData is Uint8List) {
            bytes = responseData;
          } else {
            throw Exception(
                'Unexpected response type: ${responseData.runtimeType}');
          }

          await FlutterFileSaver().writeFileAsBytes(
            fileName: 'invoice_$orderId.pdf',
            bytes: bytes,
          );
          toast("Invoice downloaded successfully!", type: ToastType.success);
        }
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }
}
