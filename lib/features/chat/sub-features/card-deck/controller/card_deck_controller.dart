import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/widgets/app_toast.dart';

class CardDeckController extends GetxController {
  RxInt currentCardIndex = 0.obs;
  final CardSwiperController cardSwiperController = CardSwiperController();

  List<String> outfits = [];
  final RxList<String> remixOutfits = <String>[].obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["outfits"] != null) {
      outfits = Get.arguments["outfits"];
    }
    super.onInit();
  }

  // Method to add current carousel item to remix outfits
  void addToRemix() {
    if (outfits.isNotEmpty && currentCardIndex.value < outfits.length) {
      final currentOutfit = outfits[currentCardIndex.value];

      // Avoid duplicates
      if (!remixOutfits.contains(outfits[currentCardIndex.value])) {
        if (remixOutfits.length < 4) {
          remixOutfits.add(currentOutfit);
        }
        // Silently ignore if max limit reached (button is already hidden)
      } else {
        toast("Already in Remix", type: ToastType.warning);
      }
    }
  }

  void removeFromRemix() {
    if (outfits.isNotEmpty && currentCardIndex.value < outfits.length) {
      final currentOutfit = outfits[currentCardIndex.value];

      // Check if the outfit exists in remix
      if (remixOutfits.contains(outfits[currentCardIndex.value])) {
        remixOutfits.remove(currentOutfit);
      }
    }
  }

  // Method to clear all remix outfits (optional)
  void clearRemixOutfits() {
    remixOutfits.clear();
  }
}
