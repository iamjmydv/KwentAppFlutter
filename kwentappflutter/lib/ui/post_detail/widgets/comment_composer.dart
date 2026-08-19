import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/image_picking.dart';

class CommentComposer extends StatefulWidget {
  const CommentComposer({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final Future<String?> Function(String body, List<Uint8List> images) onSubmit;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();
  final _images = <EditorImage>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _attach() async {
    final slots = Constants.maxImagesPerComment - _images.length;

    if (slots <= 0) {
      CommonSnackbar.show(
        context,
        Strings.imageLimit(Constants.maxImagesPerComment),
      );
      return;
    }

    final picked = await pickImages(slots: slots);
    if (!mounted) return;

    if (picked.images.isNotEmpty) {
      setState(() {
        _images.addAll(picked.images.map(NewImage.new));
      });
    }

    if (picked.skipped) {
      CommonSnackbar.show(context, Strings.someImagesSkipped);
    }
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();

    if (body.isEmpty) {
      CommonSnackbar.show(context, Strings.commentRequired);
      return;
    }

    final message = await widget.onSubmit(body, _images.newImageBytes);
    if (!mounted) return;

    if (message != null) {
      CommonSnackbar.showError(context, message);
      return;
    }

    setState(() {
      _controller.clear();
      _images.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !widget.isSubmitting,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: Strings.joinKwentuhan,
                  suffixIcon: IconButton(
                    onPressed: widget.isSubmitting ? null : _attach,
                    tooltip: Strings.attachImages,
                    icon: const Icon(Icons.photo_outlined, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: widget.isSubmitting ? null : _submit,
                child: widget.isSubmitting
                    ? CommonLoader(
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : const Text(Strings.post),
              ),
            ),
          ],
        ),
        if (_images.isNotEmpty)
          ImagePickerRow(
            images: _images,
            enabled: !widget.isSubmitting,
            maxImages: Constants.maxImagesPerComment,
            tileSize: 64,
            onRemove: (index) => setState(() => _images.removeAt(index)),
          ),
      ],
    );
  }
}
