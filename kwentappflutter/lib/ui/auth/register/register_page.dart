import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      icon: Icons.person_add_outlined,
      title: Strings.createAccount,
      arrivesOn: 'The sign-up form arrives on Day 3.',
      appBar: AppBar(),
    );
  }
}
