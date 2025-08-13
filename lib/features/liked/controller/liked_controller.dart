import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/home/models/outfit_card_model.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LikedController extends GetxController {
  var currentCarouselIndex = 0.obs;
  final RxList<OutfitCardModel> remixOutfits = <OutfitCardModel>[].obs;

  final RxList<OutfitCardModel> likedOutfitCardModels = <OutfitCardModel>[
    OutfitCardModel(
      imageUrl:
          "https://framerusercontent.com/images/ioTL88ZpHCWXDdmKwFbhBBMJfA.png",
      title: "The Midnight Monochrome Street Set",
    ),
    OutfitCardModel(
      imageUrl:
          "https://framerusercontent.com/images/EDnff5CDaVTXO7iJhG2jmUWgJos.png",
      title: "The Sandstone Explorer Co-Ord",
    ),
    OutfitCardModel(
      imageUrl:
          "https://framerusercontent.com/images/497wrI6QPtcqc9q1y7a7kdGc.png",
      title: "The Urban Ash Layered Look",
    ),
    OutfitCardModel(
      imageUrl:
          "https://framerusercontent.com/images/uwRHxl9xBPMQcwC7g6f5k6z5o.png",
      title: "The Crimson Bolt Street Set",
    ),
    OutfitCardModel(
      imageUrl:
          "https://framerusercontent.com/images/0cz3vf6fEsEb13ulylzz3lTR4.png",
      title: "The Ivory Mocha Luxe Dress",
    ),
  ].obs;

  // Method to add current carousel item to remix outfits
  void addToRemix(CarouselSliderController carouselController) {
    if (likedOutfitCardModels.isNotEmpty &&
        currentCarouselIndex.value < likedOutfitCardModels.length) {
      final currentOutfit = likedOutfitCardModels[currentCarouselIndex.value];

      // Avoid duplicates
      if (!remixOutfits
          .any((outfit) => outfit.imageUrl == currentOutfit.imageUrl)) {
        remixOutfits.add(currentOutfit);
      } else {
        toast("Already in Remix");
      }

      // Move to next index
      if (currentCarouselIndex.value < likedOutfitCardModels.length - 1) {
        currentCarouselIndex.value++;
        carouselController.animateToPage(
          currentCarouselIndex.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (currentCarouselIndex.value ==
          likedOutfitCardModels.length - 1) {
        currentCarouselIndex.value = 0;
        carouselController.animateToPage(
          currentCarouselIndex.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
