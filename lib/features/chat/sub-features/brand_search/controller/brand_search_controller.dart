import 'dart:async';

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/chat/models/brands_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class BrandSearchController extends GetxController {
  final RxBool brandLoader = false.obs;
  Timer? _debounce;
  final TextEditingController brandController = TextEditingController();
  final RxList<Brand> searchBrands = <Brand>[].obs;

  Future searchBrandApi(String value) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      try {
        brandLoader.value = true;
        if (brandController.text.trim() != "") {
          var result = await NetworkClient.instance.callApi(
            "${ApiConstants.getBrandList}?search=${value}&page=1&limit=100",
            MethodType.get,
            baseUrlType: BaseUrl.base,
          );

          if (result.isSuccess) {
            brandLoader.value = false;
            var brandsModel = BrandsModel.fromJson(result.data?.data);
            searchBrands.value = brandsModel.data?.brands ?? [];
          } else {
            brandLoader.value = false;
            searchBrands.clear();
            toast(result.error ?? "Failed to load data");
          }
        }
      } catch (e) {
        brandLoader.value = false;
        searchBrands.clear();
      }
    });
  }
}
