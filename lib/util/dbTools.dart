// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkIfDocExists(String collectionName, String docId) async {
  try {
    var collectionRef = FirebaseFirestore.instance.collection(collectionName);
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  } catch (e) {
    rethrow;
  }
}
