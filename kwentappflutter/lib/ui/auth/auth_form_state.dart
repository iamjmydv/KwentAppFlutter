sealed class AuthFormState {
  const AuthFormState();
}

class AuthFormIdle extends AuthFormState {
  const AuthFormIdle();
}

class AuthFormSubmitting extends AuthFormState {
  const AuthFormSubmitting();
}

class AuthFormSucceeded extends AuthFormState {
  const AuthFormSucceeded(this.message);

  final String message;
}

class AuthFormFailed extends AuthFormState {
  const AuthFormFailed(this.message);

  final String message;
}
