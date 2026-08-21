import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/config/supabase_config.dart';
import 'package:kwentappflutter/core/di/app_providers.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_router.dart';
import 'package:kwentappflutter/core/theme/app_scroll_behavior.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/url_strategy.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/connection_check/connection_check_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  if (!SupabaseConfig.isConfigured) {
    runApp(const KwentappUnconfiguredApp());
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(KwentappApp(client: Supabase.instance.client));
}

class KwentappApp extends StatelessWidget {
  const KwentappApp({super.key, required this.client});

  final SupabaseClient client;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(client),
      child: const _KwentappRouterApp(),
    );
  }
}

class _KwentappRouterApp extends StatefulWidget {
  const _KwentappRouterApp();

  @override
  State<_KwentappRouterApp> createState() => _KwentappRouterAppState();
}

class _KwentappRouterAppState extends State<_KwentappRouterApp> {
  late final GoRouter _router = createRouter(context.read<AuthViewModel>());

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
      scrollBehavior: const AppScrollBehavior(),
    );
  }
}

class KwentappUnconfiguredApp extends StatelessWidget {
  const KwentappUnconfiguredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const ConnectionCheckPage(),
      scrollBehavior: const AppScrollBehavior(),
    );
  }
}
