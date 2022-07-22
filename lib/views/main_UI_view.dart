import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app_1/constants/routes.dart';
import 'package:my_app_1/enums/menu_actions.dart';
import 'package:my_app_1/extentions/buildContext/loc.dart';
import 'package:my_app_1/services/auth/auth_services.dart';
import 'package:my_app_1/services/auth/bloc/auth_bloc.dart';
import 'package:my_app_1/services/auth/bloc/auth_event.dart';
import 'package:my_app_1/services/cloud/cloud_firestore_database_service.dart';
import 'package:my_app_1/services/cloud/cloud_note.dart';
import 'package:my_app_1/utilities/dialogs/logout_dialog.dart';
import 'package:my_app_1/views/notes_list_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map(((event) => event.length));
}

class MainUI extends StatefulWidget {
  const MainUI({Key? key}) : super(key: key);

  @override
  State<MainUI> createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  late final FirebaseCloudStorage
      _notesService; // late means we will definately assign this variable a value.
  String get userId => AuthServices.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService =
        FirebaseCloudStorage(); // make new instance of notes service.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: StreamBuilder<int>(
            stream: _notesService.allNotes(ownerId: userId).getLength,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final noteCount = snapshot.data ?? 0;
                return Text(
                  context.loc.notes_title(noteCount),
                );
              } else {
                return const Text('');
              }
            }),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.LOGOUT:
                final signedOut = await showLogOutDialog(context);
                if (signedOut) {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.LOGOUT,
                child: Text('Logout'),
              ),
            ];
          })
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(docId: note.documentId);
                  },
                  onTap: (note) async {
                    Navigator.of(context).pushNamed(
                      newNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
