import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/services/auth/auth_exceptions.dart';
import 'package:my_app_1/services/auth/bloc/auth_bloc.dart';
import 'package:my_app_1/services/auth/bloc/auth_event.dart';
import 'package:my_app_1/services/auth/bloc/auth_state.dart';
import 'package:my_app_1/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception is EmailAlreadyInUseAuthException) {
            showErrorDialog(
              context,
              context.loc.register_view_already_registered,
            );
          } else if (state.exception is WeakPasswordAuthException) {
            showErrorDialog(
              context,
              context.loc.register_error_weak_password,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            showErrorDialog(
              context,
              context.loc.register_error_invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            showErrorDialog(
              context,
              context.loc.register_error_generic,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.loc.register),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  context.loc.register_view_prompt,
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

                    context.read<AuthBloc>().add(AuthEventRegister(
                          email,
                          password,
                        ));
                  },
                  child: Text(
                    context.loc.register,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: Text(
                      context.loc.register_view_already_registered,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
