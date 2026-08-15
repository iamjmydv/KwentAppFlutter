import 'package:flutter/material.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/config/supabase_config.dart';
import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ConnectionStatus { checking, connected, notConfigured, unreachable }

class ConnectionCheckPage extends StatefulWidget {
  const ConnectionCheckPage({super.key});

  @override
  State<ConnectionCheckPage> createState() => _ConnectionCheckPageState();
}

class _ConnectionCheckPageState extends State<ConnectionCheckPage> {
  var _status = ConnectionStatus.checking;
  String? _detail;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _status = ConnectionStatus.checking;
      _detail = null;
    });

    if (!SupabaseConfig.isConfigured) {
      setState(() {
        _status = ConnectionStatus.notConfigured;
        _detail = Strings.supabaseNotConfiguredDetail;
      });
      return;
    }

    try {
      await Supabase.instance.client
          .from(Keys.postsTable)
          .select(Keys.id)
          .limit(1);

      if (!mounted) return;
      setState(() {
        _status = ConnectionStatus.connected;
        _detail = Strings.supabaseConnectedDetail;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = ConnectionStatus.unreachable;
        _detail = error.toString();
      });
    }
  }

  (IconData, Color, String) _presentation(ThemeData theme) {
    return switch (_status) {
      ConnectionStatus.checking => (
          Icons.sync,
          theme.colorScheme.onSurfaceVariant,
          Strings.checkingConnection,
        ),
      ConnectionStatus.connected => (
          Icons.check_circle_outline,
          theme.colorScheme.primary,
          Strings.supabaseConnected,
        ),
      ConnectionStatus.notConfigured => (
          Icons.settings_outlined,
          theme.colorScheme.onSurfaceVariant,
          Strings.supabaseNotConfigured,
        ),
      ConnectionStatus.unreachable => (
          Icons.error_outline,
          theme.colorScheme.error,
          Strings.supabaseUnreachable,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, headline) = _presentation(theme);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.connectionCheckTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.contentMaxWidth,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_status == ConnectionStatus.checking)
                        const CommonLoader()
                      else
                        Icon(icon, size: 40, color: color),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (_detail != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _detail!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      CommonPrimaryButton(
                        label: Strings.recheck,
                        onPressed: _check,
                        isLoading: _status == ConnectionStatus.checking,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
