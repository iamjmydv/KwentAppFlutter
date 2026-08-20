import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/editor_image.dart';
import 'package:kwentappflutter/core/common/image_thumbnail.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';

class ImagePickerRow extends StatelessWidget {
  const ImagePickerRow({
    super.key,
    required this.images,
    required this.onRemove,
    this.onAdd,
    this.maxImages,
    this.tileSize = 80,
    this.enabled = true,
    this.markNew = false,
    this.showCounter = true,
  });

  final List<EditorImage> images;
  final ValueChanged<int> onRemove;
  final VoidCallback? onAdd;
  final int? maxImages;
  final double tileSize;
  final bool enabled;
  final bool markNew;
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAdd =
        onAdd != null &&
        enabled &&
        (maxImages == null || images.length < maxImages!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: tileSize + AppSpacing.sm,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            itemCount: images.length + (canAdd ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == images.length) {
                return _AddTile(size: tileSize, onTap: onAdd!);
              }

              return ImageThumbnail(
                image: images[index],
                width: tileSize,
                height: tileSize,
                markNew: markNew,
                onRemove: enabled ? () => onRemove(index) : null,
              );
            },
          ),
        ),
        if (showCounter && maxImages != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${images.length}/${maxImages!}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: theme.colorScheme.outline),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            Strings.addImage,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
