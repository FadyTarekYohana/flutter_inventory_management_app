import 'package:cloud_firestore/cloud_firestore.dart';

dynamic getItem(String itemId) async {
  var collection = FirebaseFirestore.instance.collection('items');
  var docSnapshot = await collection.doc(itemId).get();
  Map<String, dynamic>? data = docSnapshot.data();

  return data;
}
