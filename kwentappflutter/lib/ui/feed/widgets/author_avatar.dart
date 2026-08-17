import 'package:flutter/material.dart';
import 'package:kwentappflutter/data/models/profile.dart';

class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({super.key, required this.profile, this.radius = 14});

  final Profile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = profile.avatarUrl;
    final hasImage = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      foregroundImage: hasImage ? NetworkImage(url) : null,
      child: Text(
        _initials(profile.name),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();

    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
