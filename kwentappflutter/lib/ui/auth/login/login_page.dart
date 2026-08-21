import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/validators.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/auth/auth_form_state.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final auth = context.read<AuthViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final result = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    switch (result) {
      case AuthFormSucceeded(:final message):
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        auth.resetForm();
        router.go(AppRoutes.feed);

      case AuthFormFailed(:final message):
        if (!mounted) return;
        await CommonErrorDialog.show(
          context,
          title: Strings.signInFailedTitle,
          message: message,
        );
        if (!mounted) return;
        auth.resetForm();
        _refocusPassword();

      case AuthFormIdle() || AuthFormSubmitting():
        break;
    }
  }

  void _refocusPassword() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _passwordController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _passwordController.text.length,
      );
      FocusScope.of(context).requestFocus(_passwordFocus);
    });
  }

  void _goToRegister() => context.go(AppRoutes.register);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.contentMaxWidth,
                ),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          Strings.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          Strings.welcomeBack,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(Strings.tagline, style: theme.textTheme.bodySmall),
                        const SizedBox(height: AppSpacing.xl),
                        CommonTextField(
                          controller: _emailController,
                          label: Strings.emailLabel,
                          hint: Strings.emailHint,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CommonPasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: Strings.passwordLabel,
                          validator: (value) => Validators.notEmpty(
                            value,
                            Strings.passwordRequired,
                          ),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CommonPrimaryButton(
                          label: Strings.signIn,
                          onPressed: _submit,
                          isLoading: context.watch<AuthViewModel>().isBusy,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Strings.noAccountYet,
                              style: theme.textTheme.bodySmall,
                            ),
                            TextButton(
                              onPressed: _goToRegister,
                              child: const Text(Strings.signUp),
                            ),
                          ],
                        ),
                      ],
                    ),
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
