import 'package:kwentappflutter/core/resources/strings.dart';

sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

String failureMessage(Object error) {
  return switch (error) {
    NetworkFailure() => Strings.networkError,
    StorageFailure() => Strings.storageError,
    ServerFailure(:final message) => message,
    UnknownFailure() => Strings.genericError,
    _ => Strings.genericError,
  };
}
