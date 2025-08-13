import 'package:ai_fashion/features/home/models/outfit_card_model.dart';
import 'package:get/get.dart';

class SkippedController extends GetxController {
  final RxList<OutfitCardModel> skippedOutfitCardModels = <OutfitCardModel>[
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
}
