import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app_1/services/cloud/cloud_note.dart';
import 'package:my_app_1/services/cloud/cloud_storage_constants.dart';
import 'package:my_app_1/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // making notes class a singleton
  static final FirebaseCloudStorage _instance =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _instance;

  final notes = FirebaseFirestore.instance
      .collection('notes'); // getting the collection named "notes"

  Future<CloudNote> createNote({required String ownerId}) async {
    final document = await notes.add({
      userIdField: ownerId,
      textField: '',
    });

    final fetchedNote = await document.get();

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerId,
      text: '',
    );
  }

  Future<void> deleteNote({required String docId}) async {
    try {
      await notes.doc(docId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String docId,
    required String text,
  }) async {
    try {
      await notes.doc(docId).update({textField: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerId}) {
    return notes
        .where(userIdField, isEqualTo: ownerId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
  }
}
