import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      icon: Icons.login_outlined,
      title: Strings.welcomeBack,
      arrivesOn: 'The sign-in form arrives on Day 3.',
      appBar: AppBar(),
    );
  }
}
