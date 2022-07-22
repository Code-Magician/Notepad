import 'package:flutter/cupertino.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
