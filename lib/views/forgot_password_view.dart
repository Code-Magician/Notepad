import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/services/auth/bloc/auth_bloc.dart';
import 'package:my_app_1/services/auth/bloc/auth_event.dart';
import 'package:my_app_1/services/auth/bloc/auth_state.dart';
import 'package:my_app_1/utilities/dialogs/error_dialog.dart';
import 'package:my_app_1/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _textEditingController.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              context.loc.forgot_password_view_generic_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.loc.forgot_password),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                context.loc.forgot_password_view_prompt,
              ),
              TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.loc.email_text_field_placeholder,
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _textEditingController.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: Text(
                  context.loc.forgot_password_view_send_me_link,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: Text(
                  context.loc.forgot_password_view_back_to_login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
