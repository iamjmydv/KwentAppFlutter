import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/image_picking.dart';
import 'package:kwentappflutter/core/utils/time_ago.dart';
import 'package:kwentappflutter/data/models/comment.dart';

class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.isOwn,
    required this.isBusy,
    required this.onSave,
    required this.onDelete,
  });

  final Comment comment;
  final bool isOwn;
  final bool isBusy;
  final Future<String?> Function(
    String body,
    List<String> keptImageIds,
    List<Uint8List> newImages,
  )
  onSave;
  final Future<String?> Function() onDelete;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  final _controller = TextEditingController();
  final _images = <EditorImage>[];
  var _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.comment.body;
      _images
        ..clear()
        ..addAll(
          widget.comment.images.map(
            (image) => ExistingImage(id: image.id, url: image.url),
          ),
        );
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _images.clear();
    });
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
      setState(() => _images.addAll(picked.images.map(NewImage.new)));
    }

    if (picked.skipped) {
      CommonSnackbar.show(context, Strings.someImagesSkipped);
    }
  }

  Future<void> _save() async {
    final body = _controller.text.trim();

    if (body.isEmpty) {
      CommonSnackbar.show(context, Strings.commentRequired);
      return;
    }

    final message = await widget.onSave(
      body,
      _images.keptImageIds,
      _images.newImageBytes,
    );
    if (!mounted) return;

    if (message != null) {
      CommonSnackbar.showError(context, message);
      return;
    }

    _cancelEditing();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await CommonConfirmDialog.show(
      context,
      title: Strings.deleteCommentTitle,
      message: Strings.deleteCommentMessage,
      confirmLabel: Strings.delete,
    );

    if (!confirmed || !mounted) return;

    final message = await widget.onDelete();
    if (!mounted || message == null) return;

    CommonSnackbar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comment = widget.comment;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorAvatar(profile: comment.author),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.isOwn
                            ? Strings.nameWithYou(comment.author.name)
                            : comment.author.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      timeAgo(comment.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (_isEditing) _editor(theme) else _content(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(ThemeData theme) {
    final comment = widget.comment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(comment.body, style: theme.textTheme.bodyMedium),
        if (comment.images.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final image in comment.images)
                ImageThumbnail(
                  image: ExistingImage(id: image.id, url: image.url),
                  width: 100,
                  height: 70,
                ),
            ],
          ),
        ],
        if (widget.isOwn) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _Action(
                label: Strings.edit,
                onPressed: widget.isBusy ? null : _startEditing,
              ),
              const SizedBox(width: AppSpacing.md),
              _Action(
                label: Strings.delete,
                color: theme.colorScheme.error,
                onPressed: widget.isBusy ? null : _confirmDelete,
              ),
              if (widget.isBusy) ...[
                const SizedBox(width: AppSpacing.md),
                const CommonLoader(size: 14),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _editor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: !widget.isBusy,
          minLines: 2,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: widget.isBusy ? null : _attach,
              tooltip: Strings.attachImages,
              icon: const Icon(Icons.photo_outlined, size: 20),
            ),
          ),
        ),
        if (_images.isNotEmpty)
          ImagePickerRow(
            images: _images,
            enabled: !widget.isBusy,
            maxImages: Constants.maxImagesPerComment,
            tileSize: 64,
            onRemove: (index) => setState(() => _images.removeAt(index)),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            FilledButton(
              onPressed: widget.isBusy ? null : _save,
              child: widget.isBusy
                  ? CommonLoader(size: 16, color: theme.colorScheme.onPrimary)
                  : const Text(Strings.save),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: widget.isBusy ? null : _cancelEditing,
              child: const Text(Strings.cancel),
            ),
          ],
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, this.color, required this.onPressed});

  final String label;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color ?? theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
