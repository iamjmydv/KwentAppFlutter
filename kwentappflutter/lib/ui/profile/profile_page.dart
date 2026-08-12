import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      icon: Icons.person_outline,
      title: Strings.profileTitle,
      arrivesOn: 'Avatar, name and log out arrive on Day 8.',
      appBar: AppBar(title: const Text(Strings.profileTitle)),
    );
  }
}
