import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/item_repository.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

import '../data/reservation_repository.dart';
import '../data/user_repository.dart';
import 'home_screen.dart';

// ignore: must_be_immutable
class ReservationDetailsScreen extends StatefulWidget {
  ReservationDetailsScreen({super.key, required this.itemId}) {
    _reservationReference =
        FirebaseFirestore.instance.collection('reservations');
    _itemsReference = FirebaseFirestore.instance.collection('items');
    _itemsStream = _itemsReference.snapshots();
  }
  String itemId;
  late Stream<QuerySnapshot> _itemsStream;
  late CollectionReference _reservationReference;
  late CollectionReference _itemsReference;

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late dynamic reservation;
  bool reservationLoaded = false;
  late dynamic user;
  bool userLoaded = false;

  loadData() async {
    try {
      reservation = await getReservation(widget.itemId);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    if (reservation != null) {
      setState(() {
        reservationLoaded = true;
      });
    }

    try {
      user = await getUser();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    setState(() {
      if (user != null) {
        userLoaded = true;
      }
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  late Map data;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Visibility(
        visible: reservationLoaded,
        replacement: const CircularProgressIndicator.adaptive(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              reservationLoaded ? "Reserved by ${reservation['name']}" : '',
              style: const TextStyle(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(reservationLoaded
                  ? "From ${reservation['start_date']} by ${reservation['end_date']}"
                  : ''),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: widget._itemsStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Some error occurred ${snapshot.error}"));
                  }
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot = snapshot.data;
                    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                    List<Map> items = documents
                        .map((e) => {
                              'id': e.id,
                              'name': e['name'],
                              'quantity': e['quantity'],
                              'notes': e['notes'],
                              'owner': e['owner'],
                              'image': e['image']
                            })
                        .toList();

                    return Expanded(
                      child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map thisItem = items[index];
                            if (reservationLoaded) {
                              var reservationMap =
                                  json.decode(reservation['items']);

                              if (reservationMap.containsKey(thisItem['id'])) {
                                return Card(
                                  child: ListTile(
                                    title: Text('${thisItem['name']}'),
                                    subtitle: Row(children: <Widget>[
                                      Text(
                                        'Quantity: ${reservationMap[thisItem['id']]}',
                                      )
                                    ]),
                                    leading: SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: thisItem.containsKey('image')
                                          ? Image.network(
                                              '${thisItem['image']}')
                                          : Container(),
                                    ),
                                  ),
                                );
                              }
                            }
                            return null;
                          }),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
            Visibility(
              visible: userLoaded ? user['type'] == 'admin' : false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      var reservationMap = json.decode(reservation['items']);
                      reservationMap.forEach((key, value) async {
                        var item = await getItem(key);
                        var newQuantity =
                            int.parse(value) + int.parse(item['quantity']);
                        widget._itemsReference
                            .doc(key)
                            .update({"quantity": newQuantity.toString()});
                      });
                      widget._reservationReference.doc(widget.itemId).delete();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    child: const Text("Delete Reservation")),
              ),
            )
          ],
        ),
      ),
    );
  }
}
