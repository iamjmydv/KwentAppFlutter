import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/editor_image.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';

class ImageThumbnail extends StatelessWidget {
  const ImageThumbnail({
    super.key,
    required this.image,
    this.width = 80,
    this.height = 80,
    this.onRemove,
    this.markNew = false,
  });

  final EditorImage image;
  final double width;
  final double height;
  final VoidCallback? onRemove;
  final bool markNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = markNew && image is NewImage;

    final picture = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: SizedBox(
        width: width,
        height: height,
        child: switch (image) {
          ExistingImage(:final url) => Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
            errorBuilder: (context, error, stack) => _Broken(theme: theme),
          ),
          NewImage(:final bytes) => Image.memory(bytes, fit: BoxFit.cover),
        },
      ),
    );

    final framed = isNew
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.field),
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: picture,
          )
        : picture;

    if (onRemove == null && !isNew) return framed;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        framed,
        if (isNew)
          Positioned(
            bottom: AppSpacing.xs,
            left: AppSpacing.xs,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Text(
                  Strings.newImageBadge,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        if (onRemove != null)
          Positioned(
            top: -6,
            right: -6,
            child: Tooltip(
              message: Strings.removeImage,
              child: InkResponse(
                onTap: onRemove,
                radius: 18,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Broken extends StatelessWidget {
  const _Broken({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
