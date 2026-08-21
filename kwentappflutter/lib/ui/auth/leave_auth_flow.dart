import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';

void leaveAuthFlow(BuildContext context) {
  final navigator = Navigator.of(context);

  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
    return;
  }

  context.go(AppRoutes.feed);
}
