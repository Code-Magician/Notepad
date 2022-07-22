import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_app_1/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment...',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required bool isLoading,
    required this.exception,
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({
    required bool isLoading,
    required this.user,
  }) : super(isLoading: isLoading);
}

class AuthStateSendEmailVerification extends AuthState {
  const AuthStateSendEmailVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerificaton extends AuthState {
  const AuthStateNeedsVerificaton({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword(
      {required this.exception,
      required this.hasSentEmail,
      required bool isLoading})
      : super(isLoading: isLoading);
}
