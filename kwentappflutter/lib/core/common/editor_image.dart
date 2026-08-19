import 'dart:typed_data';

sealed class EditorImage {
  const EditorImage();
}

class ExistingImage extends EditorImage {
  const ExistingImage({required this.id, required this.url});

  final String id;
  final String url;
}

class NewImage extends EditorImage {
  const NewImage(this.bytes);

  final Uint8List bytes;
}

extension EditorImageList on List<EditorImage> {
  List<String> get keptImageIds =>
      whereType<ExistingImage>().map((image) => image.id).toList();

  List<Uint8List> get newImageBytes =>
      whereType<NewImage>().map((image) => image.bytes).toList();
}
