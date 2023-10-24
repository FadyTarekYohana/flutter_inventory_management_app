import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

dynamic getUser() async {
  var collection = FirebaseFirestore.instance.collection('users');
  var docSnapshot = await collection
      .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
      .get();
  Map<String, dynamic>? data = docSnapshot.data();
  return data;
}
