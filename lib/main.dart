import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_1/constants/routes.dart';
import 'package:my_app_1/helper/loading/loading_screen.dart';
import 'package:my_app_1/services/auth/bloc/auth_bloc.dart';
import 'package:my_app_1/services/auth/bloc/auth_event.dart';
import 'package:my_app_1/services/auth/bloc/auth_state.dart';
import 'package:my_app_1/services/auth/firebase_auth_provider.dart';
import 'package:my_app_1/views/forgot_password_view.dart';
import 'package:my_app_1/views/main_UI_view.dart';
import 'package:my_app_1/views/notes_view.dart';
import 'package:my_app_1/views/register_view.dart';
import 'package:my_app_1/views/verify_email_view.dart';
import 'package:my_app_1/views/login_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      title: 'WP::Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: BlocProvider(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        newNoteRoute: (context) => const NewNote(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: (state.loadingText ?? 'Please wait a moment'),
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MainUI();
        } else if (state is AuthStateNeedsVerificaton) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
