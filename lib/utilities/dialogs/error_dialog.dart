import 'package:flutter/cupertino.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {context.loc.ok: null},
  );
}
