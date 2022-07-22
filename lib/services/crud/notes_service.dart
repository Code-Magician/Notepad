// import 'dart:async';
// import 'dart:developer' as Debug show log;

// import 'package:flutter/foundation.dart';
// import 'package:my_app_1/services/crud/crud_exceptions.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:my_app_1/extentions/filter.dart';

// class NotesService {
//   // making notes class a singleton
//   static final NotesService _instance = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NotesService() => _instance;

//   Database? _db;
//   DatabaseUser? _user;

//   List<DatabaseNote> _notes = [];
//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeUsingNotes();
//         }
//       });

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpen {
//       Debug.log('Database Already Open');
//     }
//   }

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setOrCreateUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);

//       if (setOrCreateUser) {
//         _user = user;
//       }

//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);

//       if (setOrCreateUser) {
//         _user = createdUser;
//       }

//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     // making sure the note exists
//     await getNote(id: note.id);

//     final updateCount = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );

//     if (updateCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       Debug.log('Note Updated : ${updatedNote.toString()}');
//       // updating the note in cache list...
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     final notes = await db.query(noteTable);

//     return notes.map((notesRow) => DatabaseNote.fromRow(notesRow));
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) {
//       throw CouldNotFIndNote();
//     } else {
//       final note = DatabaseNote.fromRow(notes.first);
//       // updating the note in cache list incase it has any change..
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();
//     final numOfDeletions = await db.delete(noteTable);

//     // clearing the cache list
//     _notes = [];
//     _notesStreamController.add(_notes);

//     return numOfDeletions;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (deletedCount == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       // remove the note from the cache memory...
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     // make sure that owner exists in the database with the correct id.
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }

//     const text = '';
//     // create an empty note in database.
//     final noteId = await db.insert(noteTable, {
//       userIdColumne: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     // adding the created note in cache list
//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     Debug.log('Created Note : ${note.toString()}');

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     // result will be empty if the user with email provided does not exist.
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (result.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       final user = DatabaseUser.fromRow(result.first);
//       Debug.log('Getting user : ${user.toString()}');
//       return user;
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     // result will be empty if the user with email provided does not exist.
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (result.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     // if user does not exist we insert the user and this function returns the
//     // userId of the row.
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     final user = DatabaseUser(id: userId, email: email);
//     Debug.log('Created User : ${user.toString()}');
//     return user;
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getCurrentDatabase();

//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (deletedCount != 1) throw CouldNotDeleteUser();
//   }

//   Database _getCurrentDatabase() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//       Debug.log('Database closed');
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpen();
//     }

//     try {
//       final docsPath =
//           await getApplicationDocumentsDirectory(); // gets the path of the database directory
//       Debug.log(docsPath.toString());
//       final dbPath = join(
//         docsPath.path,
//         dbName,
//       ); // appends the path of database directory with database name.
//       final db = await openDatabase(
//           dbPath); // if database exixts then opens database else creates the database with dbName.
//       _db = db;

//       Debug.log('Database Opened');

//       await db.execute(createUserTable); // creates user table
//       await db.execute(createNoteTable); // creates notes table

//       await _cacheNotes(); // fetching all the notes in local list.
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person id : $id, Email : $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   const DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumne] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud = (map[isSyncedWithCloudColumn] == 1) ? true : false;

//   @override
//   String toString() =>
//       'Notes Id : $id,\n Person Id : $userId,\n Note : $text,\n IsSyncedWithCloud : $isSyncedWithCloud';

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// // These names are same as mentioned in the database...
// const dbName = 'notes.db';
// const userTable = 'user';
// const noteTable = 'notes';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumne = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
// 	"id"	INTEGER NOT NULL,
// 	"email"	TEXT NOT NULL UNIQUE,
// 	PRIMARY KEY("id" AUTOINCREMENT)
// );
// ''';
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
// 	"id"	INTEGER NOT NULL,
// 	"user_id"	INTEGER NOT NULL,
// 	"text"	TEXT,
// 	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
// 	PRIMARY KEY("id" AUTOINCREMENT),
// 	FOREIGN KEY("user_id") REFERENCES "user"("id")
// );
// ''';
