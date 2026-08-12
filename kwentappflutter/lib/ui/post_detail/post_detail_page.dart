import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      icon: Icons.menu_book_outlined,
      title: 'Kwento $postId',
      arrivesOn: 'Gallery and comments arrive on Day 6.',
      appBar: AppBar(title: const Text('Kwento')),
    );
  }
}
