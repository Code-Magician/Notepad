import 'package:flutter/cupertino.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_note_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
