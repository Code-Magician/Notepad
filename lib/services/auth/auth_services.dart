import 'package:my_app_1/services/auth/auth_provider.dart';
import 'package:my_app_1/services/auth/auth_user.dart';
import 'package:my_app_1/services/auth/firebase_auth_provider.dart';

class AuthServices implements AuthProvider {
  final AuthProvider provider;

  const AuthServices(this.provider);

  factory AuthServices.firebase() => AuthServices(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) {
    return provider.createUser(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    return provider.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return provider.logout();
  }

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }

  @override
  Future<void> initialize() {
    return provider.initialize();
  }

  @override
  Future<void> sendPasswordReset({required String email}) =>
      provider.sendPasswordReset(email: email);
}
