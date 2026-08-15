import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/config/supabase_config.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_router.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  runApp(const KwentappApp());
}

class KwentappApp extends StatefulWidget {
  const KwentappApp({super.key});

  @override
  State<KwentappApp> createState() => _KwentappAppState();
}

class _KwentappAppState extends State<KwentappApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
