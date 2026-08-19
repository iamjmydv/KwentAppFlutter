import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:kwentappflutter/core/utils/image_bytes.dart';

class PickedImages {
  const PickedImages({this.images = const [], this.skipped = false});

  final List<Uint8List> images;
  final bool skipped;

  bool get isEmpty => images.isEmpty;
}

Future<PickedImages> pickImages({required int slots}) async {
  if (slots <= 0) return const PickedImages(skipped: true);

  final files = await ImagePicker().pickMultiImage();
  if (files.isEmpty) return const PickedImages();

  final accepted = <Uint8List>[];
  var skipped = false;

  for (final file in files) {
    if (accepted.length >= slots) {
      skipped = true;
      continue;
    }

    final bytes = await file.readAsBytes();

    if (bytes.lengthInBytes > Constants.maxImageBytes ||
        imageExtensionFor(bytes) == null) {
      skipped = true;
      continue;
    }

    accepted.add(bytes);
  }

  return PickedImages(images: accepted, skipped: skipped);
}
