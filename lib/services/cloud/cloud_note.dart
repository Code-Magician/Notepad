import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app_1/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[userIdField],
        text = snapshot.data()[textField] as String;
}
