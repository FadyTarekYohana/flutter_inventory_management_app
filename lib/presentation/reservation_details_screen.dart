import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

import '../data/reservation_repository.dart';
import '../data/user_repository.dart';

class ReservationDetailsScreen extends StatefulWidget {
  ReservationDetailsScreen({super.key, required this.itemId}) {
    CollectionReference _itemsReference =
        FirebaseFirestore.instance.collection('items');
    _itemsStream = _itemsReference.snapshots();
  }
  String itemId;
  late Stream<QuerySnapshot> _itemsStream;

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
      print(e);
    }

    if (reservation != null) {
      setState(() {
        reservationLoaded = true;
      });
    }

    try {
      user = await getUser();
    } catch (e) {
      print(e);
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
        replacement: CircularProgressIndicator.adaptive(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              reservationLoaded ? "Reserved by ${reservation['name']}" : '',
              style: TextStyle(fontSize: 16),
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
                                    leading: Container(
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
                      FirebaseFirestore.instance
                          .collection('reservations')
                          .doc(widget.itemId)
                          .delete();
                      GoRouter.of(context).go('/');
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
