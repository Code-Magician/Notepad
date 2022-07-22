import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/services/auth/auth_exceptions.dart';
import 'package:my_app_1/services/auth/bloc/auth_bloc.dart';
import 'package:my_app_1/services/auth/bloc/auth_event.dart';
import 'package:my_app_1/services/auth/bloc/auth_state.dart';
import 'package:my_app_1/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController emailText;
  late final TextEditingController passwdText;

  @override
  void initState() {
    emailText = TextEditingController();
    passwdText = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailText.dispose();
    passwdText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_auth_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.loc.login),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  context.loc.login_view_prompt,
                ),
                TextField(
                  controller: emailText,
                  decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder,
                  ),
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true,
                ),
                TextField(
                  controller: passwdText,
                  decoration: InputDecoration(
                    hintText: context.loc.password_text_field_placeholder,
                  ),
                  obscureText: true, // makes password come in star format
                  enableSuggestions:
                      false, // makes suggestions on keyword to hide.
                  autocorrect:
                      false, // makes autocorrect disable for that text field.
                ),
                TextButton(
                  onPressed: () async {
                    final email = emailText.text;
                    final password = passwdText.text;

                    context.read<AuthBloc>().add(
                          AuthEventLogIn(email, password),
                        );
                  },
                  child: Text(
                    context.loc.login,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(),
                        );
                  },
                  child: Text(
                    context.loc.login_view_forgot_password,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventShouldRegister());
                    },
                    child: Text(
                      context.loc.login_view_not_registered_yet,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
