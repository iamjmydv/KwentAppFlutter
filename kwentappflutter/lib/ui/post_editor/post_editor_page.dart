import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';

class PostEditorPage extends StatelessWidget {
  const PostEditorPage({super.key, this.postId});

  final String? postId;

  bool get isEditing => postId != null;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      icon: Icons.edit_note_outlined,
      title: isEditing ? Strings.editKwento : Strings.newKwento,
      arrivesOn: 'The image editor arrives on Day 7.',
      appBar: AppBar(
        title: Text(isEditing ? Strings.editKwento : Strings.newKwento),
      ),
    );
  }
}
