import 'package:cloud_firestore/cloud_firestore.dart';

dynamic getReservation(String reservationId) async {
  var collection = FirebaseFirestore.instance.collection('reservations');
  var docSnapshot = await collection.doc(reservationId).get();
  Map<String, dynamic>? data = docSnapshot.data();

  return data;
}
