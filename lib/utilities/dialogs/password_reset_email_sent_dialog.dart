import 'package:flutter/cupertino.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
