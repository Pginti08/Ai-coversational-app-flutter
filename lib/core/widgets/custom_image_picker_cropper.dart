import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<void> imagePickerCropper(Function(File file) selectedImage) async {
  XFile? pickedFile;
  try {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
  } catch (e) {
    debugPrint(e.toString());
  }
  if (pickedFile != null) {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: const Color(0xFF1F8BB5),
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.black,
          navBarLight: true,
          hideBottomControls: false,
          activeControlsWidgetColor: const Color(0xFF1F8BB5),
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
          ],
        ),
      ],
    );
    if (croppedFile != null) {
      selectedImage(File(croppedFile.path));
    }
  } else {
    return;
  }
}

Future<void> imagePicker(Function(File file) selectedImage) async {
  try {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      selectedImage(File(pickedFile.path));
    }
  } catch (e) {
    debugPrint("Image pick error: $e");
  }
}

Future<void> imagePickerMultiple(
  int? limit,
  Function(List<File> files) selectedImages,
) async {
  try {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage(
      imageQuality: 30,
      limit: limit ?? 4,
    );

    if (pickedFiles.isNotEmpty) {
      final files = pickedFiles.map((e) => File(e.path)).toList();
      selectedImages(files);
    }
  } catch (e) {
    debugPrint("Multiple image pick error: $e");
  }
}

Future<void> capturePhoto(Function(File file) capturedImage) async {
  try {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 30, // lower for compression
    );
    if (image != null) {
      capturedImage(File(image.path));
    }
  } catch (e) {
    debugPrint("Camera pick error: $e");
  }
}
