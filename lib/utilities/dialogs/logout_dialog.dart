import 'package:flutter/cupertino.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.logout_button,
    content: context.loc.logout_dialog_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
