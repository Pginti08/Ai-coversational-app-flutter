import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/home/models/outfit_card_model.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

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
      if (!remixOutfits.any((outfit) => outfit == currentOutfit)) {
        if (remixOutfits.length < 4) {
          remixOutfits.add(currentOutfit);
        } else {
          toast("You can select maximum 4 images in Remix");
        }
      } else {
        toast("Already in Remix");
      }

      // Move to next index
      if (currentCardIndex.value < outfits.length - 1) {
        currentCardIndex.value++;
        cardSwiperController.swipe(CardSwiperDirection.right);
      } else if (currentCardIndex.value == outfits.length - 1) {
        currentCardIndex.value = 0;
        cardSwiperController.swipe(CardSwiperDirection.right);
      }
    }
  }

  // Method to remove from remix outfits (optional)
  void removeFromRemix(OutfitCardModel outfit) {
    remixOutfits.remove(outfit);
  }

  // Method to clear all remix outfits (optional)
  void clearRemixOutfits() {
    remixOutfits.clear();
  }
}
