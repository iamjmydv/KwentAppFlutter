import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/validators.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/auth/leave_auth_flow.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final auth = context.read<AuthViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(Strings.accountCreatedMessage)),
        );
      if (mounted) leaveAuthFlow(context);
      return;
    }

    if (!mounted) return;
    await CommonErrorDialog.show(
      context,
      title: Strings.signUpFailedTitle,
      message: auth.errorMessage ?? Strings.genericError,
    );
  }

  void _goToLogin() {
    if (GoRouterState.of(context).extra == AppRoutes.authSiblingExtra) {
      context.pop();
      return;
    }
    context.push(AppRoutes.login, extra: AppRoutes.authSiblingExtra);
  }

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
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          Strings.createAccount,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          Strings.createAccountSubtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CommonTextField(
                          controller: _nameController,
                          label: Strings.nameLabel,
                          hint: Strings.nameHint,
                          validator: (value) => Validators.notEmpty(
                            value,
                            Strings.nameRequired,
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CommonTextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: Strings.emailLabel,
                          hint: Strings.emailHint,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CommonPasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: Strings.passwordLabel,
                          hint: Strings.passwordHint,
                          validator: Validators.password,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CommonPrimaryButton(
                          label: Strings.signUp,
                          onPressed: _submit,
                          isLoading: context.watch<AuthViewModel>().isBusy,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          Strings.termsNote,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Strings.alreadyHaveAccount,
                              style: theme.textTheme.bodySmall,
                            ),
                            TextButton(
                              onPressed: _goToLogin,
                              child: const Text(Strings.signIn),
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
